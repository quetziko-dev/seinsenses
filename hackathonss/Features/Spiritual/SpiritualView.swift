import SwiftUI

struct SpiritualView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Section
                    welcomeSection
                    
                    // Spiritual Practices
                    spiritualPracticesSection
                    
                    // Mindfulness Activities
                    mindfulnessSection
                }
                .padding()
            }
            .background(Color.themeLightAqua)
            .navigationTitle("Bienestar Espiritual")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Crecimiento Espiritual")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.themePrimaryDarkGreen)
            
            Text("Encuentra paz, propósito y conexión interior")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var spiritualPracticesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prácticas Espirituales")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                SpiritualPracticeCard(
                    title: "Meditación",
                    icon: "brain.head.profile",
                    color: .themeDeepBlue
                )
                
                SpiritualPracticeCard(
                    title: "Oración",
                    icon: "hands.and.sparkles",
                    color: .themeLavender
                )
                
                SpiritualPracticeCard(
                    title: "Journaling",
                    icon: "book.fill",
                    color: .themeTeal
                )
                
                SpiritualPracticeCard(
                    title: "Naturaleza",
                    icon: "leaf.fill",
                    color: .themePrimaryDarkGreen
                )
            }
        }
    }
    
    private var mindfulnessSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Atención Plena")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            VStack(spacing: 12) {
                MindfulnessRow(
                    title: "Respiración consciente",
                    description: "5 minutos de respiración profunda",
                    duration: "5 min",
                    icon: "lungs.fill",
                    color: .themeTeal
                )
                
                MindfulnessRow(
                    title: "Escaneo corporal",
                    description: "Relajación progresiva del cuerpo",
                    duration: "10 min",
                    icon: "figure.walk",
                    color: .themeLavender
                )
                
                MindfulnessRow(
                    title: "Gratitud diaria",
                    description: "Reflexiona sobre lo que agradeces",
                    duration: "3 min",
                    icon: "heart.fill",
                    color: .themeDeepBlue
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct SpiritualPracticeCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct MindfulnessRow: View {
    let title: String
    let description: String
    let duration: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(duration)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.themePrimaryDarkGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.themeLightAqua.opacity(0.5))
                .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SpiritualView()
}
