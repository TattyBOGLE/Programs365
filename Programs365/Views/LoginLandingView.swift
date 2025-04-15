import SwiftUI

struct LoginLandingView: View {
    @State private var isShowingLogin = false
    @State private var isShowingRegister = false
    @State private var isShowingHome = false
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    
    // Define consistent colors
    private let backgroundColor = Color.black
    private let primaryRed = Color.red
    private let textFieldBackground = Color.white.opacity(0.08)
    private let buttonBackground = Color.white.opacity(0.05)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Image with Overlay
                Image("track_hero_banner")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.85),
                                Color.black.opacity(0.6),
                                Color.black.opacity(0.3),
                                Color.black.opacity(0.1)
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Title and Subtitle Group
                    VStack(spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: -10) {
                            Text("Program")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack(alignment: .bottom, spacing: 0) {
                                Text("365")
                                    .font(.system(size: 70, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
                        
                        // Subtitle
                        Text("Your Personal Athletics Coach")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding(.bottom, 50)
                    
                    // Login/Register Form
                    VStack(spacing: 16) {
                        if isShowingLogin || isShowingRegister {
                            // Email Field
                            TextField("Email", text: $email)
                                .textFieldStyle(DefaultTextFieldStyle())
                                .padding(12)
                                .background(textFieldBackground)
                                .cornerRadius(25)
                                .foregroundColor(.white)
                                .accentColor(primaryRed)
                                .padding(.horizontal, 24)
                                .autocapitalization(.none)
                            
                            // Password Field
                            SecureField("Password", text: $password)
                                .textFieldStyle(DefaultTextFieldStyle())
                                .padding(12)
                                .background(textFieldBackground)
                                .cornerRadius(25)
                                .foregroundColor(.white)
                                .accentColor(primaryRed)
                                .padding(.horizontal, 24)
                            
                            // Submit Button
                            Button(action: handleSubmit) {
                                Text(isLoginMode ? "Login" : "Register")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(primaryRed)
                                    .cornerRadius(25)
                                    .padding(.horizontal, 24)
                            }
                            
                            // Switch Mode Button
                            Button(action: { 
                                isLoginMode.toggle()
                                isShowingLogin = isLoginMode
                                isShowingRegister = !isLoginMode
                            }) {
                                Text(isLoginMode ? "Need an account? Register" : "Already have an account? Login")
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        } else {
                            // Initial Buttons
                            VStack(spacing: 16) {
                                Button(action: { isShowingLogin = true }) {
                                    Text("Login")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(primaryRed)
                                        .cornerRadius(25)
                                }
                                
                                Button(action: { isShowingRegister = true }) {
                                    Text("Register")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(buttonBackground)
                                        .cornerRadius(25)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Bypass Login Button
                        Button(action: { isShowingHome = true }) {
                            Text("Continue without login")
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            .background(backgroundColor)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isShowingHome) {
                DashboardView()
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private func handleSubmit() {
        // Here you would typically handle the actual login/register logic
        // For now, we'll just navigate to the home page
        isShowingHome = true
    }
}

// Preview
struct LoginLandingView_Previews: PreviewProvider {
    static var previews: some View {
        LoginLandingView()
    }
} 