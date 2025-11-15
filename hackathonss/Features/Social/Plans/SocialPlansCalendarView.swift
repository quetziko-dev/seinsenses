import SwiftUI
import SwiftData

struct SocialPlansCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    
    @State private var selectedDate = Date()
    @State private var planTitle = ""
    @State private var showingSaved = false
    
    private var currentUser: User? {
        users.first
    }
    
    private var upcomingPlans: [SocialPlan] {
        currentUser?.socialPlans.filter { $0.date >= Date() }.sorted(by: { $0.date < $1.date }) ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calendario de Planes")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Organiza tus encuentros sociales")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Date Picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Selecciona una fecha")
                        .font(.headline)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    DatePicker(
                        "Fecha del plan",
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .tint(.themeTeal)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Plan Details
                VStack(alignment: .leading, spacing: 12) {
                    Text("¿Qué vas a hacer?")
                        .font(.headline)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    TextField("Ej: Cena con amigos, Ir al cine...", text: $planTitle)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.themeLightAqua.opacity(0.3))
                        .cornerRadius(12)
                    
                    Button(action: {
                        savePlan()
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Guardar Plan")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(planTitle.isEmpty ? Color.gray.opacity(0.3) : Color.themeTeal)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(planTitle.isEmpty)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Upcoming Plans
                if !upcomingPlans.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Próximos Planes")
                            .font(.headline)
                            .foregroundColor(.themePrimaryDarkGreen)
                        
                        ForEach(upcomingPlans) { plan in
                            PlanCard(plan: plan, onDelete: {
                                deletePlan(plan)
                            })
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            .padding()
        }
        .background(Color.themeLightAqua)
        .navigationTitle("Planes")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Plan Guardado", isPresented: $showingSaved) {
            Button("OK") {
                planTitle = ""
            }
        } message: {
            Text("Tu plan ha sido guardado exitosamente")
        }
    }
    
    private func savePlan() {
        guard let user = currentUser, !planTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let newPlan = SocialPlan(date: selectedDate, title: planTitle)
        user.socialPlans.append(newPlan)
        
        do {
            try modelContext.save()
            showingSaved = true
            print("✅ Plan social guardado")
        } catch {
            print("❌ Error al guardar plan: \(error)")
        }
    }
    
    private func deletePlan(_ plan: SocialPlan) {
        guard let user = currentUser else { return }
        
        if let index = user.socialPlans.firstIndex(where: { $0.id == plan.id }) {
            user.socialPlans.remove(at: index)
            
            do {
                try modelContext.save()
                print("✅ Plan eliminado")
            } catch {
                print("❌ Error al eliminar plan: \(error)")
            }
        }
    }
}

struct PlanCard: View {
    let plan: SocialPlan
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(plan.date, style: .date)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.themeLightAqua.opacity(0.3))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        SocialPlansCalendarView()
    }
}
