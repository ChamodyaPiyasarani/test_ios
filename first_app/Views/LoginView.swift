import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var username = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Welcome")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                
                TextField("Enter username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 40)
                
                Button(action: login) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .disabled(username.isEmpty)
                
                // Existing Users
                if !authViewModel.users.isEmpty {
                    VStack {
                        Text("Existing Users")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(authViewModel.users) { user in
                                    Button(action: {
                                        username = user.username
                                        login()
                                    }) {
                                        HStack {
                                            Text(user.username)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(systemName: "person.circle")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .frame(height: 200)
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
            }
            .padding(.top, 50)
        }
    }
    
    private func login() {
        authViewModel.login(username: username)
        presentationMode.wrappedValue.dismiss()
    }
}
