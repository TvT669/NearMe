//
//  ContentView.swift
//  NearMe
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/4/28.
//

import SwiftUI
import MapKit

enum DisplayMode {
    case list
    case detail
}

struct ContentView: View {
    
    @State private var selectedDetent: PresentationDetent = .fraction(0.15)
    @State private var query: String = ""
    @State private var locationManager = LocationManager.shared
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var isSearching: Bool = false
    @State private var mapItems: [MKMapItem] = []
    @State private var visibleReginon: MKCoordinateRegion?
    @State private var selectedMapItem: MKMapItem?
    @State private var displayMode: DisplayMode = .list
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var route: MKRoute?

    private func search() async {
        do {
            mapItems = try await performSearch(searchTerm: query, visibleRegion: visibleReginon)
            isSearching = false
        } catch {
            mapItems = []
            print(error.localizedDescription)
            isSearching = false
        }
    }
    //1. 清空旧路线 → 2. 检查是否有目的地 → 3. 获取当前位置 → 4. 创建起点 → 5. 异步计算路线
    private func requestCalculateDirections() async {
        route = nil
        if let selectedMapItem {
            guard let currentUserLocation = locationManager.manager.location else { return }
            let startingMapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentUserLocation.coordinate))
                self.route = await calculationDirections(from:startingMapItem, to: selectedMapItem)
            
        }
    }
    var body: some View {
        ZStack{
            Map(position: $position, selection: $selectedMapItem){
                ForEach(mapItems,id:\.self) { mapItem in
                    Marker(item: mapItem)
                }
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
                UserAnnotation()
                
            }
            .onChange(of: locationManager.region, {
                withAnimation {
                    position = .region(locationManager.region)
                }
            })
                .sheet(isPresented: .constant(true), content: {
                    VStack {
                        switch displayMode {
                        case .list:
                            SearchBarView(search: $query, isSearching: $isSearching)
                            PlaceListView(mapItems: mapItems,selectedMapItem: $selectedMapItem)
                        case .detail:
                            SelectedPlaceDetailView(mapItem: $selectedMapItem)
                                .padding()
                            if selectedDetent == .medium || selectedDetent == .large{
                                if let selectedMapItem {
                                    ActionButtons(mapItem: selectedMapItem)
                                        .padding()
                                }
                               
                                LookAroundPreview(initialScene: lookAroundScene)
                            }
                              
                        }
                       
                        Spacer()
                    }
                    .presentationDetents([.fraction(0.15), .medium, .large],selection: $selectedDetent)//可调整高度的搜索栏
                     .presentationDragIndicator(.visible)
                     .interactiveDismissDisabled()
                     .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                })
        }
        .onChange(of: selectedMapItem, {
            if selectedMapItem != nil {
                displayMode = .detail
              //  requestCalculateDirections()
            } else {
                displayMode = .list
            }
        })
        .onMapCameraChange { context in
            visibleReginon = context.region
            
        }
        .task(id: selectedMapItem) {
            lookAroundScene = nil
            if let selectedMapItem{
                let request = MKLookAroundSceneRequest(mapItem: selectedMapItem)
                lookAroundScene = try? await request.scene
               await requestCalculateDirections()
            }
            
        }
        .task(id: isSearching,{
            if isSearching {
                await search()
            }
        })
    }
}

#Preview {
    ContentView()
}
