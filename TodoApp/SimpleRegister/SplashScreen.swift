//import SwiftUI
//
//struct SplashScreen: View {
//    @EnvironmentObject var dataManager: DataManager
//    
//    @State private var isActive = false
//    
//    var body: some View {
//        ZStack {
//            Color.blue
//                .ignoresSafeArea()
//            
//            VStack {
//                Image(systemName: "pawprint.fill")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.white)
//                
//                Text("Welcome to ReminderApp")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                    .padding(.top, 20)
//            }
//        }
//        .onAppear {
//            // Start a timer to navigate after 3 seconds
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                isActive = true
//            }
//        }
//        // Navigate to ContentView after 3 seconds
//        .background(
//            NavigationLink(destination: ContentView(), isActive: $isActive) {
//                EmptyView()
//            }
//                .hidden()
//        )
//        .fullScreenCover(isPresented: $isActive) {
//           // ContentView()
//               // .environmentObject(dataManager)  // Pass DataManager to ContentView
//        }
//    }
//    
//    struct SplashScreen_Previews: PreviewProvider {
//        static var previews: some View {
//            SplashScreen()
//        }
//    }
//}
//




// SplashScreen.swift
import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var isActive = false
    @State private var imageOffset = CGSize(width: 0, height: -300) // Start position off-screen
    @State private var imageOpacity = 0.0 // Start with opacity 0
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            VStack {
                // Your image here
                Image("sp") // Refer to the image name in the Assets folder without extension
                    .resizable()
                    .scaledToFit()
                    .frame(width:300, height:200)
                    .offset(imageOffset)
                    .opacity(imageOpacity)
                    .onAppear {
                        
                        print("image loaded")
                        // Animate the image coming from the top
                        withAnimation(.easeOut(duration: 1.5)) {
                            imageOffset = CGSize(width: 0, height: 0)
                            imageOpacity = 1.0
                        }
                    }

            }
        }
        .onAppear {
            // Start a timer to navigate after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isActive = true
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            NavigationView {
                ContentView()
                    .environmentObject(dataManager)
            }
        }
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
            .environmentObject(DataManager())
    }
}



