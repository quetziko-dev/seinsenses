import Foundation
import SwiftUI

// MARK: - Meditation Media Service Protocol
protocol MeditationMediaServiceProtocol {
    func fetchFeaturedMeditationImages() async throws -> [MeditationImage]
}

// MARK: - Meditation Image Model
struct MeditationImage: Identifiable, Codable {
    let id: String
    let imageURL: URL?
    let localName: String?
    let caption: String?
    
    init(id: String, imageURL: URL? = nil, localName: String? = nil, caption: String?) {
        self.id = id
        self.imageURL = imageURL
        self.localName = localName
        self.caption = caption
    }
}

// MARK: - Mock Implementation
/// Implementación MOCK del servicio de medios de meditación
/// 
/// ⚠️ IMPORTANTE - FUTURO BACKEND:
/// Esta implementación usa imágenes locales placeholder.
/// 
/// Para producción, se debe:
/// 1. Crear un backend que consuma la Instagram Graph API
/// 2. El backend debe estar autenticado con la cuenta oficial @anahi_soundhealing
/// 3. El backend debe exponer un endpoint REST, por ejemplo:
///    GET /api/meditation/featured-images
///    Response: [{ id, imageURL, caption }]
/// 4. Este servicio debe hacer fetch a ese endpoint en lugar de usar mocks
/// 5. NUNCA exponer tokens de Instagram directamente en la app (seguridad)
/// 
/// Documentación Instagram Graph API:
/// https://developers.facebook.com/docs/instagram-basic-display-api/
/// 
/// Flujo recomendado:
/// App iOS → Backend (tu servidor) → Instagram Graph API → @anahi_soundhealing
@MainActor
final class MockMeditationMediaService: MeditationMediaServiceProtocol {
    static let shared = MockMeditationMediaService()
    
    private init() {}
    
    /// Fetch featured meditation images
    /// Actualmente devuelve imágenes mock locales
    /// TODO: Conectar con backend real cuando esté disponible
    func fetchFeaturedMeditationImages() async throws -> [MeditationImage] {
        // Simular latencia de red
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
        
        // Imágenes mock inspiradas en @anahi_soundhealing
        // Estas son placeholders que deben ser reemplazados por imágenes reales
        let mockImages: [MeditationImage] = [
            MeditationImage(
                id: "anahi_1",
                localName: "meditation_bowl",
                caption: "Cuencos tibetanos para sanación profunda 🎶"
            ),
            MeditationImage(
                id: "anahi_2",
                localName: "meditation_nature",
                caption: "Conecta con la naturaleza y encuentra paz interior 🌿"
            ),
            MeditationImage(
                id: "anahi_3",
                localName: "meditation_yoga",
                caption: "Práctica de mindfulness y respiración consciente 🧘‍♀️"
            ),
            MeditationImage(
                id: "anahi_4",
                localName: "meditation_sunset",
                caption: "Meditación al atardecer, momento de gratitud 🌅"
            ),
            MeditationImage(
                id: "anahi_5",
                localName: "meditation_sound",
                caption: "Terapia de sonido para balance energético ✨"
            ),
            MeditationImage(
                id: "anahi_6",
                localName: "meditation_calm",
                caption: "Encuentra tu centro de calma y serenidad 🕊️"
            )
        ]
        
        print("✅ Cargadas \(mockImages.count) imágenes de meditación (mock)")
        return mockImages
    }
}

// MARK: - Production Implementation (Para futuro)
/// Implementación real que se conectaría al backend
/// NO USAR TODAVÍA - Solo estructura de referencia
final class ProductionMeditationMediaService: MeditationMediaServiceProtocol {
    static let shared = ProductionMeditationMediaService()
    
    // URL del backend (configurar según tu servidor)
    private let baseURL = "https://api.tuservidor.com"
    
    private init() {}
    
    func fetchFeaturedMeditationImages() async throws -> [MeditationImage] {
        // TODO: Implementar cuando el backend esté listo
        // Ejemplo de implementación:
        
        /*
        let url = URL(string: "\(baseURL)/api/meditation/featured-images")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw MeditationServiceError.networkError
        }
        
        let images = try JSONDecoder().decode([MeditationImage].self, from: data)
        return images
        */
        
        // Por ahora, delegar al mock
        return try await MockMeditationMediaService.shared.fetchFeaturedMeditationImages()
    }
}

// MARK: - Errors
enum MeditationServiceError: LocalizedError {
    case networkError
    case decodingError
    case noImagesAvailable
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Error de conexión al cargar imágenes de meditación"
        case .decodingError:
            return "Error al procesar imágenes de meditación"
        case .noImagesAvailable:
            return "No hay imágenes disponibles en este momento"
        }
    }
}
