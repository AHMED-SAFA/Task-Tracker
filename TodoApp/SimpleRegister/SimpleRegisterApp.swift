//import SwiftUI
//import Firebase
//
//@main
//struct SimpleRegisterApp: App {
//    @StateObject var dataManager = DataManager()  // Initialize DataManager
//
//    init() {
//        FirebaseApp.configure()  // Configure Firebase
//    }
//
//    var body: some Scene {
//        WindowGroup {
//            NavigationView {
//                ContentView()
//            
//                 .environmentObject(dataManager)  // Inject DataManager into the environment
//            }
//        }
//    }
//}
//



// SimpleRegisterApp.swift
import SwiftUI
import Firebase

@main
struct SimpleRegisterApp: App {
    @StateObject var dataManager = DataManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(dataManager)
        }
    }
}
