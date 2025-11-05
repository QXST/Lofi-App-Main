//
//  ImageCache.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import UIKit
import SwiftUI

actor ImageCache {
    static let shared = ImageCache()

    private var cache = NSCache<NSString, UIImage>()
    private var loadingTasks: [URL: Task<UIImage?, Never>] = [:]

    private init() {
        cache.countLimit = 100 // Maximum number of images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    // MARK: - Cache Operations
    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url.absoluteString as NSString)
    }

    func setImage(_ image: UIImage, for url: URL) {
        let cost = image.pngData()?.count ?? 0
        cache.setObject(image, forKey: url.absoluteString as NSString, cost: cost)
    }

    func removeImage(for url: URL) {
        cache.removeObject(forKey: url.absoluteString as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }

    // MARK: - Image Loading
    func loadImage(from url: URL) async -> UIImage? {
        // Check cache first
        if let cachedImage = image(for: url) {
            return cachedImage
        }

        // Check if already loading
        if let existingTask = loadingTasks[url] {
            return await existingTask.value
        }

        // Create new loading task
        let task = Task<UIImage?, Never> {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    return nil
                }

                // Cache the image
                setImage(image, for: url)
                return image
            } catch {
                print("Failed to load image from \(url): \(error.localizedDescription)")
                return nil
            }
        }

        loadingTasks[url] = task

        let image = await task.value
        loadingTasks.removeValue(forKey: url)

        return image
    }
}

// MARK: - Cached AsyncImage View
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let content: (Image) -> Content
    let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = false

    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
        }
    }

    private func loadImage() async {
        guard let url = url else { return }

        isLoading = true

        // Try cache first
        let cachedImage = await ImageCache.shared.image(for: url)
        if let cachedImage = cachedImage {
            self.image = cachedImage
            isLoading = false
            return
        }

        // Load from network
        let loadedImage = await ImageCache.shared.loadImage(from: url)
        self.image = loadedImage
        isLoading = false
    }
}

// MARK: - View Extension for Easy Use
extension View {
    func cachedAsyncImage(from urlString: String?) -> some View {
        modifier(CachedImageModifier(urlString: urlString))
    }
}

struct CachedImageModifier: ViewModifier {
    let urlString: String?

    func body(content: Content) -> some View {
        if let urlString = urlString, let url = URL(string: urlString) {
            CachedAsyncImage(url: url) { image in
                image
                    .resizable()
            } placeholder: {
                content
            }
        } else {
            content
        }
    }
}
