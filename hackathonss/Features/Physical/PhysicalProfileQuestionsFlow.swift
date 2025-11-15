import SwiftUI

struct PhysicalProfileQuestionsFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var goal: FitnessGoal = .generalHealth
    @State private var heightCm = "170"
    @State private var weightKg = "70"
    @State private var age = "30"
    @State private var activityDays = 3
    @State private var sessionDuration = 45
    @State private var workoutLocation = "gym"
    
    let onComplete: (PhysicalProfile) -> Void
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.themeDeepBlue, Color.themeLavender],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: geometry.size.width * CGFloat(currentStep + 1) / 6, height: 4)
                    }
                }
                .frame(height: 4)
                
                // Question content
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer(minLength: 40)
                        
                        questionContent
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(ProfileSecondaryButtonStyle())
                    }
                    
                    Button(action: handleNext) {
                        Text(currentStep < 5 ? "Continuar" : "Generar Plan")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(ProfilePrimaryButtonStyle())
                }
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private var questionContent: some View {
        switch currentStep {
        case 0:
            GoalSelectionView(selected: $goal)
        case 1:
            PhysicalStatsView(heightCm: $heightCm, weightKg: $weightKg, age: $age)
        case 2:
            ActivityDaysView(days: $activityDays)
        case 3:
            SessionDurationView(duration: $sessionDuration)
        case 4:
            WorkoutLocationView(location: $workoutLocation)
        case 5:
            SummaryView(
                goal: goal,
                heightCm: heightCm,
                weightKg: weightKg,
                activityDays: activityDays,
                sessionDuration: sessionDuration,
                workoutLocation: workoutLocation
            )
        default:
            EmptyView()
        }
    }
    
    private func handleNext() {
        if currentStep < 5 {
            withAnimation {
                currentStep += 1
            }
        } else {
            // Create profile and complete
            let profile = PhysicalProfile(
                heightCm: Double(heightCm) ?? 170,
                weightKg: Double(weightKg) ?? 70,
                age: Int(age),
                sex: nil,
                activityDaysPerWeek: activityDays,
                sessionDurationMinutes: sessionDuration,
                workoutLocation: workoutLocation,
                goal: goal
            )
            onComplete(profile)
            dismiss()
        }
    }
}

// MARK: - Question Views
struct GoalSelectionView: View {
    @Binding var selected: FitnessGoal
    
    var body: some View {
        VStack(spacing: 20) {
            Text("¿Cuál es tu objetivo principal?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            ForEach(FitnessGoal.allCases, id: \.self) { goal in
                GoalCard(goal: goal, isSelected: selected == goal) {
                    selected = goal
                }
            }
        }
    }
}

struct GoalCard: View {
    let goal: FitnessGoal
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: goal.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .themeTeal : .white)
                
                Text(goal.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.themeTeal)
                }
            }
            .padding()
            .background(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.themeTeal : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct PhysicalStatsView: View {
    @Binding var heightCm: String
    @Binding var weightKg: String
    @Binding var age: String
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Tus datos físicos")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                DataField(label: "Altura (cm)", value: $heightCm, icon: "ruler")
                DataField(label: "Peso (kg)", value: $weightKg, icon: "scalemass")
                DataField(label: "Edad (años)", value: $age, icon: "calendar")
            }
        }
    }
}

struct DataField: View {
    let label: String
    @Binding var value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                Text(label)
            }
            .font(.subheadline)
            .foregroundColor(.white.opacity(0.8))
            
            TextField("", text: $value)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
    }
}

struct ActivityDaysView: View {
    @Binding var days: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Text("¿Cuántos días puedes entrenar por semana?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Picker("", selection: $days) {
                ForEach(1...7, id: \.self) { day in
                    Text("\(day) día\(day > 1 ? "s" : "")").tag(day)
                }
            }
            .pickerStyle(.wheel)
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

struct SessionDurationView: View {
    @Binding var duration: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Text("¿Cuánto tiempo por sesión?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Picker("", selection: $duration) {
                Text("30 min").tag(30)
                Text("45 min").tag(45)
                Text("60 min").tag(60)
                Text("90 min").tag(90)
            }
            .pickerStyle(.wheel)
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

struct WorkoutLocationView: View {
    @Binding var location: String
    
    var body: some View {
        VStack(spacing: 30) {
            Text("¿Dónde entrenas?")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                LocationCard(title: "Gimnasio", icon: "dumbbell.fill", isSelected: location == "gym") {
                    location = "gym"
                }
                LocationCard(title: "Casa", icon: "house.fill", isSelected: location == "home") {
                    location = "home"
                }
            }
        }
    }
}

struct LocationCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                Text(title)
                    .font(.headline)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct SummaryView: View {
    let goal: FitnessGoal
    let heightCm: String
    let weightKg: String
    let activityDays: Int
    let sessionDuration: Int
    let workoutLocation: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Resumen de tu perfil")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                SummaryRow(label: "Objetivo", value: goal.displayName)
                SummaryRow(label: "Altura", value: "\(heightCm) cm")
                SummaryRow(label: "Peso", value: "\(weightKg) kg")
                SummaryRow(label: "Días/semana", value: "\(activityDays)")
                SummaryRow(label: "Duración", value: "\(sessionDuration) min")
                SummaryRow(label: "Lugar", value: workoutLocation == "gym" ? "Gimnasio" : "Casa")
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            
            Text("¡Listo! Generaremos tu plan personalizado")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .font(.subheadline)
    }
}

// MARK: - Button Styles
struct ProfilePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(.themeDeepBlue)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct ProfileSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.white.opacity(0.2))
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
