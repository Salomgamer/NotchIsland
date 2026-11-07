import UIKit
import SwiftUI
import Combine

enum WallpaperPreset: String, CaseIterable, Identifiable {
    case astralOled = "Astral OLED"
    case liquidPrism = "Liquid Prism"
    case oceanGlass = "Ocean Glass"
    case frostedAcrylic = "Frosted Acrylic"
    case sunsetAmber = "Sunset Amber"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .astralOled: return "moon.stars.fill"
        case .liquidPrism: return "sparkles"
        case .oceanGlass: return "drop.fill"
        case .frostedAcrylic: return "aqi.medium"
        case .sunsetAmber: return "sunset.fill"
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .astralOled:
            return LinearGradient(
                colors: [Color(white: 0.14), Color(white: 0.04)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .liquidPrism:
            return LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.22, blue: 0.38),
                    Color(red: 0.25, green: 0.12, blue: 0.32),
                    Color(red: 0.08, green: 0.18, blue: 0.24)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .oceanGlass:
            return LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.25, blue: 0.35),
                    Color(red: 0.02, green: 0.10, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .frostedAcrylic:
            return LinearGradient(
                colors: [
                    Color(white: 0.24),
                    Color(white: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sunsetAmber:
            return LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.14, blue: 0.10),
                    Color(red: 0.15, green: 0.04, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

class WallpaperService: ObservableObject {
    static let shared = WallpaperService()

    @Published var customWallpaper: UIImage? = nil
    @Published var croppedSlice: UIImage? = nil
    @Published var glassBlurRadius: CGFloat = 16.0
    @Published var glassOpacity: Double = 0.55
    @Published var specularSheen: Double = 0.65
    @Published var liquidShimmer: Bool = true
    @Published var hasCustomWallpaper: Bool = false
    @Published var selectedPreset: WallpaperPreset = .liquidPrism

    private let wallpaperFileURL: URL
    private let sliceFileURL: URL

    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.wallpaperFileURL = docs.appendingPathComponent("custom_wallpaper.jpg")
        self.sliceFileURL = docs.appendingPathComponent("cropped_notch_slice.jpg")
        loadSavedWallpaper()
    }

    func setWallpaper(_ image: UIImage) {
        self.customWallpaper = image
        self.hasCustomWallpaper = true

        // 1. Crop top slice where the notch sits
        let slice = generateNotchSlice(from: image)
        self.croppedSlice = slice

        // 2. Persist to disk
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            if let fullData = image.jpegData(compressionQuality: 0.85) {
                try? fullData.write(to: self.wallpaperFileURL)
            }
            if let slice = slice, let sliceData = slice.jpegData(compressionQuality: 0.90) {
                try? sliceData.write(to: self.sliceFileURL)
            }
        }

        // 3. Switch background style to liquid wallpaper glass
        IslandState.shared.backgroundStyle = .liquidWallpaperGlass
        HapticService.shared.success()
        IslandState.shared.triggerNotification(
            title: "Liquid Wallpaper Glass",
            subtitle: "Wallpaper Glass Tint Applied",
            icon: "drop.fill",
            color: Color(red: 0.0, green: 0.85, blue: 1.0)
        )
    }

    func clearCustomWallpaper() {
        self.customWallpaper = nil
        self.croppedSlice = nil
        self.hasCustomWallpaper = false
        try? FileManager.default.removeItem(at: wallpaperFileURL)
        try? FileManager.default.removeItem(at: sliceFileURL)
        HapticService.shared.light()
    }

    private func loadSavedWallpaper() {
        if FileManager.default.fileExists(atPath: sliceFileURL.path),
           let sliceData = try? Data(contentsOf: sliceFileURL),
           let slice = UIImage(data: sliceData) {
            self.croppedSlice = slice
            self.hasCustomWallpaper = true
        }

        if FileManager.default.fileExists(atPath: wallpaperFileURL.path),
           let fullData = try? Data(contentsOf: wallpaperFileURL),
           let full = UIImage(data: fullData) {
            self.customWallpaper = full
            self.hasCustomWallpaper = true
        }
    }

    private func generateNotchSlice(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        // The iPhone camera notch occupies the top ~10-14% of the screen center
        let sliceWidth = width * 0.70
        let sliceHeight = height * 0.16
        let originX = (width - sliceWidth) / 2.0
        let originY: CGFloat = 0.0

        let cropRect = CGRect(x: originX, y: originY, width: sliceWidth, height: sliceHeight)

        guard let cropped = cgImage.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }
}

// MARK: - Native Photo Library Picker
struct ImagePickerRepresentable: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerRepresentable

        init(_ parent: ImagePickerRepresentable) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                WallpaperService.shared.setWallpaper(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
