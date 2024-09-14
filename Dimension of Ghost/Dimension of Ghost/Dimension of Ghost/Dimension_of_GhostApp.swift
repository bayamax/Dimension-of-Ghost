import SwiftUI

@main
struct Dimension_of_GhostApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            if session.currentUser != nil {
                ContentView()
                    .environmentObject(session)
            } else {
                LoginView()
                    .environmentObject(session)
            }
        }
    }
}
