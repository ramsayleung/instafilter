//
//  ContentUnavailableView.swift
//  Instafilter
//
//  Created by ramsayleung on 2024-03-02.
//

import SwiftUI

struct CUView: View {
    var body: some View {
        ContentUnavailableView{
            Label("No snippet", systemImage: "swift")
        } description: {
            Text("You don't have any code snippet yet")
        } actions: {
            Button("Create snippet"){
                
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    CUView()
}
