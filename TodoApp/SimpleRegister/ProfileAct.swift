//
//  ProfileAct.swift
//  SimpleRegister
//
//  Created by s m shible sadik on 16/1/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage

 



struct ProfileAct: View {
    @StateObject private var profileManager = ProfileManager()
    @State private var showingImagePicker = false // To show the image picker
    @State private var inputImage: UIImage? = nil // Selected image from picker

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    ZStack {
                        if let profileImage = profileManager.profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                        .frame(width: 80, height: 80)
                                )
                                .shadow(radius: 5)
                        }

                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Circle()
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                )
                                .offset(x: 40, y: 40)
                        }
                    }
                    .padding(.top)

                    // Name Field
                    VStack(alignment: .leading) {
                        Text("Name")
                            .font(.headline)
                        TextField("Enter your name", text: $profileManager.name)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }

                    // Email Field (Read-only)
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.headline)
                        TextField("Email", text: .constant(Auth.auth().currentUser?.email ?? "Unknown Email"))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .disabled(true) // Read-only
                    }

                    // Contact Number Field
                    VStack(alignment: .leading) {
                        Text("Contact Number")
                            .font(.headline)
                        TextField("Enter your contact number", text: $profileManager.contactNumber)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .keyboardType(.numberPad)
                    }

                    // Hobby Field
                    VStack(alignment: .leading) {
                        Text("Hobby")
                            .font(.headline)
                        TextField("Enter your hobbies", text: $profileManager.hobby)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }

                    // Save Button
                    Button(action: profileManager.saveProfile) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top)

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .onAppear {
                profileManager.fetchProfile()
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
        }
    }

    // Load image from image picker
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        profileManager.profileImage = inputImage
    }
}


struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}







class ProfileManager: ObservableObject {
    @Published var name: String = ""
    @Published var contactNumber: String = ""
    @Published var hobby: String = ""
    @Published var profileImage: UIImage? = nil

    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let userId = Auth.auth().currentUser?.uid ?? "unknown_user"
    @State private var toastMessage: String? = nil
    @State private var showToast = false


    // Save the profile data to Firestore
    func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        if let profileImage = profileImage {
            // Upload image to Firebase Storage
            uploadImage(profileImage) { [weak self] imageURL in
                guard let self = self else { return }
                let profileData: [String: Any] = [
                    "name": self.name,
                    "contactNumber": self.contactNumber,
                    "hobby": self.hobby,
                    "profileImageURL": imageURL ?? "" // Store the image URL
                ]

                self.db.collection("info").document(userId).setData(profileData) { error in
                    if let error = error {
                        print("Error saving profile: \(error.localizedDescription)")
                    } else {
                        print("Profile saved successfully.")
                        DispatchQueue.main.async {
                            // Trigger the toast message after saving the profile
                            self.showToastMessage("Profile saved successfully!")
                        }
                    }
                }
            }
        } else {
            // Save profile without image
            let profileData: [String: Any] = [
                "name": name,
                "contactNumber": contactNumber,
                "hobby": hobby,
                "profileImageURL": "" // Empty if no image
            ]

            db.collection("info").document(userId).setData(profileData) { error in
                if let error = error {
                    print("Error saving profile: \(error.localizedDescription)")
                } else {
                    print("Profile saved successfully.")
                    DispatchQueue.main.async {
                        // Trigger the toast message after saving the profile
                        self.showToastMessage("Profile saved successfully!")
                    }
                }
            }
        }
    }

    // Show the toast message function
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.showToast = false
        }
    }


    // Fetch the profile data from Firestore
    func fetchProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        db.collection("info").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching profile: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("No profile data found.")
                return
            }

            // Update fields with data from Firestore
            self.name = data["name"] as? String ?? ""
            self.contactNumber = data["contactNumber"] as? String ?? ""
            self.hobby = data["hobby"] as? String ?? ""

            if let imageURL = data["profileImageURL"] as? String, !imageURL.isEmpty {
                self.downloadImage(from: imageURL) { image in
                    self.profileImage = image
                }
            }
        }
    }

    // Upload image to Firebase Storage
    private func uploadImage(_ image: UIImage, completion: @escaping (String?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            completion(nil)
            return
        }

        let storageRef = storage.reference().child("profileImages/\(userId).jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to compress image.")
            completion(nil)
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting image URL: \(error.localizedDescription)")
                        completion(nil)
                    } else {
                        completion(url?.absoluteString)
                    }
                }
            }
        }
    }

    // Download image from Firebase Storage
    private func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error downloading image: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}














