import SwiftUI
import MapKit

/// ビルマップ画面
/// Google Mapを全画面表示し、ビルをピンで表示
/// 注: Swift PlaygroundsではGoogle Maps SDKが使用できないため、
/// Apple Mapで代替実装。Xcodeプロジェクトへ移行時にGoogle Maps SDKに置き換え可能
struct BuildingMapView: View {
    /// ViewModel
    @State private var viewModel = BuildingMapViewModel()

    /// 詳細画面へのナビゲーション用
    @State private var navigationPath = NavigationPath()

    var body: some View {
        ZStack {
            // マップ表示
            Map(position: $viewModel.cameraPosition, selection: Binding(
                get: { viewModel.selectedBuilding?.buildingId },
                set: { id in
                    if let id = id {
                        viewModel.selectBuilding(viewModel.buildings.first { $0.buildingId == id })
                    } else {
                        viewModel.selectBuilding(nil)
                    }
                }
            )) {
                // ビルのピン表示
                ForEach(viewModel.buildings) { building in
                    Marker(
                        building.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: building.latitude,
                            longitude: building.longitude
                        )
                    )
                    .tint(AppColors.primary)
                    .tag(building.buildingId)
                }

                // 現在地表示
                UserAnnotation()
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }

            // ビル概要カード（ビル選択時）
            if let building = viewModel.selectedBuilding {
                VStack {
                    Spacer()
                    BuildingCardView(
                        building: building,
                        tenantCompanies: BuildingRepository.shared.getCompanies(for: building.buildingId),
                        onDetailTap: {
                            navigationPath.append(building)
                        },
                        onDismiss: {
                            viewModel.selectBuilding(nil)
                        }
                    )
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.3), value: viewModel.selectedBuilding?.id)
            }
        }
        .navigationTitle("ビルマップ")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Building.self) { building in
            BuildingDetailView(building: building)
        }
        .task {
            await viewModel.loadBuildings()
            viewModel.locationManager.requestAuthorization()
        }
    }
}

#Preview {
    NavigationStack {
        BuildingMapView()
    }
    .environment(AppState.shared)
}
