//
//  SelectedPlaceDetailView.swift
//  NearMe
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/5/3.
//

import SwiftUI
import MapKit

struct SelectedPlaceDetailView: View {
    
    @Binding var mapItem: MKMapItem?
    var onCancel: (() -> Void)? // 添加取消回调
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading){
                if let mapItem {
                    PlaceView(mapItem: mapItem)
                }
            }
            Image(systemName: "xmark.circle.fill")
                .padding([.trailing], 10)
                .onTapGesture {
                    onCancel?()
                    mapItem = nil
                }
        }
    }
}

#Preview {
    let apple = Binding<MKMapItem?>(
        get: { PreviewData.apple},
        set: {_ in}
    )
    return SelectedPlaceDetailView(mapItem: apple)
}
