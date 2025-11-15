import SwiftUI
import MessageUI

struct SupportCenterView: View {
    @State private var showingMailComposer = false
    @State private var showingMailError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Centro de ayuda y soporte")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Estamos aquí para ayudarte")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // FAQ Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preguntas frecuentes")
                        .font(.headline)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    VStack(spacing: 12) {
                        FAQItem(
                            question: "¿Cómo funciona la pantera de bienestar?",
                            answer: "Tu pantera evoluciona según tus hábitos saludables. Completa actividades diarias para hacerla crecer."
                        )
                        
                        Divider()
                        
                        FAQItem(
                            question: "¿Mis datos están seguros?",
                            answer: "Sí, toda tu información se almacena localmente en tu dispositivo y nunca se comparte sin tu consentimiento."
                        )
                        
                        Divider()
                        
                        FAQItem(
                            question: "¿Puedo sincronizar entre dispositivos?",
                            answer: "Actualmente los datos se almacenan localmente. La sincronización en la nube estará disponible próximamente."
                        )
                        
                        Divider()
                        
                        FAQItem(
                            question: "¿Cómo activo las notificaciones?",
                            answer: "Ve a Configuración > Notificaciones y activa los recordatorios que desees recibir."
                        )
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Contact Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Contacto")
                        .font(.headline)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            sendEmail()
                        }) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.themeTeal)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Enviar correo")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text("soporte@seinsense.app")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        Button(action: {
                            openSupportWebsite()
                        }) {
                            HStack {
                                Image(systemName: "safari.fill")
                                    .foregroundColor(.themeLavender)
                                    .frame(width: 24)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Visitar sitio de soporte")
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text("seinsense.app/soporte")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.forward")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Quick Tips
                VStack(alignment: .leading, spacing: 16) {
                    Text("Consejos rápidos")
                        .font(.headline)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        TipRow(icon: "target", text: "Completa al menos una actividad diaria para mantener tu pantera feliz")
                        TipRow(icon: "moon.fill", text: "Registra tu sueño cada mañana para un mejor seguimiento")
                        TipRow(icon: "heart.fill", text: "Usa el diario emocional para reflexionar sobre tu día")
                        TipRow(icon: "person.2.fill", text: "Las misiones sociales fortalecen tus conexiones")
                    }
                }
                .padding()
                .background(Color.themeTeal.opacity(0.1))
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color.themeLightAqua)
        .navigationTitle("Ayuda")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingMailComposer) {
            MailComposeView(
                recipients: ["soporte@seinsense.app"],
                subject: "Soporte Seinsense",
                body: ""
            )
        }
        .alert("Correo no disponible", isPresented: $showingMailError) {
            Button("OK") { }
        } message: {
            Text("No se puede enviar correo desde este dispositivo. Por favor contacta a soporte@seinsense.app")
        }
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            showingMailComposer = true
        } else {
            showingMailError = true
        }
    }
    
    private func openSupportWebsite() {
        if let url = URL(string: "https://seinsense.app/soporte") {
            UIApplication.shared.open(url)
        }
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(question)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.themeTeal)
                        .font(.caption)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.themeTeal)
                .frame(width: 20)
            
            Text(text)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// Mail Composer
struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let body: String
    
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        SupportCenterView()
    }
}
