import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(placeholder)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 30)
            
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .padding(.horizontal, 20)
                )
        }
    }
}

struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(placeholder)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.leading, 30)
            
            HStack {
                if isSecure {
                    SecureField("", text: $text)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                } else {
                    TextField("", text: $text)
                        .autocapitalization(.none)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                
                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .padding(.horizontal, 20)
            )
        }
    }
}

#Preview("TextField") {
    VStack {
        CustomTextField(
            placeholder: "Correo electrónico",
            text: .constant(""),
            keyboardType: .emailAddress
        )
        
        CustomSecureField(
            placeholder: "Contraseña",
            text: .constant("")
        )
    }
    .padding()
}
