import SwiftUI
import SwiftData

struct EmotionalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var currentUser: User?
    @State private var isShowingEmotionFlow = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Full background extending to edges
                Color.themeLightAqua
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 20) {
                    // Current Mood Section
                    currentMoodSection
                    
                    // Mood Jar Visualization
                    moodJarSection
                    
                    // Emotional History
                    emotionalHistorySection
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            }
            .navigationTitle("Bienestar Emocional")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Agregar") {
                        isShowingEmotionFlow = true
                    }
                    .foregroundColor(.themeTeal)
                }
            }
            .toolbarBackground(Color.themeLightAqua, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                setupCurrentUser()
            }
            .navigationDestination(isPresented: $isShowingEmotionFlow) {
                EmotionFlowView()
            }
        }
    }
    
    private var currentMoodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estado Emocional Actual")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            if let user = currentUser, let moodJar = user.moodJar, let currentMood = moodJar.currentMood {
                HStack {
                    Text(currentMood.icon)
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentMood.rawValue.capitalized)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Último registro: hoy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Actualizar") {
                        isShowingEmotionFlow = true
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 40))
                        .foregroundColor(.themeLavender)
                    
                    Text("No has registrado tu estado emocional hoy")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Registrar ahora") {
                        isShowingEmotionFlow = true
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
    
    private func moodJarSectionView(user: User) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tarro de Emociones")
                    .font(.headline)
                    .foregroundColor(.themePrimaryDarkGreen)
                
                Spacer()
                
                Text("\(user.moodJar?.marbles.count ?? 0) días")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.themeTeal)
            }
            
            if let moodJar = user.moodJar, !moodJar.marbles.isEmpty {
                // Enhanced 2D Mood Jar with Solid Design
                MoodJarView(
                    marbles: Array(moodJar.marbles.suffix(20)),
                    maxVisible: 20,
                    isAnimated: true
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10)
                
                // Legend
                let recentEmotions = moodJar.marbles.suffix(7).map { $0.emotion }
                let emotionCounts = Dictionary(grouping: recentEmotions) { $0 }
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(emotionCounts.keys.sorted(by: { emotionCounts[$0]!.count > emotionCounts[$1]!.count }), id: \.self) { emotion in
                        HStack {
                            Text(emotion.icon)
                                .font(.system(size: 16))
                            
                            Text(emotion.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("×\(emotionCounts[emotion]?.count ?? 0)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.themePrimaryDarkGreen)
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "jar")
                        .font(.system(size: 40))
                        .foregroundColor(.themeTeal)
                    
                    Text("Tu tarro de emociones está vacío")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Comienza a registrar tus emociones diarias para ver tu progreso")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var moodJarSection: some View {
        Group {
            if let user = currentUser {
                moodJarSectionView(user: user)
            } else {
                EmptyView()
            }
        }
    }
    
    private var emotionalHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Historial Emocional")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            if let user = currentUser, let moodJar = user.moodJar {
                let lastWeekEmotions = moodJar.marbles.suffix(7)
                
                if !lastWeekEmotions.isEmpty {
                    LazyVStack(spacing: 8) {
                        ForEach(lastWeekEmotions.reversed(), id: \.id) { marble in
                            EmotionHistoryRow(marble: marble)
                        }
                    }
                } else {
                    Text("No hay registros emocionales recientes")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            } else {
                Text("Comienza a registrar tus emociones para ver tu historial")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Herramientas Emocionales")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NavigationLink(destination: BreathingExerciseView()) {
                    EmotionToolCardView(
                        title: "Respiración",
                        icon: "lungs.fill",
                        color: .themeTeal
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: MeditationView()) {
                    EmotionToolCardView(
                        title: "Meditación",
                        icon: "brain.head.profile",
                        color: .themeLavender
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: JournalView()) {
                    EmotionToolCardView(
                        title: "Diario",
                        icon: "book.fill",
                        color: .themeDeepBlue
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: EmotionalAnalysisFlowView()) {
                    EmotionToolCardView(
                        title: "Análisis IA",
                        icon: "cpu",
                        color: .themePrimaryDarkGreen
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
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
        
        // Initialize mood jar if it doesn't exist
        if let user = currentUser, user.moodJar == nil {
            user.moodJar = MoodJar()
        }
    }
}

struct EmotionHistoryRow: View {
    let marble: MoodMarble
    
    var body: some View {
        HStack {
            Text(marble.emotion.icon)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(marble.emotion.rawValue.capitalized)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(marble.dateText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Intensity indicator
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index < Int(marble.intensity * 5) ? Color.themeTeal : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.themeLightAqua.opacity(0.3))
        .cornerRadius(8)
    }
}

struct EmotionToolCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmotionToolCardView: View {
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

extension MoodMarble {
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    EmotionalView()
        .modelContainer(for: [User.self, MoodJar.self, MoodMarble.self], inMemory: true)
}
