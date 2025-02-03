//
//  AsyncCachedImage.swift
//  Recipes
//
//  Created by Dillon Teakell on 2/1/25.
//

import Foundation
import SwiftUI

// To cache AsyncImage to disk
// Both ImageView and PlaceholderView are generircs that conform to the View protocol
struct AsyncCachedImage<ImageView: View, PlaceholderView: View>: View {
    
    // The image URL
    var url: URL?
    
    // Takes an image and returns a custom ImageView
    @ViewBuilder var content: (Image) -> ImageView
    
    // Returns a placeholder while the image is loading
    @ViewBuilder var placeholder: () -> PlaceholderView
    
    // Downloaded Image
    @State var image: UIImage? = nil
    
    // Marked as @escaping to be able to use at a future point
    init(url: URL?,
         @ViewBuilder content: @escaping (Image) -> ImageView,
         @ViewBuilder placeholder: @escaping () -> PlaceholderView
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    
    var body: some View {
        
        if let uiImage = image {
            content(Image(uiImage: uiImage))
        }
        else {
                placeholder()
                    .onAppear {
                        Task {
                            image = await downloadImage()
                }
            }
        }
    }
    
    
    // Function to download image if the image has not been cached
    private func downloadImage() async -> UIImage? {
        do {
            // Check if the URL is a URL
            guard let url else {
                return nil
            }
            
            // Check if image has been cached
            if let cachedImage = URLCache.shared.cachedResponse(for: .init(url: url)) {
                // Return the image
                return UIImage(data: cachedImage.data)
            } else {
                // Get image data from image URL
                let (data, response) = try await URLSession.shared.data(from: url)
                
                // Save returned image data
                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
                
                // Set the image as a UIImage using the data that was recieved
                guard let image = UIImage(data: data) else {
                    return nil
                }
                
                return image
            }
        }
        catch {
            print("Error Downloading: \(error)")
            return nil
        }
    }
}
