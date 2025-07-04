//
//  ContentView.swift
//  NearMe
//
//  Created by 珠穆朗玛小蜜蜂 .
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
   // @State private var isTrackingUserLocation = true // 新增跟踪状态
    
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
            
            // 使用统一的位置源
                  guard let currentUserLocation = locationManager.currentLocation else { return }
          //  guard let currentUserLocation = locationManager.manager.location else { return }
            
            // 打印起点位置
              let startCoord = currentUserLocation.coordinate
              print("🚗 路线起点位置:")
              print("🚗 经度: \(startCoord.longitude)")
              print("🚗 纬度: \(startCoord.latitude)")
              
              // 打印终点位置
              let endCoord = selectedMapItem.placemark.coordinate
              print("🏁 路线终点位置:")
              print("🏁 经度: \(endCoord.longitude)")
              print("🏁 纬度: \(endCoord.latitude)")
              print("🏁 地点名称: \(selectedMapItem.name ?? "未知地点")")
            
            let startingMapItem = MKMapItem(placemark: MKPlacemark(coordinate: currentUserLocation.coordinate))
            
            
                self.route = await calculationDirections(from:startingMapItem, to: selectedMapItem)
            
        }
        
    
    }
    
    private func clearRoute() {
        route = nil // 清空路线
        print("✅ 路线规划已清除")
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
                
                  /* 自定义用户位置标记
                  if let userLocation = locationManager.currentLocation?.coordinate {
                      Annotation(
                          "我的位置",
                          coordinate: userLocation,
                          anchor: .center
                      ) {
                          ZStack {
                              // 定位精度圈（动态大小）
                              Circle()
                                  .fill(Color.blue.opacity(0.25))
                                  .frame(width: locationManager.currentLocation?.horizontalAccuracy ?? 30,
                                         height: locationManager.currentLocation?.horizontalAccuracy ?? 30)
                              
                              // 位置指示器
                              Circle()
                                  .fill(.blue)
                                  .frame(width: 15, height: 15)
                                  .zIndex(2)
                          }
                      }
                  }*/
              }
            
           /* .onChange(of: isTrackingUserLocation) {
                       if isTrackingUserLocation {
                           withAnimation {
                               position = .userLocation(fallback: .automatic)
                           }
                       }
                   }
            .onChange(of: locationManager.currentLocation) { newLocation in
                guard let location = newLocation, isTrackingUserLocation else { return }
                            
                            // 更平滑的位置更新
                            DispatchQueue.main.async {
                                position = .region(MKCoordinateRegion(
                                    center: location.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                                ))
                                
                                print("📍 视图位置更新:")
                                print("📍 经度: \(location.coordinate.longitude)")
                                print("📍 纬度: \(location.coordinate.latitude)")
                            }
             }*/
     
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
                            {
                                clearRoute()
                            }
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
            
            let center = context.region.center
                print("地图中心位置: 经度=\(center.longitude), 纬度=\(center.latitude)")
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
