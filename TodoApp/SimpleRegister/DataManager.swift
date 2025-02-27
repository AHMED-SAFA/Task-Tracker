import SwiftUI
import Firebase
import FirebaseAuth
import UserNotifications


class DataManager: ObservableObject {
    @Published var dogs: [Dog] = []  // This is the array of dogs
    @Published var selectedDog: Dog? = nil
    
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    
//    for notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }


    // Initialization: Set up an Auth state change listener
    init() {
        // Set up an Auth state change listener to fetch dogs when the user logs in or logs out
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                // Fetch dogs when a user logs in
                self?.fetchDogs()
            } else {
                // Clear dogs when the user logs out
                self?.dogs.removeAll()
            }
        }
    }

    // De-initialization: Remove listener when DataManager is deallocated
    deinit {
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // Fetch dogs for the current logged-in user
    func fetchDogs() {
        dogs.removeAll()
        
        // Get the current authenticated user UID
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }

        // Access Firestore database
        let db = Firestore.firestore()
        
        // Query the "Dogs" collection where the document's UID matches the current user's UID
        let ref = db.collection("Dogs").whereField("uid", isEqualTo: currentUserUID)
        
        ref.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching dogs: \(error.localizedDescription)")
                return
            }
            
            // Process the fetched data
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let data = document.data()
                    let dogId = data["id"] as? String ?? ""
                    let breed = data["breed"] as? String ?? ""
                    let uid = data["uid"] as? String ?? ""
                    let reminderTime = (data["reminderTime"] as? Timestamp)?.dateValue() ?? Date()
                    let dog = Dog(id: dogId, breed: breed, uid: uid, reminderTime: reminderTime)
                    self.dogs.append(dog)
                }
            }
        }
    }

    // Add a new dog to Firestore
    func addDog(dogBreed: String, dogId: String, reminderTime: Date) {
        // Get the current authenticated user UID
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("No user is logged in.")
            return
        }

        // Access Firestore database
        let db = Firestore.firestore()

        // Generate a unique ID for the new dog
        let uniqueId = UUID().uuidString
        let ref = db.collection("Dogs").document(uniqueId)
        
        // Set data for the new dog
        ref.setData([
            "breed": dogBreed,
            "id": dogId,
            "uid": currentUserUID, // Add the current user's UID here
            "reminderTime": Timestamp(date: reminderTime) // Store reminder time
        ]) { error in
            if let error = error {
                print("Error adding dog: \(error.localizedDescription)")
            } else {
                print("Dog added successfully")
                self.fetchDogs()  // Refresh the list of dogs
            }
        }
    }

    // Update an existing dog's data
    func updateDog(dog: Dog, newBreed: String, newId: String, reminderTime: Date) {
        let db = Firestore.firestore()
        
        // Find the document with the matching dog ID
        let ref = db.collection("Dogs").whereField("id", isEqualTo: dog.id).limit(to: 1)
        
        ref.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching document to update: \(error.localizedDescription)")
                return
            }
            
            // Update the document if it exists
            if let snapshot = snapshot, let document = snapshot.documents.first {
                document.reference.updateData([
                    "breed": newBreed,
                    "id": newId,
                    "reminderTime": Timestamp(date: reminderTime) // Update reminder time
                ]) { error in
                    if let error = error {
                        print("Error updating dog: \(error.localizedDescription)")
                    } else {
                        print("Dog updated successfully")
                        self.fetchDogs()  // Refresh the list of dogs
                    }
                }
            }
        }
    }

    // Delete a dog from Firestore
    func deleteDog(_ dog: Dog) {
        let db = Firestore.firestore()
        
        // Find the document with the matching dog ID
        let ref = db.collection("Dogs").whereField("id", isEqualTo: dog.id).limit(to: 1)

        ref.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching document to delete: \(error.localizedDescription)")
                return
            }

            // Delete the document if it exists
            if let snapshot = snapshot, !snapshot.isEmpty {
                if let document = snapshot.documents.first {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting dog: \(error.localizedDescription)")
                        } else {
                            print("Dog deleted successfully")
                            DispatchQueue.main.async {
                                // Remove dog from local array
                                if let index = self.dogs.firstIndex(where: { $0.id == dog.id }) {
                                    self.dogs.remove(at: index)
                                }
                            }
                        }
                    }
                }
            } else {
                print("No document found for the specified dog id")
            }
        }
    }
}
