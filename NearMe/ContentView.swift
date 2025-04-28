//
//  ContentView.swift
//  NearMe
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/4/28.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var selectedDetent: PresentationDetent = .fraction(0.15)
    @State private var query: String = ""
    
    var body: some View {
        ZStack{
            Map()
                .sheet(isPresented: .constant(true), content: {
                    VStack {
                        TextField("Search",text: $query)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                            .onSubmit {
                                
                            }
                        Spacer()
                    }
                    .presentationDetents([.fraction(0.15), .medium, .large], selection: $selectedDetent)//可调整高度的搜索栏
                     .presentationDragIndicator(.visible)
                     .interactiveDismissDisabled()
                     .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                })
        }
    }
}

#Preview {
    ContentView()
}
