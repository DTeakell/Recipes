//
//  ImageManager.swift
//  Recipes
//
//  Created by Dillon Teakell on 1/31/25.
//

import Foundation
import SwiftUI

final class ImageManager {
    let shared = ImageManager()
    
    init() {}
    
    // Get the URL for the file of the image
    private func getImageFileURL(for url: URL) -> URL? {
        guard let fileName = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
            return nil
        }
        
        let fileManager = FileManager.default
        let cacheDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheDirectoryURL.appendingPathComponent(fileName)
    }
    
    // Function to save the image to the disk
    func saveImage(_ image: UIImage, for url: URL) {
        // Get the file URL and set the quality
        guard let fileURL = getImageFileURL(for: url), let imageData = image.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        // Write the data
        do {
            try imageData.write(to: fileURL, options: .atomic)
            print("Image has been saved!")
        }
        catch {
            print("Failed to save image: \(error.localizedDescription)")
        }
    }
    
    
    // Function to load the image
    func loadImage(for url: URL) -> UIImage? {
        
        // Retrieve the image from the URL
        guard let fileURL = getImageFileURL(for: url) else {
            return nil
        }
        
        // Check if the file exists, and return a UIImage
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
}
