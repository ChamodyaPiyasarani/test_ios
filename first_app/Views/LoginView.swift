import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var username = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Welcome")
                    .font(.largeTitle)
                    .foregroundColor(AppColors.textColor)
                    .bold()
                
                TextField("Enter username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 40)
                
                Button(action: login) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .disabled(username.isEmpty)
                
                // Existing Users
                if !authViewModel.users.isEmpty {
                    VStack {
                        Text("Existing Users")
                            .font(.headline)
                            .foregroundColor(AppColors.secondaryTextColor)
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
                                                .foregroundColor(AppColors.textColor)
                                            Spacer()
                                            Image(systemName: "person.circle")
                                                .foregroundColor(AppColors.secondaryTextColor)
                                        }
                                        .padding()
                                        .background(AppColors.cardBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(AppColors.borderColor, lineWidth: 1)
                                        )
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
        .preferredColorScheme(authViewModel.colorScheme)
    }
    
    private func login() {
        authViewModel.login(username: username)
        presentationMode.wrappedValue.dismiss()
    }
}
