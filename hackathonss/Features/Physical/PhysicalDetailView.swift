import SwiftUI
import SwiftData

struct PhysicalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var users: [User]
    @State private var currentUser: User?
    
    @State private var height: String = ""
    @State private var weight: String = ""
    @State private var weeklyGoal: Int = 5
    
    @State private var selectedActivityType: ActivityType = .walking
    @State private var activityDuration: String = ""
    @State private var caloriesBurned: String = ""
    
    @State private var isShowingAddActivity = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Physical Data Setup
                    physicalDataSection
                    
                    // Add Activity Section
                    addActivitySection
                    
                    // Recent Activities
                    if let user = currentUser, let physicalData = user.physicalData {
                        recentActivitiesSection(physicalData: physicalData)
                    }
                }
                .padding()
            }
            .background(Color.themeLightAqua)
            .navigationTitle("Configuración Física")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.themeTeal)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Guardar") {
                        savePhysicalData()
                    }
                    .fontWeight(.medium)
                    .foregroundColor(.themeTeal)
                }
            }
            .onAppear {
                setupCurrentUser()
                loadExistingData()
            }
        }
    }
    
    private var physicalDataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Datos Físicos")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Altura (cm)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("170", text: $height)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Peso (kg)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    TextField("70", text: $weight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meta de actividad semanal (días)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Stepper("\(weeklyGoal) días", value: $weeklyGoal, in: 1...7)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var addActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Agregar Actividad")
                    .font(.headline)
                    .foregroundColor(.themePrimaryDarkGreen)
                
                Spacer()
                
                Button(action: {
                    isShowingAddActivity.toggle()
                }) {
                    Image(systemName: isShowingAddActivity ? "chevron.up" : "chevron.down")
                        .foregroundColor(.themeTeal)
                }
            }
            
            if isShowingAddActivity {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tipo de actividad")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Picker("Tipo", selection: $selectedActivityType) {
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Duración (minutos)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        TextField("30", text: $activityDuration)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Calorías quemadas (opcional)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        TextField("200", text: $caloriesBurned)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }
                    
                    Button("Agregar Actividad") {
                        addActivity()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func recentActivitiesSection(physicalData: PhysicalData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actividades de Hoy")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            let todayActivities = physicalData.activities.filter { 
                Calendar.current.isDateInToday($0.date) 
            }
            
            if todayActivities.isEmpty {
                Text("No hay actividades registradas hoy")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(todayActivities.sorted { $0.date > $1.date }, id: \.id) { activity in
                        ActivityRow(activity: activity)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func setupCurrentUser() {
        if users.isEmpty {
            // Use registered name from AuthenticationManager, fallback to "Usuario"
            let userName = AuthenticationManager.shared.registeredUserName ?? "Usuario"
            let newUser = User(name: userName)
            modelContext.insert(newUser)
            currentUser = newUser
        } else {
            currentUser = users.first
        }
    }
    
    private func loadExistingData() {
        guard let user = currentUser, let physicalData = user.physicalData else { return }
        
        height = String(format: "%.1f", physicalData.height)
        weight = String(format: "%.1f", physicalData.weight)
        weeklyGoal = physicalData.weeklyGoal
    }
    
    private func savePhysicalData() {
        guard let user = currentUser else { return }
        
        let heightValue = Double(height) ?? 170
        let weightValue = Double(weight) ?? 70
        
        if user.physicalData == nil {
            user.physicalData = PhysicalData(
                height: heightValue,
                weight: weightValue,
                weeklyGoal: weeklyGoal
            )
        } else {
            user.physicalData?.height = heightValue
            user.physicalData?.weight = weightValue
            user.physicalData?.weeklyGoal = weeklyGoal
            user.physicalData?.lastUpdated = Date()
        }
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving physical data: \(error)")
        }
    }
    
    private func addActivity() {
        guard let user = currentUser,
              let physicalData = user.physicalData,
              let duration = Int(activityDuration),
              duration > 0 else { return }
        
        let calories = Int(caloriesBurned)
        
        let activity = PhysicalActivity(
            type: selectedActivityType,
            duration: duration,
            date: Date(),
            caloriesBurned: calories
        )
        
        physicalData.activities.append(activity)
        
        // Update activity days for this week
        updateActivityDays(physicalData: physicalData)
        
        // Add experience to panther
        user.pantherProgress.addExperience(points: 10)
        user.pantherProgress.updateDailyActivity()
        
        // Clear form
        activityDuration = ""
        caloriesBurned = ""
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving activity: \(error)")
        }
    }
    
    private func updateActivityDays(physicalData: PhysicalData) {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        let uniqueDays = Set(physicalData.activities
            .filter { $0.date >= startOfWeek }
            .map { calendar.startOfDay(for: $0.date) })
        
        physicalData.activityDays = uniqueDays.count
    }
}

#Preview {
    PhysicalDetailView()
        .modelContainer(for: [User.self, PhysicalData.self, PhysicalActivity.self], inMemory: true)
}
