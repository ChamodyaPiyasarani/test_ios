import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.title)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .opacity(0)
                }
                .padding()
                
                // Settings Options
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.primary)
                            .frame(width: 30)
                        
                        Text("Dark Mode")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { authViewModel.currentUser?.isDarkMode ?? false },
                            set: { _ in authViewModel.toggleDarkMode() }
                        ))
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        authViewModel.toggleDarkMode()
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    Button(action: logout) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 30)
                            
                            Text("Logout")
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.red.opacity(0.7))
                        }
                        .padding()
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
                
                Spacer()
                
                // App Info
                VStack {
                    Text("Color Memory v1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("© 2024")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(authViewModel.colorScheme)
    }
    
    private func logout() {
        authViewModel.logout()
        presentationMode.wrappedValue.dismiss()
    }
}
