import SwiftUI
import Firebase
import FirebaseAuth

struct ListView: View {
    @Binding var userIsLoggedIn: Bool
    @EnvironmentObject var dataManager: DataManager
    @State private var isActive = false
    @State private var showNewDogView = false
    @State private var isEditing = false
    @State private var searchText: String = ""
    @Environment(\.colorScheme) var colorScheme

    // State variables to store selected font, size, and color for dog.breed
    @State private var selectedFont: String = "Helvetica"
    @State private var fontSize: Int = 20
    @State private var fontColor: Color = .black

    // State variables for sheet visibility
    @State private var showFontSheet = false
    @State private var showSizeSheet = false
    @State private var showColorSheet = false

    var filteredDogs: [Dog] {
        if searchText.isEmpty {
            return dataManager.dogs
        } else {
            return dataManager.dogs.filter { $0.breed.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search by tasks...", text: $searchText)
                    .padding(12)
                    .background(colorScheme == .dark ? .black : .white)
                    .cornerRadius(12)
                    .shadow(color: Color.gray.opacity(0.2), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.top, 20)

                // Buttons to change font, size, and color
                HStack {
                    // Change Font Button
                    Button(action: {
                        showFontSheet.toggle()
                    }) {
                        Text("Font")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Change Font Size Button
                    Button(action: {
                        showSizeSheet.toggle()
                    }) {
                        Text("Size")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Change Font Color Button
                    Button(action: {
                        showColorSheet.toggle()
                    }) {
                        Text("Color")
                            .padding()
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()

                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(filteredDogs, id: \.id) { dog in
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    // Apply custom font, size, and color for breed text
                                    Text(dog.breed)
                                        .font(.custom(selectedFont, size: CGFloat(fontSize)))
                                        .foregroundColor(fontColor) // Use selected color
                                        .fontWeight(.semibold)
                                    
                                    Text("Time: \(dog.id)")
                                        .font(.subheadline)
                                        .foregroundColor(colorScheme == .dark ? .gray : .secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                // Trash Button
                                Button(action: {
                                    dataManager.deleteDog(dog)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.red)
                                        .padding()
                                        .background(Circle().fill(Color.red.opacity(0.1)))
                                        .shadow(radius: 5)
                                }

                                // Edit Button
                                Button(action: {
                                    dataManager.selectedDog = dog
                                    isEditing = true
                                    showNewDogView.toggle()
                                }) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Circle().fill(Color.blue.opacity(0.1)))
                                        .shadow(radius: 5)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(colorScheme == .dark ? Color.gray.opacity(0.8) : Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            }
            .navigationBarTitle("Tasks List", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: logout) {
                    Text("Logout")
                        .font(.body)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .padding(8)
                        .background(Color.red)
                        .cornerRadius(8)
                },
                trailing: HStack {
                    // Add New Button
                    Button(action: {
                        isEditing = false
                        dataManager.selectedDog = nil
                        showNewDogView.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                            Text("Add")
                                .font(.body)
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(8)
                    }

                    // Dark/Light Mode Toggle
                    Button(action: toggleColorScheme) {
                        Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                            .padding(8)
                            .background(Circle().fill(Color.gray.opacity(0.2)))
                            .shadow(radius: 5)
                    }
                }
            )
            .navigationBarTitle("Tasks List", displayMode: .inline)
            .overlay(
                NavigationLink(destination: ProfileAct()) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                        .padding()
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 5)
                        .padding(.bottom, 30)
                        .padding(.trailing, 20)
                },
                alignment: .bottomTrailing
            )

            
            .sheet(isPresented: $showFontSheet) {
                // Font Selection Sheet
                FontSelectionSheet(selectedFont: $selectedFont)
            }
            .sheet(isPresented: $showSizeSheet) {
                // Size Selection Sheet
                SizeSelectionSheet(fontSize: $fontSize)
            }
            .sheet(isPresented: $showColorSheet) {
                // Color Selection Sheet
                ColorSelectionSheet(fontColor: $fontColor)
            }
            .sheet(isPresented: $showNewDogView) {
                NewDogView(isEditing: isEditing)
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            userIsLoggedIn = false
            print("User logged out successfully")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }

    func toggleColorScheme() {
        if colorScheme == .dark {
            UIApplication.shared.windows.first?.rootViewController?.overrideUserInterfaceStyle = .light
        } else {
            UIApplication.shared.windows.first?.rootViewController?.overrideUserInterfaceStyle = .dark
        }
    }
}

struct FontSelectionSheet: View {
    @Binding var selectedFont: String
    @Environment(\.dismiss) var dismiss

    private let fonts: [String] = [
        "Helvetica", "Courier", "Times New Roman", "Verdana", "Georgia",
        "Arial", "Chalkboard SE", "Futura", "Avenir", "Gill Sans"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(fonts, id: \.self) { font in
                        Button(action: {
                            selectedFont = font
                            dismiss()
                        }) {
                            Text(font)
                                .font(.custom(font, size: 20))
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Pick a Font")
        }
    }
}

struct SizeSelectionSheet: View {
    @Binding var fontSize: Int
    @Environment(\.dismiss) var dismiss

    private let sizes: [Int] = [5, 12, 18, 20, 25, 34, 40, 48, 56, 64]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(sizes, id: \.self) { size in
                        Button(action: {
                            fontSize = size
                            dismiss()
                        }) {
                            Text("Size: \(size)")
                                .font(.system(size: CGFloat(size)))
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Pick a Font Size")
        }
    }
}

struct ColorSelectionSheet: View {
    @Binding var fontColor: Color
    @Environment(\.dismiss) var dismiss

    private let colors: [Color] = [
        .black, .red, .blue, .green, .orange, .purple, .gray, .pink, .yellow, .brown
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ForEach(colors, id: \.self) { color in
                        Button(action: {
                            fontColor = color
                            dismiss()
                        }) {
                            HStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .padding(25)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pick a Font Color")
        }
    }
}








