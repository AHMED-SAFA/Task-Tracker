import SwiftUI
import Firebase
import FirebaseAuth

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var userIsLoggedIn = false
    @State private var isSignUpMode = true
    @State private var errorMessage = ""
    @State private var showListView = false

    var body: some View {
        VStack {
            if userIsLoggedIn {
                ListView(userIsLoggedIn: $userIsLoggedIn)
            } else {
                content
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    showListView = true
                }) {
                    Text("About Us")
                        .bold()
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
                .sheet(isPresented: $showListView) {
                    APIListView()
                }
            }
        }
    }

    var content: some View {
        ZStack {
            // Enhanced Background Gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(isSignUpMode ? "Create Account" : "Welcome Back")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                    .padding(.top, 50)
                    .transition(.opacity)

                // Email Field with Enhanced Border
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email Address")
                        .foregroundColor(.black)
                        .font(.subheadline)
                    TextField("Enter your email", text: $email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.black, lineWidth: 2))
                        .foregroundColor(.black)
                        .padding(.top, 5)
                        .autocapitalization(.none)
                }
                .padding(.horizontal)

                // Password Field with Enhanced Border
                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                        .foregroundColor(.black)
                        .font(.subheadline)
                    SecureField("Enter your password", text: $password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.black, lineWidth: 2))
                        .foregroundColor(.black)
                        .padding(.top, 5)
                }
                .padding(.horizontal)

                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.body)
                        .padding(.top, 10)
                        .transition(.opacity)
                }

                // Login / Register Button with Gradient
                Button(action: {
                    if isSignUpMode {
                        register()
                    } else {
                        login()
                    }
                }) {
                    Text(isSignUpMode ? "Create Account" : "Sign In")
                        .bold()
                        .frame(width: 250, height: 50)
                        .background(RoundedRectangle(cornerRadius: 25).fill(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.red]), startPoint: .leading, endPoint: .trailing)))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.top)
                }

                // Toggle Button (Sign up / Login)
                Button(action: {
                    isSignUpMode.toggle()
                }) {
                    Text(isSignUpMode ? "Already have an account? Log In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                        .animation(.easeInOut)
                }

                // Forgot Password Button (only in Login mode)
                if !isSignUpMode {
                    Button(action: {
                        resetPassword()
                    }) {
                        Text("Forgot Password?")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.top, 10)
                            .animation(.easeInOut)
                    }
                }
            }
            .frame(width: 350)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(radius: 20)
            )
            .onAppear {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        userIsLoggedIn = true
                    }
                }
            }
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                userIsLoggedIn = true
                errorMessage = ""
            }
        }
    }

    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                userIsLoggedIn = true
                errorMessage = ""
            }
        }
    }

    func resetPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Password reset email sent. Check your inbox!"
            }
        }
    }
}

struct ContactDetailView: View {
    let record: Record
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Image
                AsyncImage(url: URL(string: record.image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 150, height: 150)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 4))
                            .shadow(radius: 10)
                            .frame(width: 150, height: 150)
                    case .failure:
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .padding(.top, 20)

                // Name and City
                Text(record.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("City: \(record.city)")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Divider()
                    .padding(.vertical, 10)

                // Contact Information
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                        Text(record.contact.email)
                            .font(.body)
                            .foregroundColor(.primary)
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                        Text(record.contact.phone)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .shadow(radius: 5)

                Spacer()

                // Custom Back Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to List")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        .navigationTitle("Contact Details")
        .navigationBarBackButtonHidden(true) // Hides default back button
    }
}




