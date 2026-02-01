import CoreLocation
import SwiftUI

/// 位置情報管理クラス
@Observable
final class LocationManager: NSObject {
    /// 現在地
    var location: CLLocation?

    /// 認証状態
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    /// エラーメッセージ
    var errorMessage: String?

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    /// 位置情報の使用許可をリクエスト
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    /// 現在地を取得開始
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    /// 現在地取得を停止
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        default:
            break
        }
    }
}
