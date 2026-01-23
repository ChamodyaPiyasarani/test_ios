import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showLoginAfterLogout = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer for centering
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .opacity(0)
                }
                .padding()
                
                // Settings Options
                VStack(spacing: 0) {
                    SettingRow(
                        icon: "moon.fill",
                        title: "Dark Mode",
                        isToggle: true,
                        isOn: Binding(
                            get: { authViewModel.currentUser?.isDarkMode ?? false },
                            set: { _ in
                                authViewModel.toggleDarkMode()
                                // Force update the color scheme
                                updateColorScheme()
                            }
                        )
                    )
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    SettingRow(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Logout",
                        action: logout
                    )
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // App Info
                VStack {
                    Text("Color Memory v1.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("© 2024")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showLoginAfterLogout) {
            LoginView(authViewModel: authViewModel)
        }
    }
    
    private func logout() {
        authViewModel.logout()
        
        // Dismiss settings view first
        presentationMode.wrappedValue.dismiss()
        
        // Show login after a short delay to allow animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showLoginAfterLogout = true
        }
    }
    
    private func updateColorScheme() {
        // This forces the view hierarchy to update
        NotificationCenter.default.post(name: NSNotification.Name("UpdateColorScheme"), object: nil)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    var isToggle: Bool = false
    var isOn: Binding<Bool>?
    var action: (() -> Void)?
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            if isToggle, let isOn = isOn {
                Toggle("", isOn: isOn)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            if !isToggle {
                action?()
            }
        }
    }
}
