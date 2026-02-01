import SwiftUI
import MapKit

/// ビルマップ画面のViewModel
@MainActor
@Observable
final class BuildingMapViewModel {
    /// ビルリポジトリ
    private let buildingRepository = BuildingRepository.shared

    /// 位置情報マネージャー
    let locationManager = LocationManager()

    /// 選択中のビル
    var selectedBuilding: Building?

    /// マップカメラ位置
    var cameraPosition: MapCameraPosition

    /// ビル一覧
    var buildings: [Building] {
        buildingRepository.buildings
    }

    /// 読み込み中かどうか
    var isLoading: Bool {
        buildingRepository.isLoading
    }

    init() {
        let appState = AppState.shared
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: appState.defaultMapLatitude,
                longitude: appState.defaultMapLongitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    /// ビルデータを読み込む
    func loadBuildings() async {
        await buildingRepository.fetchBuildings()
    }

    /// ビルを選択
    func selectBuilding(_ building: Building?) {
        selectedBuilding = building
        if let building = building {
            // 選択したビルに地図を移動
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: building.latitude,
                        longitude: building.longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        }
    }

    /// 現在地に移動
    func moveToCurrentLocation() {
        locationManager.requestAuthorization()
        if let location = locationManager.location {
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            }
        }
    }

    /// 指定した座標に移動
    func moveTo(latitude: Double, longitude: Double) {
        withAnimation {
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            ))
        }
    }
}
