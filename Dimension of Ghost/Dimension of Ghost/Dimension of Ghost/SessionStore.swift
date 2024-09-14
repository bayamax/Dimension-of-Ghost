import SwiftUI
import FirebaseAuth

class SessionStore: ObservableObject {
    @Published var currentUser: AppUser?

    var handle: AuthStateDidChangeListenerHandle?

    init() {
        listen()
    }

    func listen() {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // FirebaseAuthのUserからAppUserに変換
                self.currentUser = AppUser(uid: user.uid, email: user.email, displayName: user.displayName)
            } else {
                self.currentUser = nil
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
        } catch {
            print("サインアウト中にエラーが発生しました: \(error.localizedDescription)")
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

// 独自のユーザーモデル
struct AppUser {
    var uid: String
    var email: String?
    var displayName: String?
}
