import SwiftUI
import SwiftData

struct SleepTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @StateObject private var viewModel = SleepViewModel()
    
    private var currentUser: User? {
        users.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    welcomeSection
                    
                    // Sleep Circle/Chart
                    if let sleep = viewModel.sleepData {
                        sleepCircleSection(sleep: sleep)
                    } else {
                        noDataSection
                    }
                    
                    // Manual Entry if needed
                    if viewModel.showManualEntry {
                        manualEntrySection
                    }
                    
                    // Sleep History
                    if let user = currentUser, !user.sleepData.isEmpty {
                        sleepHistorySection(sleepData: user.sleepData)
                    }
                }
                .padding()
            }
            .background(Color.themeLightAqua)
            .navigationTitle("Seguimiento de Sueño")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadSleepData()
            }
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tu Descanso")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.themePrimaryDarkGreen)
            
            Text("El sueño de calidad es fundamental para tu bienestar")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func sleepCircleSection(sleep: SleepData) -> some View {
        VStack(spacing: 16) {
            // Source indicator
            HStack {
                Image(systemName: sleep.source == .healthKit ? "heart.fill" : "hand.raised.fill")
                    .foregroundColor(sleep.source == .healthKit ? .red : .themeTeal)
                Text(sleep.source.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Sleep circle
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: min(sleep.totalHours / 9.0, 1.0))
                    .stroke(
                        Color(hex: sleep.quality.color),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(sleep.totalHours, specifier: "%.1f")")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("horas")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Sleep times
            HStack(spacing: 40) {
                VStack {
                    Image(systemName: "moon.fill")
                        .font(.title2)
                        .foregroundColor(.themeTeal)
                    Text("Dormir")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(sleep.bedTime, style: .time)
                        .font(.headline)
                }
                
                VStack {
                    Image(systemName: "sun.max.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text("Despertar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(sleep.wakeTime, style: .time)
                        .font(.headline)
                }
            }
            
            // Quality badge
            HStack {
                Circle()
                    .fill(Color(hex: sleep.quality.color))
                    .frame(width: 12, height: 12)
                Text("Calidad: \(sleep.quality.rawValue)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var noDataSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.zzz")
                .font(.system(size: 60))
                .foregroundColor(.themeTeal.opacity(0.5))
            
            Text("Sin datos de sueño")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var manualEntrySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Registrar Sueño Manualmente")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            Text("No pudimos leer datos desde Salud. Ingresa tu hora de dormir y despertar.")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Bed time picker
            HStack {
                Image(systemName: "moon.fill")
                    .foregroundColor(.themeTeal)
                Text("Hora de dormir:")
                Spacer()
                DatePicker("", selection: $viewModel.manualBedTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
            
            // Wake time picker
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.orange)
                Text("Hora de despertar:")
                Spacer()
                DatePicker("", selection: $viewModel.manualWakeTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
            
            // Quality picker
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("Calidad:")
                Spacer()
                Picker("", selection: $viewModel.manualQuality) {
                    ForEach(SleepQuality.allCases, id: \.self) { quality in
                        Text(quality.rawValue).tag(quality)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // Save button
            Button(action: {
                viewModel.saveManualSleep(context: modelContext, user: currentUser)
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Guardar Registro")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeTeal)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func sleepHistorySection(sleepData: [SleepData]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Historial de Sueño")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            ForEach(sleepData.prefix(7).sorted(by: { $0.date > $1.date })) { sleep in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sleep.date, style: .date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 8) {
                            Image(systemName: sleep.source == .healthKit ? "heart.fill" : "hand.raised.fill")
                                .font(.caption2)
                            Text("\(sleep.totalHours, specifier: "%.1f")h")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color(hex: sleep.quality.color))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(sleep.quality.rawValue.prefix(1).uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                }
                .padding(.vertical, 8)
                
                if sleep.id != sleepData.prefix(7).sorted(by: { $0.date > $1.date }).last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - ViewModel
@MainActor
class SleepViewModel: ObservableObject {
    @Published var sleepData: SleepData?
    @Published var showManualEntry = false
    @Published var healthKitAvailable = false
    @Published var errorMessage: String?
    
    @Published var manualBedTime = Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var manualWakeTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()) ?? Date()
    @Published var manualQuality: SleepQuality = .good
    
    private let sleepService = SleepService.shared
    
    func loadSleepData() async {
        // Check if HealthKit is available
        healthKitAvailable = sleepService.isHealthKitAvailable()
        
        guard healthKitAvailable else {
            showManualEntry = true
            errorMessage = "HealthKit no disponible. Usa entrada manual."
            return
        }
        
        do {
            // Request authorization
            try await sleepService.requestAuthorization()
            
            // Try to fetch data from HealthKit
            if let healthKitSleep = try await sleepService.fetchLastNightSleep() {
                sleepData = healthKitSleep
                showManualEntry = false
            } else {
                // No data in HealthKit, show manual entry
                showManualEntry = true
                errorMessage = "No hay datos de sueño en Salud. Regístralos manualmente."
            }
        } catch {
            showManualEntry = true
            errorMessage = error.localizedDescription
        }
    }
    
    func saveManualSleep(context: ModelContext, user: User?) {
        guard let user = user else { return }
        
        // Ensure wake time is after bed time
        if manualWakeTime <= manualBedTime {
            manualWakeTime = Calendar.current.date(byAdding: .hour, value: 8, to: manualBedTime) ?? manualWakeTime
        }
        
        let manualSleep = SleepData(
            bedTime: manualBedTime,
            wakeTime: manualWakeTime,
            quality: manualQuality,
            notes: "Registro manual",
            source: .manual
        )
        
        user.sleepData.append(manualSleep)
        
        do {
            try context.save()
            sleepData = manualSleep
            showManualEntry = false
            print("✅ Sueño manual guardado")
        } catch {
            errorMessage = "Error al guardar: \(error.localizedDescription)"
        }
    }
}

#Preview {
    SleepTrackingView()
}
