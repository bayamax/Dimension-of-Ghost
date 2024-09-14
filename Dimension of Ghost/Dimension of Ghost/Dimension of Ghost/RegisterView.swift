import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @EnvironmentObject var session: SessionStore
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            // アプリ名を表示
            Text("Dimension of Ghost")
                .font(.largeTitle)
                .padding()

            // ユーザーネーム入力フィールド
            TextField("ユーザーネーム", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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

            // 登録ボタン
            Button(action: {
                register()
            }) {
                Text("登録")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()

            // エラーメッセージの表示
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    // ユーザー登録処理
    func register() {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "全ての項目を入力してください。"
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                // ユーザー名を設定
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.errorMessage = ""
                        // 登録成功時の処理はSessionStoreが担当
                    }
                }
            }
        }
    }
}
