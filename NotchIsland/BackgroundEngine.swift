import AVFoundation
import UIKit

class BackgroundEngine: ObservableObject {
    static let shared = BackgroundEngine()

    private var audioPlayer: AVAudioPlayer?
    private var bgTaskID: UIBackgroundTaskIdentifier = .invalid

    @Published var isAlwaysOnActive: Bool = false

    init() {
        startAlwaysOnEngine()
    }

    func startAlwaysOnEngine() {
        configureAudioSession()
        playSilentAudioLoop()
        beginBackgroundTask()
        isAlwaysOnActive = true
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
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
            audioPlayer?.volume = 0.01 // Inaudible, mixes with music
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("[BackgroundEngine] Silent player error: \(error.localizedDescription)")
        }
    }

    private func beginBackgroundTask() {
        bgTaskID = UIApplication.shared.beginBackgroundTask(withName: "NotchIslandAlwaysOn") { [weak self] in
            guard let self = self else { return }
            self.playSilentAudioLoop()
            UIApplication.shared.endBackgroundTask(self.bgTaskID)
            self.bgTaskID = .invalid
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
