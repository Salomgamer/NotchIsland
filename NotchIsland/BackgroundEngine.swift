import AVFoundation
import UIKit

class BackgroundEngine: ObservableObject {
    static let shared = BackgroundEngine()

    private var audioPlayer: AVAudioPlayer?
    private var bgTaskID: UIBackgroundTaskIdentifier = .invalid
    private var watchdogTimer: Timer?

    @Published var isAlwaysOnActive: Bool = false
    @Published var keepAliveWhenClosed: Bool = true

    init() {
        startAlwaysOnEngine()
        setupLifecycleObservers()
    }

    func startAlwaysOnEngine() {
        configureAudioSession()
        playSilentAudioLoop()
        renewBackgroundTask()
        startWatchdog()
        isAlwaysOnActive = true
    }

    private func setupLifecycleObservers() {
        // Recover when audio session is interrupted (e.g. phone call, Siri, alarm)
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notif in
            guard let userInfo = notif.userInfo,
                  let typeVal = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeVal) else { return }
            if type == .ended {
                self?.ensureKeepAlive()
            }
        }

        // Recover on audio route changes
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.ensureKeepAlive()
        }

        // When app enters background or when container window minimizes
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.ensureKeepAlive()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.ensureKeepAlive()
        }
    }

    private func startWatchdog() {
        watchdogTimer?.invalidate()
        watchdogTimer = Timer.scheduledTimer(withTimeInterval: 12.0, repeats: true) { [weak self] _ in
            self?.ensureKeepAlive()
        }
    }

    func ensureKeepAlive() {
        guard keepAliveWhenClosed else { return }
        configureAudioSession()
        if audioPlayer?.isPlaying != true {
            playSilentAudioLoop()
        }
        if bgTaskID == .invalid {
            renewBackgroundTask()
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)
        } catch {
            print("[BackgroundEngine] Audio session error: \(error.localizedDescription)")
        }
    }

    private func playSilentAudioLoop() {
        let silentData = createSilentWAVData()
        do {
            audioPlayer = try AVAudioPlayer(data: silentData)
            audioPlayer?.numberOfLoops = -1 // Infinite loop
            audioPlayer?.volume = 0.001 // Inaudible, mixes seamlessly with active music
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("[BackgroundEngine] Silent player error: \(error.localizedDescription)")
        }
    }

    func renewBackgroundTask() {
        let oldTask = bgTaskID
        bgTaskID = UIApplication.shared.beginBackgroundTask(withName: "NotchIslandPersistentAlwaysOn") { [weak self] in
            self?.renewBackgroundTask()
        }
        if oldTask != .invalid {
            UIApplication.shared.endBackgroundTask(oldTask)
        }
    }

    private func createSilentWAVData() -> Data {
        var data = Data()
        let sampleRate: Int32 = 44100
        let numChannels: Int16 = 1
        let bitsPerSample: Int16 = 16
        let byteRate = sampleRate * Int32(numChannels * bitsPerSample / 8)
        let blockAlign = numChannels * bitsPerSample / 8
        let numSamples = sampleRate // 1 second of silence
        let dataSize = Int32(numSamples * Int32(blockAlign))
        let chunkSize = 36 + dataSize

        // RIFF header
        data.append(contentsOf: "RIFF".utf8)
        data.append(contentsOf: withUnsafeBytes(of: chunkSize.littleEndian) { Array($0) })
        data.append(contentsOf: "WAVE".utf8)

        // fmt chunk
        data.append(contentsOf: "fmt ".utf8)
        let subchunk1Size: Int32 = 16
        data.append(contentsOf: withUnsafeBytes(of: subchunk1Size.littleEndian) { Array($0) })
        let audioFormat: Int16 = 1 // PCM
        data.append(contentsOf: withUnsafeBytes(of: audioFormat.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: numChannels.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: sampleRate.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Array($0) })

        // data chunk
        data.append(contentsOf: "data".utf8)
        data.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Array($0) })
        data.append(Data(count: Int(dataSize)))

        return data
    }
}
