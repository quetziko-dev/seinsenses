import SwiftUI

struct MeditationView: View {
    @StateObject private var viewModel = MeditationViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Sponsor header
                    sponsorHeader
                    
                    // Welcome section
                    welcomeSection
                    
                    // Gallery of meditation images
                    if !viewModel.images.isEmpty {
                        meditationGallery
                    } else if viewModel.isLoading {
                        loadingView
                    }
                    
                    // Meditation practices
                    practicesSection
                }
                .padding()
            }
            .background(Color.themeLightAqua)
            .navigationTitle("Meditación")
            .navigationBarTitleDisplayMode(.large)
            .task {
                await viewModel.loadImages()
            }
        }
    }
    
    private var sponsorHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Patrocinado por")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundColor(.themeLavender)
                
                Text("@anahi_soundhealing")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.themePrimaryDarkGreen)
                
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.themeTeal)
            }
            
            Text("Terapia de sonido y sanación energética")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: [Color.themeLavender.opacity(0.1), Color.themeTeal.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.themeLavender.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Encuentra tu Paz Interior")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.themePrimaryDarkGreen)
            
            Text("Descubre prácticas de meditación, sound healing y mindfulness")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var meditationGallery: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(.themeTeal)
                Text("Inspiración de @anahi_soundhealing")
                    .font(.headline)
                    .foregroundColor(.themePrimaryDarkGreen)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.images) { image in
                        MeditationImageCard(image: image)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var loadingView: some View {
        HStack {
            ProgressView()
            Text("Cargando imágenes...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    private var practicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Prácticas de Meditación")
                .font(.headline)
                .foregroundColor(.themePrimaryDarkGreen)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MeditationPracticeCard(
                    icon: "figure.mind.and.body",
                    title: "Mindfulness",
                    description: "5-10 min",
                    color: .themeLavender
                )
                
                MeditationPracticeCard(
                    icon: "lungs.fill",
                    title: "Respiración",
                    description: "3 min",
                    color: .themeTeal
                )
                
                MeditationPracticeCard(
                    icon: "sparkles",
                    title: "Sound Healing",
                    description: "15 min",
                    color: .themeDeepBlue
                )
                
                MeditationPracticeCard(
                    icon: "heart.fill",
                    title: "Gratitud",
                    description: "5 min",
                    color: .themePrimaryDarkGreen
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Meditation Image Card
struct MeditationImageCard: View {
    let image: MeditationImage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .bottomLeading) {
                if let localName = image.localName {
                    // Try to load local image, fallback to placeholder
                    if let uiImage = UIImage(named: localName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 220)
                            .clipped()
                    } else {
                        // Placeholder with gradient
                        placeholderImage
                    }
                } else if let url = image.imageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .failure, .empty:
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                    .frame(width: 220, height: 220)
                    .clipped()
                }
                
                // Instagram icon overlay
                Image(systemName: "camera.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            // Caption
            if let caption = image.caption {
                Text(caption)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
        }
        .frame(width: 220)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private var placeholderImage: some View {
        LinearGradient(
            colors: [
                Color.themeLavender.opacity(0.3),
                Color.themeTeal.opacity(0.3),
                Color.themeDeepBlue.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .frame(width: 220, height: 220)
        .overlay(
            VStack {
                Image(systemName: "photo")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.6))
                Text("Meditación")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        )
    }
}

// MARK: - Meditation Practice Card
struct MeditationPracticeCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - ViewModel
@MainActor
class MeditationViewModel: ObservableObject {
    @Published var images: [MeditationImage] = []
    @Published var isLoading = false
    
    private let service = MockMeditationMediaService.shared
    
    func loadImages() async {
        isLoading = true
        
        do {
            images = try await service.fetchFeaturedMeditationImages()
            isLoading = false
            print("✅ Cargadas \(images.count) imágenes de meditación")
        } catch {
            isLoading = false
            print("❌ Error cargando imágenes: \(error)")
        }
    }
}

#Preview {
    MeditationView()
}
