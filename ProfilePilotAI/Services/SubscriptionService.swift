import Foundation
import StoreKit
import UserNotifications

@MainActor
final class SubscriptionService: ObservableObject {
    @Published var products: [Product] = []
    @Published var currentPlan: SubscriptionPlan = .free
    @Published var isActive = false
    @Published var purchasingPlan: SubscriptionPlan?
    @Published var productLoadError: String?

    private let productIDs = SubscriptionPlan.allCases.compactMap(\.productID)

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            productLoadError = nil
        } catch {
            productLoadError = "Plans could not be loaded. Please check your connection and try again."
        }
    }

    func updateEntitlements() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result,
                  let plan = SubscriptionPlan.allCases.first(where: { $0.productID == transaction.productID }) else {
                continue
            }
            currentPlan = plan
            isActive = true
            return
        }
        currentPlan = .free
        isActive = false
    }

    func displayPrice(for plan: SubscriptionPlan) -> String {
        guard let productID = plan.productID,
              let product = products.first(where: { $0.id == productID }) else {
            return plan.price
        }
        return product.displayPrice
    }

    func purchase(_ plan: SubscriptionPlan) async throws -> String? {
        guard let productID = plan.productID else {
            return nil
        }

        purchasingPlan = plan
        defer { purchasingPlan = nil }

        if products.isEmpty {
            await loadProducts()
        }

        guard let product = products.first(where: { $0.id == productID }) else {
            throw PurchaseError.productUnavailable
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw PurchaseError.unverifiedTransaction
            }
            currentPlan = plan
            isActive = true
            await transaction.finish()
            return "\(plan.rawValue) is active."
        case .pending:
            return "Your purchase is pending approval."
        case .userCancelled:
            return nil
        @unknown default:
            throw PurchaseError.unknown
        }
    }
}

enum PurchaseError: LocalizedError {
    case productUnavailable
    case unverifiedTransaction
    case unknown

    var errorDescription: String? {
        switch self {
        case .productUnavailable:
            return "This plan is still connecting to the App Store. Please try again in a moment."
        case .unverifiedTransaction:
            return "The App Store could not verify this purchase. Please try again."
        case .unknown:
            return "The purchase could not be completed. Please try again."
        }
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
