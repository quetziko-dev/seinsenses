import Foundation

// MARK: - Social Mission Model
struct SocialMission: Identifiable, Codable {
    let id: UUID
    let text: String
    
    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

// MARK: - Social Mission Service Protocol
protocol SocialMissionServiceProtocol {
    func randomMission() -> SocialMission
}

// MARK: - Social Mission Service
final class SocialMissionService: SocialMissionServiceProtocol {
    static let shared = SocialMissionService()
    
    private init() {}
    
    private let missions: [String] = [
        "Llama a tu mamá o papá y pregúntales cómo están.",
        "Escribe un mensaje a un viejo amigo para saber de su vida.",
        "Invita a alguien a tomar un café esta semana.",
        "Agradece a una persona que te haya ayudado recientemente.",
        "Envía un meme o mensaje divertido a tu grupo de amigos.",
        "Escribe una nota amable a alguien de tu casa.",
        "Comparte un recuerdo feliz con alguien especial.",
        "Pregunta a alguien cómo se siente realmente.",
        "Organiza una videollamada con amigos o familia.",
        "Haz un cumplido sincero a alguien hoy.",
        "Ayuda a alguien con algo pequeño sin que te lo pida.",
        "Reconecta con alguien con quien perdiste contacto."
    ]
    
    func randomMission() -> SocialMission {
        let text = missions.randomElement() ?? missions[0]
        return SocialMission(text: text)
    }
}
