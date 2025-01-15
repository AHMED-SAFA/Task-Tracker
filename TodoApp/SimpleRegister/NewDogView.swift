import SwiftUI

struct NewDogView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) var dismiss
    @State private var newDog: String = ""
    @State private var taskDate = Date()
    @State private var showToast = false
    var isEditing: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Cross Button to Close Sheet
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                                .padding(.leading, 20)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)

                    // Title
                    Text(isEditing ? "Edit Activity" : "Add Activity")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    Spacer()

                    // Activity Name Field
                    VStack(alignment: .leading) {
                        Text("Activity Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        TextField("Enter Activity", text: $newDog)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .autocapitalization(.words)
                            .padding(.bottom, 20)
                    }

                    // Task Date and Time Picker
                    VStack(alignment: .leading) {
                        Text("Task Date and Time")
                            .font(.headline)
                            .foregroundColor(.primary)

                        DatePicker(
                            "Select Date and Time",
                            selection: $taskDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.bottom, 40)
                    }

                    // Save or Update Button
                    Button(action: {
                        if taskDate < Date() {
                            showToast = true
                        } else {
                            let formattedDate = formattedDate(taskDate)
                            if isEditing, let dog = dataManager.selectedDog {
                                dataManager.updateDog(dog: dog, newBreed: newDog, newId: formattedDate, reminderTime: taskDate)
                            } else {
                                dataManager.addDog(dogBreed: newDog, dogId: formattedDate, reminderTime: taskDate)
                            }
                            dismiss()
                        }
                    }) {
                        Text(isEditing ? "Update Activity" : "Save Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
                .navigationBarTitleDisplayMode(.inline)
                .toast(isPresented: $showToast) {
                    AnyView(
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Cannot select a past date or time.")
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    )
                }
            }
            .onAppear {
                if isEditing, let dog = dataManager.selectedDog {
                    newDog = dog.breed
                }
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    func sendReminder(time: Date) {
        print("Reminder set for: \(formattedDate(time))")
    }
}

// Toast View Modifier
extension View {
    func toast(isPresented: Binding<Bool>, content: @escaping () -> AnyView) -> some View {
        ZStack {
            self
            if isPresented.wrappedValue {
                content()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isPresented.wrappedValue = false
                        }
                    }
            }
        }
    }
}
