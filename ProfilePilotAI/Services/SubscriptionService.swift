import Foundation
import StoreKit
import UserNotifications

@MainActor
final class SubscriptionService: ObservableObject {
    @Published var products: [Product] = []
    @Published var currentPlan: SubscriptionPlan = .free
    @Published var isActive = false

    private let productIDs = [
        "profilepilot.professional.monthly",
        "profilepilot.professional.yearly",
        "profilepilot.accelerator.monthly"
    ]

    func loadProducts() async {
        products = (try? await Product.products(for: productIDs)) ?? []
    }

    func purchasePlaceholder(_ plan: SubscriptionPlan) {
        currentPlan = plan
        isActive = plan != .free
    }
}

@MainActor
final class LocalNotificationService {
    func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    func scheduleInterviewReminder(title: String, date: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "ProfilePilot AI"
        content.body = title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
