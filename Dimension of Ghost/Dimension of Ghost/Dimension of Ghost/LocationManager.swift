import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    // CLLocationManagerのインスタンス
    private let manager = CLLocationManager()
    // ユーザーの現在位置
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        // 位置情報の使用許可をリクエスト
        manager.requestWhenInUseAuthorization()
        // 位置情報の更新を開始
        manager.startUpdatingLocation()
    }

    // 位置情報が更新されたときに呼ばれるデリゲートメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 最新の位置情報を取得
        lastLocation = locations.first
    }

    // 位置情報の使用許可が変更されたときに呼ばれるデリゲートメソッド
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            // 許可されている場合は位置情報の更新を開始
            manager.startUpdatingLocation()
        case .notDetermined:
            // 許可が未決定の場合はリクエスト
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // 許可が拒否された場合は適切な対応を行う
            print("位置情報の使用が許可されていません。")
        @unknown default:
            break
        }
    }
}
