//
//  ContentView.swift
//  Instafilter
//
//  Created by ramsayleung on 2024-03-01.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImageManipulatedView: View {
    @State private var image: Image?
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
        }
        .onAppear(perform: loadImage)
    }
    
    func loadImage() {
        let inputImage = UIImage(resource: .example)
        let beginImage = CIImage(image: inputImage)
        
        let context = CIContext()
        let currentFilter = CIFilter.sepiaTone()
        
        currentFilter.inputImage = beginImage
        
        let amount = 1.0
        
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(amount, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputScaleKey){
            currentFilter.setValue(amount * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputRadiusKey){
            currentFilter.setValue(amount * 20, forKey: kCIInputRadiusKey)
        }
        
        // UIImage -> CIImage -> <perform transform> -> CIImage -> CGImage -> UIImage -> Image
        // get a CIImage from our filter or exit if that fails
        guard let outputImage = currentFilter.outputImage else {
            return
        }
        
        // attempt to get a CGImage from our CIImage
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return
        }
        
        // convert that to a UIImage
        let uiImage = UIImage(cgImage: cgImage)
        image = Image(uiImage: uiImage)
        //        image = Image(.example)
    }
}

#Preview {
    ImageManipulatedView()
}
