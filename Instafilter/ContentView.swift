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
    @State private var showingFilters = false
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
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
                    
                    if let processedImage {
                        ShareLink(item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Select a filter", isPresented: $showingFilters){
                Button("Crystallize"){setFilter(CIFilter.crystallize())}
                Button("Edges"){setFilter(CIFilter.edges())}
                Button("Gaussian Blur"){setFilter(CIFilter.gaussianBlur())}
                Button("Pixellate"){setFilter(CIFilter.pixellate())}
                Button("Sepia Tone"){setFilter(CIFilter.sepiaTone())}
                Button("Unsharp Mask"){setFilter(CIFilter.unsharpMask())}
                Button("Vignette"){setFilter(CIFilter.vignette())}
                Button("Cancel", role: .cancel){ }
            }
        }
    }
    
    func changeFilter() {
        showingFilters.toggle()
    }
    
    func applyProcess(){
        let inputKey = currentFilter.inputKeys
        
        if inputKey.contains(kCIInputIntensityKey){
            currentFilter.setValue(intensity, forKey: kCIInputIntensityKey)
        }
        if inputKey.contains(kCIInputRadiusKey){
            currentFilter.setValue(intensity * 200, forKey: kCIInputRadiusKey)
        }
        if inputKey.contains(kCIInputScaleKey){
            currentFilter.setValue(intensity * 10, forKey: kCIInputScaleKey)
        }
        
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
    
    @MainActor func setFilter(_ filter: CIFilter){
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        if filterCount >= 7 && (filterCount == 7 || filterCount % 129 == 0) {
            requestReview()
        }
    }
}

#Preview {
    ContentView()
}
