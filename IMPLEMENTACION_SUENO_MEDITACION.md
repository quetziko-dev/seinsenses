# 🌙 Sistema de Sueño (HealthKit) + 🧘‍♀️ Meditación (@anahi_soundhealing)

## ✅ Implementación Completada

He implementado dos sistemas completos:

1. **SUEÑO** - HealthKit como fuente principal + entrada manual como fallback
2. **MEDITACIÓN** - Servicio de imágenes (preparado para @anahi_soundhealing)

---

## 📁 Archivos Creados/Modificados

### Creados (3 archivos):
1. ✅ `SleepService.swift` - Servicio HealthKit + fallback
2. ✅ `MeditationMediaService.swift` - Servicio de imágenes de meditación
3. ✅ `PERMISOS_HEALTHKIT_REQUERIDOS.md` - Instrucciones de configuración

### Modificados (1 archivo):
1. ✅ `SleepData.swift` - Agregado campo `source` (healthKit vs manual)

---

## 🌙 SISTEMA DE SUEÑO

### 1. **SleepData Model** (MODIFICADO)

**Cambios:**
```swift
@Model
final class SleepData {
    // ... campos existentes
    var source: SleepDataSource  // ← NUEVO
    
    init(..., source: SleepDataSource = .manual) {
        // ...
        self.source = source
    }
}

enum SleepDataSource: String, Codable {
    case healthKit = "health_kit"    // Datos desde app Salud
    case manual = "manual"            // Entrada manual del usuario
    
    var displayName: String {
        switch self {
        case .healthKit: return "Datos de Salud"
        case .manual: return "Registro Manual"
        }
    }
}
```

---

### 2. **SleepService** (NUEVO)

**Archivo:** `Core/Services/SleepService.swift`

**Funcionalidades:**

#### A. Check HealthKit Availability
```swift
func isHealthKitAvailable() -> Bool
```
- Verifica si el dispositivo soporta HealthKit
- Retorna `false` en simulador sin configurar

#### B. Request Authorization
```swift
func requestAuthorization() async throws
```
- Solicita **solo lectura** de datos de sueño
- Tipo: `HKCategoryTypeIdentifier.sleepAnalysis`
- **NO pide permisos de escritura**
- **NO accede a Screen Time** (iOS no lo permite)

#### C. Fetch Last Night Sleep
```swift
func fetchLastNightSleep() async throws -> SleepData?
```
- Lee datos de sueño de la última noche
- Rango: 6 PM ayer - 2 PM hoy
- Filtra muestras `.asleep` y `.inBed`
- Calcula: hora mínima inicio, hora máxima fin
- Estima calidad basado en horas totales
- Retorna `SleepData` con `source = .healthKit`
- Retorna `nil` si no hay datos (usar fallback manual)

**Estimación de Calidad:**
```swift
private func estimateQuality(from hours: Double) -> SleepQuality {
    switch hours {
    case 7.5...9:     return .excellent  // Óptimo
    case 6.5..<7.5:   return .good       // Bueno
    case 9..<10:      return .good       // Bueno
    case 5.5..<6.5:   return .fair       // Regular
    case 10..<11:     return .fair       // Regular
    default:          return .poor       // Malo
    }
}
```

---

### 3. **Flujo de Uso Recomendado**

#### En el ViewModel de Sueño:

```swift
import SwiftUI
import SwiftData

@MainActor
class SleepViewModel: ObservableObject {
    @Published var sleepData: SleepData?
    @Published var showManualEntry = false
    @Published var healthKitAvailable = false
    @Published var errorMessage: String?
    
    private let sleepService = SleepService.shared
    
    func loadSleepData() async {
        // 1. Check si HealthKit está disponible
        healthKitAvailable = sleepService.isHealthKitAvailable()
        
        guard healthKitAvailable else {
            // HealthKit no disponible, mostrar entrada manual
            showManualEntry = true
            errorMessage = "HealthKit no disponible en este dispositivo"
            return
        }
        
        do {
            // 2. Solicitar permisos (solo primera vez)
            try await sleepService.requestAuthorization()
            
            // 3. Intentar obtener datos de HealthKit
            if let healthKitSleep = try await sleepService.fetchLastNightSleep() {
                // ✅ Datos obtenidos desde Salud
                sleepData = healthKitSleep
                showManualEntry = false
            } else {
                // ⚠️ No hay datos en HealthKit, usar entrada manual
                showManualEntry = true
                errorMessage = "No hay datos de sueño. Regístralos manualmente."
            }
        } catch {
            // ❌ Error (permisos denegados, etc.)
            showManualEntry = true
            errorMessage = error.localizedDescription
        }
    }
    
    func saveManualSleep(bedTime: Date, wakeTime: Date, quality: SleepQuality) {
        // Crear SleepData manual
        let manualSleep = SleepData(
            bedTime: bedTime,
            wakeTime: wakeTime,
            quality: quality,
            notes: "Registro manual",
            source: .manual  // ← Importante
        )
        
        sleepData = manualSleep
        // TODO: Persistir en SwiftData
    }
}
```

#### En la Vista de Sueño:

```swift
struct SleepView: View {
    @StateObject private var viewModel = SleepViewModel()
    
    var body: some View {
        VStack {
            if let sleep = viewModel.sleepData {
                // Mostrar círculo de sueño
                SleepCircle(sleep: sleep)
                
                // Indicador de fuente de datos
                HStack {
                    Image(systemName: sleep.source == .healthKit ? "heart.fill" : "hand.raised.fill")
                    Text(sleep.source.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if viewModel.showManualEntry {
                // Mostrar entrada manual
                ManualSleepEntry { bedTime, wakeTime, quality in
                    viewModel.saveManualSleep(
                        bedTime: bedTime,
                        wakeTime: wakeTime,
                        quality: quality
                    )
                }
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await viewModel.loadSleepData()
        }
    }
}
```

---

### 4. **⚠️ Limitaciones Importantes**

#### NO Accedemos a:
- ❌ **"Última vez que el usuario usó el teléfono"**
  - iOS no ofrece API pública para esto
  - Screen Time está completamente sandboxed
  - Solo el usuario puede ver estos datos en Configuración
  
- ❌ **Tiempo de pantalla global**
  - No hay forma confiable de obtenerlo
  - Requeriría jailbreak o trucos no seguros

#### Nuestra Solución:
- ✅ **HealthKit** = Fuente principal (oficial, precisa, confiable)
- ✅ **Entrada manual** = Fallback simple y no intrusivo
- ✅ **Sin trucos** = App segura y aprobada por App Store

---

## 🧘‍♀️ SISTEMA DE MEDITACIÓN

### 1. **MeditationMediaService** (NUEVO)

**Archivo:** `Core/Services/MeditationMediaService.swift`

**Modelos:**

```swift
struct MeditationImage: Identifiable, Codable {
    let id: String
    let imageURL: URL?        // URL real (futuro)
    let localName: String?    // Nombre local (actual)
    let caption: String?      // Caption de Instagram
}
```

**Protocolo:**

```swift
protocol MeditationMediaServiceProtocol {
    func fetchFeaturedMeditationImages() async throws -> [MeditationImage]
}
```

---

### 2. **MockMeditationMediaService** (IMPLEMENTACIÓN ACTUAL)

**Uso:**
```swift
let service = MockMeditationMediaService.shared
let images = try await service.fetchFeaturedMeditationImages()
```

**Imágenes Mock (6 placeholders):**
```swift
let mockImages: [MeditationImage] = [
    MeditationImage(
        id: "anahi_1",
        localName: "meditation_bowl",      // Asset local
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
    // ... 3 más
]
```

**📝 Nota:** 
- Las imágenes locales deben agregarse a `Assets.xcassets`
- Nombres sugeridos: `meditation_bowl`, `meditation_nature`, etc.
- Usar imágenes de placeholder por ahora

---

### 3. **Integración Instagram (FUTURO)**

#### ⚠️ IMPORTANTE - Arquitectura Recomendada:

```
┌─────────────────────────────────────────────┐
│  App iOS (seinsense)                        │
│  └─ MeditationMediaService                  │
│     └─ Llama a tu backend                   │
└─────────────────────────────────────────────┘
                    ↓
                HTTP/REST
                    ↓
┌─────────────────────────────────────────────┐
│  TU BACKEND (Node.js, Python, etc.)         │
│  └─ Endpoint: GET /api/meditation/images    │
│     └─ Consulta Instagram Graph API         │
│        con token de @anahi_soundhealing     │
└─────────────────────────────────────────────┘
                    ↓
           Instagram Graph API
                    ↓
┌─────────────────────────────────────────────┐
│  Instagram @anahi_soundhealing              │
│  └─ Fotos públicas                          │
└─────────────────────────────────────────────┘
```

**¿Por qué un backend?**
- ✅ Tokens de Instagram seguros (no expuestos en app)
- ✅ Caché de imágenes
- ✅ Control de rate limits
- ✅ Fallback si Instagram cambia API

**Implementación Futura:**

```swift
// ProductionMeditationMediaService (ya incluido pero comentado)
final class ProductionMeditationMediaService: MeditationMediaServiceProtocol {
    private let baseURL = "https://api.tuservidor.com"
    
    func fetchFeaturedMeditationImages() async throws -> [MeditationImage] {
        let url = URL(string: "\(baseURL)/api/meditation/featured-images")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([MeditationImage].self, from: data)
    }
}
```

**Backend Response Example:**
```json
[
  {
    "id": "instagram_123456",
    "imageURL": "https://cdn.instagram.com/...",
    "caption": "Meditación con cuencos tibetanos ✨"
  },
  {
    "id": "instagram_123457",
    "imageURL": "https://cdn.instagram.com/...",
    "caption": "Sound healing en la naturaleza 🌿"
  }
]
```

---

### 4. **UI de Meditación - Ejemplo de Integración**

```swift
struct MeditationView: View {
    @StateObject private var viewModel = MeditationViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Carrusel de imágenes de @anahi_soundhealing
                    if !viewModel.images.isEmpty {
                        meditationGallery
                    } else {
                        ProgressView()
                    }
                    
                    // Resto del contenido
                }
                .padding()
            }
            .background(Color.themeLightAqua)
            .navigationTitle("Meditación")
            .task {
                await viewModel.loadImages()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Patrocinado por")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("@anahi_soundhealing")
                    .font(.headline)
                    .foregroundColor(.themePrimaryDarkGreen)
                
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.themeTeal)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
    
    private var meditationGallery: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.images) { image in
                    MeditationImageCard(image: image)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MeditationImageCard: View {
    let image: MeditationImage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Imagen
            if let localName = image.localName {
                Image(localName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else if let url = image.imageURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // Caption
            if let caption = image.caption {
                Text(caption)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(width: 200)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

@MainActor
class MeditationViewModel: ObservableObject {
    @Published var images: [MeditationImage] = []
    
    private let service = MockMeditationMediaService.shared
    
    func loadImages() async {
        do {
            images = try await service.fetchFeaturedMeditationImages()
        } catch {
            print("Error cargando imágenes: \(error)")
        }
    }
}
```

---

## ⚙️ CONFIGURACIÓN REQUERIDA

### 1. **HealthKit** (para Sueño)

#### A. Habilitar Capability:
1. Xcode → Target → Signing & Capabilities
2. Click "+ Capability"
3. Agregar "HealthKit"

#### B. Info.plist:
```xml
<key>NSHealthShareUsageDescription</key>
<string>Necesitamos acceso a tus datos de sueño para mostrarte tu progreso de descanso</string>

<key>NSHealthUpdateUsageDescription</key>
<string>No modificamos tus datos de salud, solo los leemos</string>
```

**Ver:** `PERMISOS_HEALTHKIT_REQUERIDOS.md` para instrucciones completas

---

### 2. **Assets de Meditación** (placeholder)

Agregar en `Assets.xcassets`:
- `meditation_bowl` - Imagen de cuencos tibetanos
- `meditation_nature` - Meditación en naturaleza
- `meditation_yoga` - Práctica de yoga/mindfulness
- `meditation_sunset` - Meditación al atardecer
- `meditation_sound` - Terapia de sonido
- `meditation_calm` - Imagen de calma/serenidad

**Fuentes sugeridas:**
- Unsplash (CC0)
- Pexels (free)
- Imágenes propias de @anahi_soundhealing (con permiso)

---

## 📊 Resumen de Funcionalidades

### SUEÑO:
| Funcionalidad | Estado |
|---------------|--------|
| Modelo SleepData con source | ✅ Implementado |
| SleepService con HealthKit | ✅ Implementado |
| Request authorization | ✅ Implementado |
| Fetch last night sleep | ✅ Implementado |
| Fallback entrada manual | ✅ Listo para UI |
| Estimación de calidad | ✅ Implementado |

### MEDITACIÓN:
| Funcionalidad | Estado |
|---------------|--------|
| MeditationImage model | ✅ Implementado |
| MockMeditationMediaService | ✅ Implementado |
| 6 imágenes placeholder | ✅ Mock listo |
| ProductionService (estructura) | ✅ Preparado |
| Documentación Instagram API | ✅ Comentado |
| UI example | ✅ En esta guía |

---

## 🧪 Cómo Probar

### Test 1: HealthKit en Dispositivo Real
```
1. Compila en dispositivo físico iPhone
2. Asegúrate de tener datos de sueño en app Salud
3. Abre la sección de sueño en tu app
4. Acepta permisos cuando se soliciten
5. Verifica que aparecen datos con "Datos de Salud"
```

### Test 2: Fallback Manual en Simulador
```
1. Compila en simulador
2. HealthKit no estará disponible
3. Debe aparecer entrada manual
4. Registra horas manualmente
5. Verifica que se guarda con "Registro Manual"
```

### Test 3: Meditación
```
1. Navega a sección de meditación
2. Debe cargar 6 imágenes placeholder
3. Verifica que se ve "@anahi_soundhealing"
4. Check que cada imagen tiene caption
5. Scroll horizontal funciona suave
```

---

## ✅ Estado del Proyecto

```bash
** BUILD SUCCEEDED **
```

✅ **SleepData actualizado** con campo source  
✅ **SleepService creado** con HealthKit + fallback  
✅ **MeditationMediaService creado** con mocks  
✅ **Documentación completa** de permisos  
✅ **Código comentado** con instrucciones futuras  
✅ **Proyecto compila** sin errores  
✅ **Arquitectura lista** para backend real  

---

## 🎉 Próximos Pasos

### Para Sueño:
1. [ ] Habilitar HealthKit capability en Xcode
2. [ ] Agregar permisos en Info.plist
3. [ ] Integrar SleepService en vista existente
4. [ ] Crear UI de entrada manual
5. [ ] Probar en dispositivo real

### Para Meditación:
1. [ ] Agregar assets de meditación placeholder
2. [ ] Integrar MeditationMediaService en vista
3. [ ] Crear carrusel de imágenes
4. [ ] Diseñar header "@anahi_soundhealing"
5. [ ] (Futuro) Crear backend para Instagram API

**¡Los servicios están implementados y listos para usar!** 🌙🧘‍♀️✨
