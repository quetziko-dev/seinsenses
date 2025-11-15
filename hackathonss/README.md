# WellnessPantherApp

Una aplicación móvil nativa para iOS tipo wellness que funciona como un acompañante personal en el camino hacia el bienestar integral, centrada en una mascota pantera como eje visual y emocional.

## 🎯 Características Principales

### 🐾 Mascota Panthera
- **Sistema de evolución**: Cachorro → Joven → Adulta
- **Experiencia y niveles**: Gana XP completando actividades de bienestar
- **Outfits personalizables**: Desbloquea diferentes atuendos según tu progreso
- **Animaciones interactivas**: La pantera reacciona a tu progreso

### 🌈 6 Áreas de Bienestar
1. **Físico**: Actividad, peso, altura, IMC, seguimiento de ejercicio
2. **Emocional-Mental**: Registro de emociones, análisis con IA, tarro de emociones
3. **Social**: Conexiones, actividades grupales, red de apoyo
4. **Espiritual**: Meditación, mindfulness, prácticas espirituales
5. **Ocupacional**: Equilibrio trabajo-vida, desarrollo profesional
6. **Ambiental**: Conexión con el entorno, espacios saludables

### 🎨 Diseño Visual
- **Paleta de colores específica**:
  - Verde oscuro profundo (#005233)
  - Verde-azulado medio (#2FA4B8)
  - Aqua muy claro (#C3EDF4)
  - Lavanda suave (#B3A6FF)
  - Azul intenso (#252E89)
- **Estilo moderno y cálido**: Esquinas redondeadas, sombras suaves, sensación "pastel"

## 🏗️ Arquitectura Técnica

### Stack Tecnológico
- **Swift 5.9+**: Lenguaje principal
- **SwiftUI**: Framework de interfaz declarativa
- **SwiftData**: Persistencia de datos nativa
- **Combine**: Manejo de streams asíncronos

### Patrón de Arquitectura
- **MVVM + SwiftUI Native**: Model-View-ViewModel con patrones nativos de SwiftUI
- **Navegación moderna**: TabView + NavigationStack con path-based navigation
- **Inyección de dependencias**: @EnvironmentObject para estado compartido

### Estructura del Proyecto
```
WellnessPantherApp/
├── App/                    # Entry point y configuración principal
├── Core/                   # Modelos, ViewModels y Servicios compartidos
│   ├── Models/            # Modelos de datos SwiftData
│   ├── ViewModels/        # Lógica de negocio de las vistas
│   └── Services/          # Servicios de IA, notificaciones, etc.
├── Features/              # Módulos por funcionalidad
│   ├── Home/              # Pantalla principal
│   ├── Physical/          # Bienestar físico
│   ├── Emotional/         # Bienestar emocional
│   ├── Social/            # Bienestar social
│   ├── Spiritual/         # Bienestar espiritual
│   └── More/              # Configuración y áreas adicionales
├── DesignSystem/          # Sistema de diseño reutilizable
│   ├── Theme/             # Colores, tipografía, espaciado
│   ├── Components/        # Componentes UI personalizados
│   └── Extensions/        # Extensiones de SwiftUI
└── Services/              # Servicios especializados
    ├── AI/                # Análisis emocional con IA
    ├── Notifications/     # Gestión de notificaciones
    └── Persistence/       # Configuración de SwiftData
```

## 📊 Modelos de Datos Clave

### Usuario y Progreso
- **User**: Perfil principal del usuario
- **PantherProgress**: Nivel, experiencia, evolución de la pantera
- **PantherEvolution**: Historial de evoluciones

### Bienestar Físico
- **PhysicalData**: Altura, peso, IMC, metas
- **PhysicalActivity**: Registro de actividades físicas
- **SleepData**: Seguimiento del sueño y calidad

### Bienestar Emocional
- **EmotionData**: Registro de emociones y respuestas
- **EmotionResponse**: Respuestas a preguntas reflexivas
- **MoodJar**: Tarro de emociones con canicas visuales
- **MoodMarble**: Canicas individuales con posición e intensidad

### Análisis con IA
- **AIEmotionAnalysisResult**: Resultados de análisis emocional
- **SeverityLevel**: Niveles de severidad (bajo, medio, alto, crítico)

## 🎮 Flujo de Usuario

### Registro Emocional
1. **Selección de emoción**: Interfaz visual con 10 emociones
2. **Intensidad**: Slider para indicar nivel (0-100%)
3. **Preguntas reflexivas**: Flujo 1-a-1 con 4 preguntas guiadas
4. **Notas adicionales**: Campo de texto libre
5. **Análisis con IA**: Resultado personalizado con sugerencias

### Seguimiento Físico
1. **Configuración inicial**: Altura, peso, metas semanales
2. **Registro de actividades**: Tipo, duración, calorías
3. **Progreso visual**: Barras de progreso y estadísticas
4. **Historial**: Actividades recientes y tendencias

### Sistema de Panthera
1. **Experiencia**: Gana XP por cada actividad completada
2. **Evolución**: Desbloquea nuevos niveles cada 100/250/500 XP
3. **Recompensas**: Outfits y características especiales
4. **Interactividad**: Animaciones y respuestas visuales

## 🎨 Sistema de Diseño

### Colores Temáticos
```swift
static let themePrimaryDarkGreen = Color(hex: "#005233")
static let themeTeal = Color(hex: "#2FA4B8")
static let themeLightAqua = Color(hex: "#C3EDF4")
static let themeLavender = Color(hex: "#B3A6FF")
static let themeDeepBlue = Color(hex: "#252E89")
```

### Gradientes
- **Wellness**: Verde oscuro → Teal → Aqua claro
- **Conversacional**: Azul intenso → Lavanda
- **Emocional**: Lavanda → Teal → Aqua claro
- **Espiritual**: Azul intenso → Verde oscuro
- **Físico**: Teal → Verde oscuro

### Componentes Reutilizables
- **WellnessCard**: Tarjetas con sombras y esquinas redondeadas
- **PantherAvatar**: Avatar de pantera con múltiples niveles y animaciones
- **MoodMarble**: Canicas de emociones con efectos visuales
- **PrimaryButton**: Botones principales con gradiente
- **GradientBackground**: Fondos animados y estáticos

## 🚀 Requisitos de Sistema

- **iOS 17.0+**: Para SwiftData y últimas características de SwiftUI
- **Xcode 15.0+**: Para compilación con Swift 5.9
- **iPhone**: Dispositivos con iOS 17 compatible
- **Almacenamiento**: ~50MB (crecerá con datos de usuario)

## 🔧 Configuración del Proyecto

### 1. Clonar el proyecto
```bash
git clone [repository-url]
cd WellnessPantherApp
```

### 2. Abrir en Xcode
```bash
open WellnessPantherApp.xcodeproj
```

### 3. Configurar el equipo de desarrollo
- Seleccionar tu equipo de desarrollo
- Configurar Bundle Identifier único
- Habilitar capabilities necesarias (Notificaciones, HealthKit si aplica)

### 4. Compilar y ejecutar
```bash
# Desde Xcode: Cmd + R
# O desde línea de comandos:
xcodebuild -project WellnessPantherApp.xcodeproj -scheme WellnessPantherApp -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## 🧪 Testing

### Tests Unitarios
- Modelos de datos con SwiftData
- Lógica de ViewModels
- Servicios de IA (mock)

### Tests UI
- Flujo de navegación
- Componentes de DesignSystem
- Interacciones de usuario

### Tests de Integración
- Persistencia de datos
- Servicios de notificaciones
- Análisis con IA

## 📱 Screenshots Principales

### Home
- Bienvenida con estado actual de la pantera
- Acciones rápidas a áreas principales
- Resumen del progreso diario

### Bienestar Emocional
- Tarro de emociones visual
- Flujo de preguntas reflexivas
- Análisis con IA personalizado

### Bienestar Físico
- Estadísticas físicas principales
- Registro de actividades
- Progreso semanal visual

### Sistema de Panthera
- Avatar interactivo con animaciones
- Sistema de niveles y experiencia
- Outfits personalizables

## 🔮 Roadmap Futuro

### Versión 1.1
- Integración con HealthKit
- Notificaciones personalizadas
- Exportación de datos

### Versión 1.2
- Conectividad con dispositivos wearables
- Modo social con amigos
- Desafíos grupales

### Versión 2.0
- IA avanzada con aprendizaje personalizado
- Realidad aumentada para la pantera
- Integración con servicios de salud

## 📄 Licencia

Este proyecto es propiedad privada y está protegido por derechos de autor.

## 👥 Equipo de Desarrollo

- **Arquitecto Senior iOS**: Diseño y arquitectura principal
- **Desarrollador SwiftUI**: Implementación de componentes
- **Diseñador UX/UI**: Sistema de diseño y experiencia de usuario
- **Especialista en IA**: Integración de servicios de análisis emocional

---

## 🎯 Resumen de Implementación

Esta aplicación representa un enfoque moderno y completo al bienestar digital, combinando:

- **Tecnología nativa iOS** de última generación
- **Diseño centrado en el usuario** con una mascota emocional
- **Arquitectura escalable** y mantenible
- **Experiencia conversacional** personalizada
- **Sistema de gamificación** motivador

La pantera como acompañante emocional crea una conexión única con el usuario, haciendo el seguimiento del bienestar una experiencia cálida, personal y motivadora.
