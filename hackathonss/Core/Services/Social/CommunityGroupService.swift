import Foundation

// MARK: - Community Group Model
struct CommunityGroup: Identifiable, Codable {
    let id: UUID
    let name: String
    let topic: String
    let createdAt: Date
    let expiresAt: Date
    var isJoined: Bool
    
    var timeRemaining: String {
        let now = Date()
        let remaining = expiresAt.timeIntervalSince(now)
        
        if remaining <= 0 {
            return "Expirado"
        }
        
        let hours = Int(remaining / 3600)
        if hours < 24 {
            return "\(hours)h restantes"
        } else {
            let days = hours / 24
            return "\(days) día\(days == 1 ? "" : "s") restante\(days == 1 ? "" : "s")"
        }
    }
    
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    init(id: UUID = UUID(), name: String, topic: String, createdAt: Date = Date(), isJoined: Bool = false) {
        self.id = id
        self.name = name
        self.topic = topic
        self.createdAt = createdAt
        self.expiresAt = createdAt.addingTimeInterval(72 * 3600) // 72 horas
        self.isJoined = isJoined
    }
}

// MARK: - Community Group Service Protocol
protocol CommunityGroupServiceProtocol {
    func fetchAvailableGroups() async throws -> [CommunityGroup]
    func joinGroup(_ group: CommunityGroup) async throws -> CommunityGroup
}

// MARK: - Mock Community Group Service
/// Servicio mock para grupos comunitarios efímeros
///
/// 🔮 FUTURO - Backend Real:
/// Este servicio debe conectarse a un backend que gestione:
/// 1. Creación de grupos temáticos
/// 2. Sistema de mensajería en tiempo real (Firebase, Pusher, etc.)
/// 3. Caducidad automática a las 72 horas
/// 4. Notificaciones push cuando hay nuevos mensajes
/// 5. Moderación y reportes de contenido inapropiado
///
/// Endpoint sugerido:
/// GET  /api/community/groups        - Lista grupos disponibles
/// POST /api/community/groups/join   - Unirse a grupo
/// GET  /api/community/groups/{id}   - Detalle y mensajes
/// POST /api/community/groups/{id}/messages - Enviar mensaje
@MainActor
final class MockCommunityGroupService: CommunityGroupServiceProtocol {
    static let shared = MockCommunityGroupService()
    
    private init() {}
    
    func fetchAvailableGroups() async throws -> [CommunityGroup] {
        // Simular latencia de red
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundos
        
        // Grupos mock con diferentes tiempos de creación
        let now = Date()
        let groups = [
            CommunityGroup(
                name: "Amantes del running",
                topic: "Compartir rutas y motivarnos para correr 🏃‍♀️",
                createdAt: now.addingTimeInterval(-24 * 3600) // Creado hace 24h
            ),
            CommunityGroup(
                name: "Meditación matutina",
                topic: "Practicamos meditación juntos cada mañana 🧘‍♀️",
                createdAt: now.addingTimeInterval(-48 * 3600) // Creado hace 48h
            ),
            CommunityGroup(
                name: "Lectura y café",
                topic: "Recomendaciones de libros y charla relajada ☕📚",
                createdAt: now.addingTimeInterval(-12 * 3600) // Creado hace 12h
            ),
            CommunityGroup(
                name: "Cocina saludable",
                topic: "Recetas nutritivas y tips de alimentación 🥗",
                createdAt: now.addingTimeInterval(-36 * 3600) // Creado hace 36h
            ),
            CommunityGroup(
                name: "Fotografía urbana",
                topic: "Capturamos la belleza de la ciudad 📸",
                createdAt: now.addingTimeInterval(-6 * 3600) // Creado hace 6h
            )
        ]
        
        // Filtrar grupos no expirados
        let activeGroups = groups.filter { !$0.isExpired }
        
        print("✅ Cargados \(activeGroups.count) grupos comunitarios activos")
        return activeGroups
    }
    
    func joinGroup(_ group: CommunityGroup) async throws -> CommunityGroup {
        // Simular latencia
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 segundos
        
        var joinedGroup = group
        joinedGroup.isJoined = true
        
        print("✅ Unido al grupo: \(group.name)")
        return joinedGroup
    }
}
