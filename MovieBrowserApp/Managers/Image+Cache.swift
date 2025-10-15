//
//  Image+Cache.swift
//  MovieBrowserApp
//
//  Created by Roberto Ramirez on 10/14/25.
//

import UIKit

class ImageCache {
    static var shared: ImageCache = .init()
    private init() {}
    
    private var cache: NSCache<NSString, UIImage> = .init()
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    func insertImage(_ image: UIImage?, forKey key: String) {
        guard let image = image else { return }
        cache.setObject(image, forKey: key as NSString)
    }
    //Load image from URL
    func loadImage(from url: URL) async throws -> UIImage {
        //load from cache
        if let cached = ImageCache.shared.image(forKey: url.absoluteString) {
            return cached
        }
        
        //load from disk
        if let cached = loadImageFromDisk(fileName: url.absoluteString) {
            return cached
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else { throw URLError(.badServerResponse) }
        
        ImageCache.shared.insertImage(image, forKey: url.absoluteString)//Save to cache
        ImageCache.shared.saveImageToDisk(image, fileName: url.absoluteString)//save to disk
        return image
    }
    
    //disk cache
    func saveImageToDisk(_ image: UIImage, fileName: String) {
        guard let data = image.pngData() else { return }
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        try? data.write(to: url)
    }

    func loadImageFromDisk(fileName: String) -> UIImage? {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
