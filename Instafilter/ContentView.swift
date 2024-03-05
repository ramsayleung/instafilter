//
//  ContentView.swift
//  Instafilter
//
//  Created by ramsayleung on 2024-03-03.
//

import SwiftUI
import StoreKit
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var intensity = 0.5
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var currentFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    var body: some View {
        NavigationStack{
            VStack {
                Spacer()
                
                // image area
                PhotosPicker(selection: $selectedItem){
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    }else{
                        ContentUnavailableView("No Image selected", systemImage: "photo.badge.plus", description: Text("Tap to import photo"))
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                
                HStack{
                    Text("Intensity")
                    Slider(value: $intensity)
                        .onChange(of: intensity, applyProcess)
                }
                
                HStack {
                    Button("Change Filter",action: changeFilter)
                    
                    Spacer()
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func changeFilter() {
        
    }
    
    func applyProcess(){
        currentFilter.intensity = Float(intensity)
        
        guard let outputImage = currentFilter.outputImage else {return}
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else{return}
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    
    func loadImage() {
        Task{
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else {return}
            
            guard let inputImage = UIImage(data: imageData) else {return}
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcess()
        }
    }
}

#Preview {
    ContentView()
}
