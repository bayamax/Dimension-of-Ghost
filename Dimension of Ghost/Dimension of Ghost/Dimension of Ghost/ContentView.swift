import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    @State private var isGhostMode = true

    var body: some View {
        VStack {
            // モード切替スイッチ
            Toggle(isOn: $isGhostMode) {
                Text(isGhostMode ? "幽霊モード" : "実体モード")
            }
            .padding()

            // モードに応じて表示を切り替え
            if isGhostMode {
                GhostModeView()
            } else {
                RealModeView()
            }

            // サインアウトボタン
            Button(action: {
                session.signOut()
            }) {
                Text("サインアウト")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}
