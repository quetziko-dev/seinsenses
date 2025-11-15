import Foundation
import HealthKit

// MARK: - Sleep Service Protocol
protocol SleepServiceProtocol {
    func requestAuthorization() async throws
    func fetchLastNightSleep() async throws -> SleepData?
    func isHealthKitAvailable() -> Bool
}

// MARK: - Sleep Service Implementation
@MainActor
final class SleepService: SleepServiceProtocol {
    static let shared = SleepService()
    
    private let healthStore: HKHealthStore?
    private let sleepType: HKCategoryType?
    
    private init() {
        // Check if HealthKit is available on this device
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
            self.sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
        } else {
            self.healthStore = nil
            self.sleepType = nil
            print("⚠️ HealthKit no está disponible en este dispositivo")
        }
    }
    
    // MARK: - Public Methods
    
    /// Check if HealthKit is available
    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    /// Request authorization to read sleep data from HealthKit
    /// ⚠️ IMPORTANTE: Solo solicitamos permisos de LECTURA para análisis de sueño.
    /// NO accedemos a "última vez que usó el teléfono" ni Screen Time porque iOS
    /// no ofrece una API pública confiable para eso.
    func requestAuthorization() async throws {
        guard let healthStore = healthStore,
              let sleepType = sleepType else {
            throw SleepServiceError.healthKitNotAvailable
        }
        
        // Solo solicitar permiso de lectura para sleep analysis
        let typesToRead: Set<HKObjectType> = [sleepType]
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    print("✅ Permiso de HealthKit concedido para lectura de sueño")
                    continuation.resume()
                } else {
                    continuation.resume(throwing: SleepServiceError.authorizationDenied)
                }
            }
        }
    }
    
    /// Fetch sleep data from last night
    /// Si HealthKit tiene datos, los devuelve con source = .healthKit
    /// Si no hay datos o falla, devuelve nil (el caller debe usar entrada manual como fallback)
    func fetchLastNightSleep() async throws -> SleepData? {
        guard let healthStore = healthStore,
              let sleepType = sleepType else {
            print("⚠️ HealthKit no disponible, usar entrada manual")
            return nil
        }
        
        // Define el rango de tiempo: desde las 6 PM de ayer hasta las 2 PM de hoy
        let calendar = Calendar.current
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        
        let startOfLastNight = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: yesterday)!
        let endOfThisMorning = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)!
        
        // Create predicate for the query
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfLastNight,
            end: endOfThisMorning,
            options: .strictStartDate
        )
        
        // Sort by start date
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                
                if let error = error {
                    print("❌ Error al leer datos de sueño de HealthKit: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let samples = samples as? [HKCategorySample], !samples.isEmpty else {
                    print("⚠️ No hay datos de sueño en HealthKit para la última noche")
                    continuation.resume(returning: nil)
                    return
                }
                
                // Filter for "inBed" or "asleep" samples
                let sleepSamples = samples.filter { sample in
                    let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)
                    return value == .asleep || value == .inBed
                }
                
                guard !sleepSamples.isEmpty else {
                    print("⚠️ No hay muestras de sueño válidas")
                    continuation.resume(returning: nil)
                    return
                }
                
                // Find earliest bedtime and latest wake time
                let bedTime = sleepSamples.map { $0.startDate }.min() ?? Date()
                let wakeTime = sleepSamples.map { $0.endDate }.max() ?? Date()
                
                // Estimate quality based on total hours
                let totalHours = wakeTime.timeIntervalSince(bedTime) / 3600
                let quality = self.estimateQuality(from: totalHours)
                
                // Create SleepData with healthKit source
                let sleepData = SleepData(
                    bedTime: bedTime,
                    wakeTime: wakeTime,
                    quality: quality,
                    notes: "Datos sincronizados desde Salud",
                    source: .healthKit
                )
                
                print("✅ Datos de sueño obtenidos de HealthKit: \(totalHours) horas")
                continuation.resume(returning: sleepData)
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Private Helpers
    
    /// Estimate sleep quality based on total hours
    /// Optimal sleep: 7-9 hours
    private func estimateQuality(from hours: Double) -> SleepQuality {
        switch hours {
        case 7.5...9:
            return .excellent
        case 6.5..<7.5, 9..<10:
            return .good
        case 5.5..<6.5, 10..<11:
            return .fair
        default:
            return .poor
        }
    }
}

// MARK: - Errors
enum SleepServiceError: LocalizedError {
    case healthKitNotAvailable
    case authorizationDenied
    case noDataAvailable
    
    var errorDescription: String? {
        switch self {
        case .healthKitNotAvailable:
            return "HealthKit no está disponible en este dispositivo"
        case .authorizationDenied:
            return "Permiso de HealthKit denegado. Ve a Configuración para activarlo."
        case .noDataAvailable:
            return "No hay datos de sueño disponibles"
        }
    }
}
