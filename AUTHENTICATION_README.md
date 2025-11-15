# Sistema de Autenticación - Seisense

## 📱 Descripción General

Se ha implementado un sistema completo de autenticación con diseño moderno y amigable que sigue la paleta de colores de la aplicación.

## 🎨 Características Visuales

### Pantalla de Bienvenida
- Gradiente suave con los colores de la app (Teal y Light Aqua)
- Ícono de huella de pantera
- Texto "Bienvenido a" con gradiente negro animado que resalta
- Nombre de la app "Seisense" en verde oscuro
- Mensaje de bienvenida cálido
- Botón "Comenzar" con gradiente

### Pantalla de Inicio de Sesión
- Formas orgánicas en la parte superior (naranja, verde oscuro y teal)
- Campos de texto para correo y contraseña
- Botón circular con flecha para iniciar sesión
- Enlaces para "Crear cuenta" y "¿Olvidaste tu contraseña?"

### Pantalla de Registro
- Formas orgánicas dominadas por teal y verde
- Campos para nombre, correo y contraseña
- Validación de contraseña (mínimo 6 caracteres)
- Botón circular para completar registro

### Recuperación de Contraseña
- Modal simple y claro
- Campo de correo electrónico
- Confirmación de envío

## 🔧 Implementación Técnica

### Archivos Creados

1. **AuthenticationView.swift** - Vista principal que coordina las pantallas
2. **WelcomeView.swift** - Pantalla de bienvenida inicial
3. **SignInView.swift** - Pantalla de inicio de sesión
4. **SignUpView.swift** - Pantalla de registro
5. **ForgotPasswordView.swift** - Modal de recuperación de contraseña
6. **CustomTextField.swift** - Componentes de campos de texto personalizados
7. **AuthenticationManager.swift** - Gestor de autenticación

### Modificaciones

1. **WellnessPantherApp.swift** - Integración de autenticación en el flujo principal
2. **MoreView.swift** - Agregado botón de cerrar sesión

## 🎯 Flujo de Usuario

1. **Primera vez**: 
   - Usuario ve pantalla de bienvenida
   - Puede elegir entre "Iniciar sesión" o "Crear cuenta"

2. **Inicio de sesión**:
   - Usuario ingresa credenciales
   - Se valida que los campos no estén vacíos
   - Se simula autenticación (1 segundo)
   - Al éxito, se redirige a la app principal

3. **Registro**:
   - Usuario ingresa nombre, correo y contraseña
   - Validación de contraseña (mínimo 6 caracteres)
   - Se simula creación de cuenta
   - Al éxito, se redirige a la app principal

4. **Cerrar sesión**:
   - Desde la sección "Más" > "Configuración"
   - Botón "Cerrar sesión" en rojo
   - Confirmación con alerta
   - Regresa a pantalla de autenticación

## 🧪 Cómo Probar

### Ver las pantallas de autenticación:

1. **Primera opción - Eliminar datos de UserDefaults**:
   - En Xcode: Product > Clean Build Folder
   - Eliminar la app del simulador
   - Volver a ejecutar

2. **Segunda opción - Cerrar sesión desde la app**:
   - Ir a la pestaña "Más"
   - Desplazarse hasta "Configuración"
   - Tocar "Cerrar sesión"
   - Confirmar en el diálogo

### Resetear manualmente el estado de autenticación:

```swift
// Ejecutar este código en un Playground o terminal de depuración:
UserDefaults.standard.set(false, forKey: "isUserAuthenticated")
```

## 🎨 Paleta de Colores Utilizada

- **Verde Oscuro** (#005233) - Áreas principales y texto importante
- **Teal** (#2FA4B8) - Acentos y elementos interactivos
- **Aqua Claro** (#C3EDF4) - Fondos y elementos secundarios
- **Naranja/Amarillo** (#FFC107) - Detalle decorativo en login
- **Rojo** (#F44336) - Botón de cerrar sesión

## ⚙️ Configuración Persistente

El estado de autenticación se guarda en `UserDefaults` con la clave `"isUserAuthenticated"`.

### AuthenticationManager

- Singleton que gestiona el estado global de autenticación
- Métodos async/await para operaciones de red simuladas
- Notificaciones para actualizar el UI:
  - `"UserDidAuthenticate"` - Usuario inició sesión
  - `"UserDidLogout"` - Usuario cerró sesión

## 🔐 Seguridad (Pendiente para Producción)

⚠️ **IMPORTANTE**: Esta es una implementación de demostración. Para producción se requiere:

1. Integración con backend real
2. Validación de correo electrónico
3. Hash de contraseñas
4. Tokens de autenticación (JWT)
5. Refresh tokens
6. Biometría (Face ID / Touch ID)
7. Validación de fortaleza de contraseña
8. Rate limiting para prevenir ataques de fuerza bruta

## 📝 Notas de Desarrollo

- Las transiciones entre pantallas usan `.asymmetric` para movimientos naturales
- Los campos de texto tienen validación básica
- El diseño es completamente responsivo
- Todas las animaciones son suaves y profesionales
- Se mantiene la consistencia visual con el resto de la app

## 🚀 Próximos Pasos Sugeridos

1. Conectar con backend real
2. Agregar validación de correo electrónico
3. Implementar biometría
4. Agregar opción "Recordarme"
5. Implementar OAuth (Google, Apple Sign In)
6. Agregar onboarding después del registro
7. Perfil de usuario completo
