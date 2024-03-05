//
//  PhotoLibrary.swift
//  Instafilter
//
//  Created by ramsayleung on 2024-03-03.
//

import SwiftUI
import PhotosUI

struct PhotoLibrary: View {
    @State private var photoItems = [PhotosPickerItem]()
    @State private var selectedImages = [Image]()
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $photoItems,maxSelectionCount: 3, matching: .images){
                Label("Select your photos", systemImage: "photo")
            }
            .onChange(of: photoItems){
                Task {
                    selectedImages.removeAll()
                    for item in photoItems {
                        if let selected = try await item.loadTransferable(type: Image.self){
                            selectedImages.append(selected)
                        }
                    }
                }
            }
            
            ScrollView {
                ForEach(0..<selectedImages.count, id: \.self){ index in
                    selectedImages[index]
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
}

#Preview {
    PhotoLibrary()
}
