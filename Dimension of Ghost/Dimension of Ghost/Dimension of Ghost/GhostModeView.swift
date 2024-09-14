import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import MapKit
import CoreLocation

struct GhostModeView: View {
    // ドラッグ可能なピンの座標を保持
    @State private var coordinate = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917) // 東京の座標
    let databaseRef = Database.database().reference()

    var body: some View {
        // ドラッグ可能なマップビューを表示
        MapViewRepresentable(coordinate: $coordinate)
            .edgesIgnoringSafeArea(.all)
            .onDisappear {
                // ビューが閉じられるときに座標を保存
                uploadGhostLocation()
            }
    }

    // 幽霊モードの位置情報をデータベースに送信
    func uploadGhostLocation() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ghostLocationRef = databaseRef.child("ghost_locations").child(userId)
        ghostLocationRef.setValue([
            "latitude": coordinate.latitude,
            "longitude": coordinate.longitude,
            "userId": userId
        ])
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let annotation = uiView.annotations.first as? MKPointAnnotation {
            annotation.coordinate = coordinate
        } else {
            // アノテーションが存在しない場合、新しく追加
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = coordinate
            uiView.addAnnotation(newAnnotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        // アノテーションのビューをカスタマイズ
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "DraggablePin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.isDraggable = true
            } else {
                annotationView?.annotation = annotation
            }

            // ピンの色を灰色に設定
            annotationView?.pinTintColor = UIColor.gray

            return annotationView
        }

        // ピンのドラッグが終了したときに座標を更新
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            if newState == .ending {
                if let annotation = view.annotation as? MKPointAnnotation {
                    parent.coordinate = annotation.coordinate
                }
            }
        }
    }
}
