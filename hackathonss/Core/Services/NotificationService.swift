import Foundation
import UserNotifications

// MARK: - Notification Service Protocol
protocol NotificationServiceProtocol {
    func requestPermissions() async -> Bool
    func scheduleWellnessReminder(time: Date, title: String, body: String) async throws
    func schedulePantherReminder(type: PantherReminderType) async throws
    func cancelAllNotifications() async
    func getPendingNotifications() async -> [UNNotificationRequest]
}

// MARK: - Panther Reminder Types
enum PantherReminderType: String, CaseIterable {
    case morningCheckIn = "revisión matutina"
    case eveningReflection = "reflexión nocturna"
    case activityReminder = "recordatorio de actividad"
    case pantherCare = "cuidado de pantera"
    case weeklyProgress = "progreso semanal"
    
    var defaultTitle: String {
        switch self {
        case .morningCheckIn:
            return "¡Buenos días! Tu pantera te espera"
        case .eveningReflection:
            return "Hora de reflexionar con tu pantera"
        case .activityReminder:
            return "Tu pantera quiere moverse"
        case .pantherCare:
            return "Tu pantera necesita tu atención"
        case .weeklyProgress:
            return "Revisa tu progreso semanal"
        }
    }
    
    var defaultBody: String {
        switch self {
        case .morningCheckIn:
            return "Comienza el día registrando cómo te sientes"
        case .eveningReflection:
            return "Termina el día con una reflexión emocional"
        case .activityReminder:
            return "Es momento de hacer alguna actividad física"
        case .pantherCare:
            return "Tu compañera pantera extraña tu atención"
        case .weeklyProgress:
            return "Ve todo lo que has logrado esta semana"
        }
    }
    
    var defaultTime: DateComponents {
        switch self {
        case .morningCheckIn:
            return DateComponents(hour: 9, minute: 0)
        case .eveningReflection:
            return DateComponents(hour: 20, minute: 0)
        case .activityReminder:
            return DateComponents(hour: 17, minute: 0)
        case .pantherCare:
            return DateComponents(hour: 12, minute: 0)
        case .weeklyProgress:
            return DateComponents(hour: 10, minute: 0, weekday: 1) // Monday 10 AM
        }
    }
}

// MARK: - Notification Service Implementation
class NotificationService: NSObject, NotificationServiceProtocol, ObservableObject {
    static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        setupNotificationCategories()
    }
    
    // MARK: - Permission Management
    func requestPermissions() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("Error requesting notification permissions: \(error)")
            await MainActor.run {
                self.isAuthorized = false
            }
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    // MARK: - Scheduling Methods
    func scheduleWellnessReminder(time: Date, title: String, body: String) async throws {
        guard isAuthorized else {
            throw NotificationError.notAuthorized
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "WELLNESS_REMINDER"
        content.userInfo = ["type": "wellness"]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "wellness_reminder_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
        await refreshPendingNotifications()
    }
    
    func schedulePantherReminder(type: PantherReminderType) async throws {
        guard isAuthorized else {
            throw NotificationError.notAuthorized
        }
        
        let content = UNMutableNotificationContent()
        content.title = type.defaultTitle
        content.body = type.defaultBody
        content.sound = .default
        content.categoryIdentifier = "PANTHER_REMINDER"
        content.userInfo = ["type": type.rawValue]
        
        // Add panther emoji for visual appeal
        content.title = "🐾 \(content.title)"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: type.defaultTime, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "panther_\(type.rawValue)",
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
        await refreshPendingNotifications()
    }
    
    func scheduleOneTimeReminder(title: String, body: String, timeInterval: TimeInterval) async throws {
        guard isAuthorized else {
            throw NotificationError.notAuthorized
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "ONE_TIME_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "one_time_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
        await refreshPendingNotifications()
    }
    
    func scheduleProgressReminder(userProgress: PantherProgress) async throws {
        guard isAuthorized else {
            throw NotificationError.notAuthorized
        }
        
        let content = UNMutableNotificationContent()
        
        if userProgress.experiencePoints >= userProgress.experienceToNextLevel - 20 {
            content.title = "🐾 ¡Casi nivel superior!"
            content.body = "Solo faltan \(userProgress.experienceToNextLevel - userProgress.experiencePoints) puntos para que tu pantera evolucione"
        } else if userProgress.consecutiveDays >= 7 {
            content.title = "🐾 ¡Increíble racha!"
            content.body = "Llevas \(userProgress.consecutiveDays) días seguidos de bienestar. ¡Sigue así!"
        } else {
            content.title = "🐾 Tu pantera te extraña"
            content.body = "Haz alguna actividad de bienestar para hacer feliz a tu compañera"
        }
        
        content.sound = .default
        content.categoryIdentifier = "PROGRESS_REMINDER"
        content.userInfo = ["type": "progress"]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 18, minute: 0), repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "progress_reminder",
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
        await refreshPendingNotifications()
    }
    
    // MARK: - Management Methods
    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        await refreshPendingNotifications()
    }
    
    func cancelNotification(withIdentifier identifier: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        await refreshPendingNotifications()
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    @MainActor
    private func refreshPendingNotifications() async {
        pendingNotifications = await notificationCenter.pendingNotificationRequests()
    }
    
    // MARK: - Notification Categories
    private func setupNotificationCategories() {
        let wellnessCategory = UNNotificationCategory(
            identifier: "WELLNESS_REMINDER",
            actions: [
                UNNotificationAction(identifier: "REGISTER_EMOTION", title: "Registrar Emoción"),
                UNNotificationAction(identifier: "START_ACTIVITY", title: "Iniciar Actividad")
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let pantherCategory = UNNotificationCategory(
            identifier: "PANTHER_REMINDER",
            actions: [
                UNNotificationAction(identifier: "CHECK_PANTHER", title: "Ver Panthera"),
                UNNotificationAction(identifier: "FEED_PANTHER", title: "Alimentar Panthera")
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let progressCategory = UNNotificationCategory(
            identifier: "PROGRESS_REMINDER",
            actions: [
                UNNotificationAction(identifier: "VIEW_PROGRESS", title: "Ver Progreso"),
                UNNotificationAction(identifier: "ADD_ACTIVITY", title: "Agregar Actividad")
            ],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([
            wellnessCategory,
            pantherCategory,
            progressCategory
        ])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        handleNotificationAction(response)
        completionHandler()
    }
    
    private func handleNotificationAction(_ response: UNNotificationResponse) {
        let identifier = response.actionIdentifier
        let request = response.notification.request
        let userInfo = request.content.userInfo
        
        print("Notification action: \(identifier)")
        print("User info: \(userInfo)")
        
        // Handle different notification actions
        switch identifier {
        case "REGISTER_EMOTION":
            NotificationCenter.default.post(name: .registerEmotionTapped, object: nil)
        case "START_ACTIVITY":
            NotificationCenter.default.post(name: .startActivityTapped, object: nil)
        case "CHECK_PANTHER":
            NotificationCenter.default.post(name: .checkPantherTapped, object: nil)
        case "FEED_PANTHER":
            NotificationCenter.default.post(name: .feedPantherTapped, object: nil)
        case "VIEW_PROGRESS":
            NotificationCenter.default.post(name: .viewProgressTapped, object: nil)
        case "ADD_ACTIVITY":
            NotificationCenter.default.post(name: .addActivityTapped, object: nil)
        default:
            break
        }
    }
}

// MARK: - Notification Error
enum NotificationError: Error, LocalizedError {
    case notAuthorized
    case schedulingFailed
    case invalidTime
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "No se han autorizado las notificaciones"
        case .schedulingFailed:
            return "Error al programar la notificación"
        case .invalidTime:
            return "Tiempo de notificación inválido"
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let registerEmotionTapped = Notification.Name("registerEmotionTapped")
    static let startActivityTapped = Notification.Name("startActivityTapped")
    static let checkPantherTapped = Notification.Name("checkPantherTapped")
    static let feedPantherTapped = Notification.Name("feedPantherTapped")
    static let viewProgressTapped = Notification.Name("viewProgressTapped")
    static let addActivityTapped = Notification.Name("addActivityTapped")
}

// MARK: - Mock Notification Service for Testing
class MockNotificationService: NotificationServiceProtocol {
    @Published var isAuthorized = true
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    func requestPermissions() async -> Bool {
        return true
    }
    
    func scheduleWellnessReminder(time: Date, title: String, body: String) async throws {
        print("Mock: Scheduled wellness reminder - \(title): \(body)")
    }
    
    func schedulePantherReminder(type: PantherReminderType) async throws {
        print("Mock: Scheduled panther reminder - \(type.rawValue)")
    }
    
    func cancelAllNotifications() async {
        print("Mock: Cancelled all notifications")
        pendingNotifications.removeAll()
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return pendingNotifications
    }
}
