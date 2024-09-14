import SwiftUI
import MapKit
import FirebaseDatabase
import FirebaseAuth

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager = LocationManager()
    let mapView = MKMapView()
    let databaseRef = Database.database().reference()

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        // 他のユーザーの位置情報を取得
        fetchUserLocations()
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let userLocation = locationManager.lastLocation {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            uiView.setRegion(region, animated: true)
            // 現在地をデータベースに送信（実体モードの場合）
            uploadUserLocation(location: userLocation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // 他のユーザーの位置情報を取得
    func fetchUserLocations() {
        databaseRef.child("user_locations").observe(.value) { snapshot in
            var annotations: [MKPointAnnotation] = []
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let lat = dict["latitude"] as? CLLocationDegrees,
                   let lon = dict["longitude"] as? CLLocationDegrees,
                   let userId = dict["userId"] as? String {
                    // 自分自身の位置情報は表示しない
                    if userId == Auth.auth().currentUser?.uid {
                        continue
                    }
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    // ユーザーIDをタイトルに設定
                    annotation.title = userId
                    annotations.append(annotation)
                }
            }
            // 既存のアノテーションを削除して新しいものを追加
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(annotations)
        }
    }

    // 現在地をデータベースに送信
    func uploadUserLocation(location: CLLocation) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userLocationRef = databaseRef.child("user_locations").child(userId)
        userLocationRef.setValue([
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "userId": userId
        ])
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        // アノテーションのビューをカスタマイズ
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                // ユーザー自身の位置情報はデフォルト表示
                return nil
            }

            let identifier = "UserAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            // アノテーションの色を設定（フレンドかどうかで色分け可能）
            annotationView?.pinTintColor = UIColor.red

            return annotationView
        }
    }
}
