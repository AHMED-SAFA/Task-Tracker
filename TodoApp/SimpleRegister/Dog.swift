import SwiftUI

struct Dog: Identifiable {
    var id: String
    var breed: String
    var uid: String
    var reminderTime: Date

    // Initializer
    init(id: String, breed: String, uid: String, reminderTime: Date) {
        self.id = id
        self.breed = breed
        self.uid = uid
        self.reminderTime = reminderTime
    }
}
