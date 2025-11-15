import SwiftUI
import AVFoundation

struct BreathingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BreathingViewModel()
    
    var body: some View {
        ZStack {
            Color.themeLightAqua.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Header
                VStack(spacing: 8) {
                    Text("Respiración Consciente")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Sigue el círculo para respirar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Breathing Circle Animation
                ZStack {
                    // Outer circle
                    Circle()
                        .stroke(Color.themeTeal.opacity(0.3), lineWidth: 2)
                        .frame(width: 280, height: 280)
                    
                    // Animated circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.themeTeal, Color.themeLavender],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: viewModel.circleSize, height: viewModel.circleSize)
                        .shadow(color: .themeTeal.opacity(0.5), radius: 20)
                    
                    // Phase text
                    Text(viewModel.currentPhase.displayText)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                // Timer
                Text("\(viewModel.countdown)")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.themePrimaryDarkGreen)
                    .monospacedDigit()
                
                Spacer()
                
                // Controls
                VStack(spacing: 16) {
                    if viewModel.isExerciseRunning {
                        HStack(spacing: 20) {
                            Button(action: {
                                viewModel.pauseExercise()
                            }) {
                                HStack {
                                    Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                                    Text(viewModel.isPaused ? "Continuar" : "Pausar")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.themeTeal)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                viewModel.stopExercise()
                            }) {
                                HStack {
                                    Image(systemName: "stop.fill")
                                    Text("Finalizar")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    } else {
                        Button(action: {
                            viewModel.startExercise()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Iniciar Ejercicio")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.themeTeal)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

// MARK: - View Model
@MainActor
class BreathingViewModel: ObservableObject {
    @Published var currentPhase: BreathingPhase = .inhale
    @Published var countdown = 4
    @Published var circleSize: CGFloat = 150
    @Published var isExerciseRunning = false
    @Published var isPaused = false
    
    private var timer: Timer?
    private var audioPlayer: AVAudioPlayer?
    
    enum BreathingPhase {
        case inhale, hold, exhale
        
        var displayText: String {
            switch self {
            case .inhale: return "Inhala"
            case .hold: return "Mantén"
            case .exhale: return "Exhala"
            }
        }
        
        var duration: Int {
            return 4 // 4 seconds each phase
        }
        
        var circleSize: CGFloat {
            switch self {
            case .inhale: return 250
            case .hold: return 250
            case .exhale: return 150
            }
        }
    }
    
    func startExercise() {
        isExerciseRunning = true
        isPaused = false
        currentPhase = .inhale
        countdown = currentPhase.duration
        startPhase()
        playBackgroundMusic()
    }
    
    func pauseExercise() {
        isPaused.toggle()
        
        if isPaused {
            timer?.invalidate()
            timer = nil
            audioPlayer?.pause()
        } else {
            startPhase()
            audioPlayer?.play()
        }
    }
    
    func stopExercise() {
        isExerciseRunning = false
        isPaused = false
        timer?.invalidate()
        timer = nil
        stopBackgroundMusic()
        
        // Reset to initial state
        currentPhase = .inhale
        countdown = 4
        withAnimation {
            circleSize = 150
        }
    }
    
    private func startPhase() {
        // Animate circle size
        withAnimation(.easeInOut(duration: Double(currentPhase.duration))) {
            circleSize = currentPhase.circleSize
        }
        
        // Start countdown
        countdown = currentPhase.duration
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.countdown -= 1
                
                if self.countdown <= 0 {
                    self.nextPhase()
                }
            }
        }
    }
    
    private func nextPhase() {
        timer?.invalidate()
        
        switch currentPhase {
        case .inhale:
            currentPhase = .hold
        case .hold:
            currentPhase = .exhale
        case .exhale:
            currentPhase = .inhale
        }
        
        countdown = currentPhase.duration
        startPhase()
    }
    
    private func playBackgroundMusic() {
        // Try to load background music
        // User should provide the audio file in Assets
        // For now, we'll just prepare the player without crashing if file doesn't exist
        
        /*
        if let audioURL = Bundle.main.url(forResource: "breathing_piano", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.volume = 0.3 // Soft volume
                audioPlayer?.play()
            } catch {
                print("No se pudo cargar el audio de respiración: \(error)")
                // Continuar sin música
            }
        }
        */
    }
    
    private func stopBackgroundMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func cleanup() {
        stopExercise()
    }
}

#Preview {
    NavigationStack {
        BreathingExerciseView()
    }
}
