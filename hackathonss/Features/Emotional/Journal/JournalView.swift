import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var entryText = ""
    @State private var showingSaved = false
    @State private var showingHistory = false
    
    private var currentUser: User? {
        users.first
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Diario Emocional")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    Text("Escribe libremente cómo te sientes hoy. Este espacio es solo para ti.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Date
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.themeTeal)
                    Text(Date(), style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let count = currentUser?.journalEntries.count, count > 0 {
                        Button(action: {
                            showingHistory = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "book.fill")
                                Text("\(count) \(count == 1 ? "entrada" : "entradas")")
                            }
                            .font(.caption)
                            .foregroundColor(.themeTeal)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Text Editor
                VStack(alignment: .leading, spacing: 12) {
                    Text("¿Cómo te sientes?")
                        .font(.headline)
                        .foregroundColor(.themePrimaryDarkGreen)
                    
                    TextEditor(text: $entryText)
                        .frame(minHeight: 300)
                        .padding(8)
                        .background(Color.themeLightAqua.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.themeTeal.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text("\(entryText.count) caracteres")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        entryText = ""
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Limpiar")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    .disabled(entryText.isEmpty)
                    
                    Button(action: {
                        saveEntry()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Guardar")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(entryText.isEmpty ? Color.gray.opacity(0.3) : Color.themeTeal)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(entryText.isEmpty)
                }
            }
            .padding()
        }
        .background(Color.themeLightAqua)
        .navigationTitle("Diario")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Entrada Guardada", isPresented: $showingSaved) {
            Button("OK") {
                entryText = ""
            }
        } message: {
            Text("Tu entrada ha sido guardada en tu diario privado")
        }
        .sheet(isPresented: $showingHistory) {
            JournalHistoryView()
        }
    }
    
    private func saveEntry() {
        guard let user = currentUser, !entryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let newEntry = JournalEntry(text: entryText)
        user.journalEntries.append(newEntry)
        
        do {
            try modelContext.save()
            showingSaved = true
            print("✅ Entrada de diario guardada")
        } catch {
            print("❌ Error al guardar entrada: \(error)")
        }
    }
}

// MARK: - Journal History View
struct JournalHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var users: [User]
    
    private var currentUser: User? {
        users.first
    }
    
    private var sortedEntries: [JournalEntry] {
        currentUser?.journalEntries.sorted(by: { $0.date > $1.date }) ?? []
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if sortedEntries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.themeTeal.opacity(0.5))
                        
                        Text("No hay entradas todavía")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(60)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(sortedEntries) { entry in
                            JournalEntryCard(entry: entry)
                        }
                    }
                    .padding()
                }
            }
            .background(Color.themeLightAqua)
            .navigationTitle("Mis Entradas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.themeTeal)
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.text)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(isExpanded ? nil : 3)
            
            if entry.text.count > 150 {
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Ver menos" : "Ver más")
                        .font(.caption)
                        .foregroundColor(.themeTeal)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    NavigationStack {
        JournalView()
    }
}
