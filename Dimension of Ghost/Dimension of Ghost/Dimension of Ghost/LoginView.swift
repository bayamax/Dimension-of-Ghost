import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack {
                // アプリ名を表示
                Text("Dimension of Ghost")
                    .font(.largeTitle)
                    .padding()

                // メールアドレス入力フィールド
                TextField("メールアドレス", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // パスワード入力フィールド
                SecureField("パスワード", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // ログインボタン
                Button(action: {
                    login()
                }) {
                    Text("ログイン")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding()

                // エラーメッセージの表示
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                // ユーザー登録画面へのリンク
                NavigationLink(destination: RegisterView()) {
                    Text("新規登録はこちら")
                }
                .padding()

                Spacer()
            }
            .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // ログイン処理
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "メールアドレスとパスワードを入力してください。"
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.errorMessage = ""
                // ログイン成功時の処理はSessionStoreが担当
            }
        }
    }
}
