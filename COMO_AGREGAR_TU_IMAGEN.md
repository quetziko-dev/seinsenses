# Cómo Agregar Tu Propia Imagen de Pantera

## ✅ Cambios Realizados en TODAS las Pantallas

### Pantallas Actualizadas:

1. ✅ **WelcomeView** - Pantalla de Bienvenida
   - Texto: **"SEISENSE"** en mayúsculas
   - Imagen personalizada con path

2. ✅ **SignInView** - Pantalla de Login
   - Texto: **"SEISENSE"** en mayúsculas
   - Imagen personalizada con path

3. ✅ **SignUpView** - Pantalla de Registro
   - Texto: **"SEISENSE"** en mayúsculas
   - Imagen personalizada con path

### Formato Consistente:
- ✅ Todas usan **"SEISENSE"** (mayúsculas)
- ✅ Todas usan la **misma imagen** personalizada
- ✅ Mismo tamaño de tracking (1.5) para el texto
- ✅ Mismo método para cargar la imagen

---

## 📸 Opción 1: Agregar Imagen a Assets (Recomendado)

### Pasos:

1. **Abre el proyecto en Xcode**

2. **Navega a Assets.xcassets**:
   - En el navegador de proyecto (izquierda), busca: `hackathonss/Assets.xcassets`

3. **Agrega tu imagen**:
   - Arrastra tu archivo `.png` directamente a `Assets.xcassets`
   - O haz clic derecho → "Add Files to Assets"

4. **Nombra tu imagen**:
   - Dale el nombre: `your_panther_image`
   - O cualquier nombre que prefieras

5. **Actualiza el código en WelcomeView.swift**:
   
   Encuentra la línea 23:
   ```swift
   if let uiImage = UIImage(named: "your_panther_image") {
   ```
   
   Cámbiala por el nombre de tu imagen:
   ```swift
   if let uiImage = UIImage(named: "tu_nombre_de_imagen") {
   ```

### Ejemplo con nombre personalizado:

Si tu imagen se llama `pantera_linda.png`:

```swift
if let uiImage = UIImage(named: "pantera_linda") {
    Image(uiImage: uiImage)
        .resizable()
        .scaledToFit()
        .frame(width: 180, height: 180)
}
```

---

## 📂 Opción 2: Usar Ruta Absoluta (Archivo Externo)

Si prefieres mantener la imagen fuera del proyecto:

### Modifica WelcomeView.swift (líneas 20-36):

Reemplaza:
```swift
// Main panther image - Replace with your custom path
VStack {
    // TODO: Reemplaza "your_panther_image.png" con el nombre de tu archivo
    if let uiImage = UIImage(named: "your_panther_image") {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(width: 180, height: 180)
    } else {
        // Fallback a SF Symbol si no encuentra la imagen
        Image(systemName: "pawprint.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(.themePrimaryDarkGreen)
    }
}
```

Por:
```swift
// Main panther image from external file
VStack {
    // Reemplaza con la ruta completa a tu archivo
    let imagePath = "/Users/TU_USUARIO/Desktop/mi_pantera.png"
    
    if let uiImage = UIImage(contentsOfFile: imagePath) {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(width: 180, height: 180)
    } else {
        // Fallback si no encuentra la imagen
        Image(systemName: "pawprint.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(.themePrimaryDarkGreen)
    }
}
```

**Nota**: Reemplaza `/Users/TU_USUARIO/Desktop/mi_pantera.png` con la ruta completa a tu imagen.

---

## 🎨 Requisitos de la Imagen

Para que se vea mejor en la app:

### Formato:
- ✅ PNG con fondo transparente (recomendado)
- ✅ JPG también funciona

### Tamaño recomendado:
- **180x180 píxeles** para pantallas normales
- **360x360 píxeles** para pantallas retina (@2x)
- **540x540 píxeles** para pantallas retina HD (@3x)

### Estilo:
- 😊 Tierna y amigable
- 🎨 Colores que combinen con la paleta:
  - Verde oscuro: #005233
  - Teal: #2FA4B8
  - Aqua claro: #C3EDF4

---

## 🔍 Cómo Encontrar la Ruta de Tu Imagen

### En Mac:

1. Abre **Finder**
2. Localiza tu archivo `.png`
3. Haz clic derecho → "Get Info" (o presiona Cmd+I)
4. Copia la ruta que aparece en "Where:"

### O arrastra el archivo a Terminal:

1. Abre **Terminal**
2. Arrastra tu archivo `.png` a la ventana
3. Copia la ruta que aparece

---

## 📝 Ejemplo Completo

Si tu imagen está en:
```
/Users/iOS Lab UPMX/Documents/pantera_feliz.png
```

### Código en WelcomeView.swift:

```swift
VStack {
    let imagePath = "/Users/iOS Lab UPMX/Documents/pantera_feliz.png"
    
    if let uiImage = UIImage(contentsOfFile: imagePath) {
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
            .frame(width: 180, height: 180)
    } else {
        // Fallback
        Image(systemName: "pawprint.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .foregroundColor(.themePrimaryDarkGreen)
    }
}
```

---

## ✅ Verificación

Después de agregar tu imagen:

1. **Compila el proyecto**: Cmd+B
2. **Ejecuta en simulador**: Cmd+R
3. **Verifica** que tu imagen aparezca en la pantalla de bienvenida

Si ves la huella de pata (fallback), significa que la imagen no se encontró. Verifica:
- ✅ El nombre es correcto (sin .png al final si usas Assets)
- ✅ La ruta es correcta (si usas archivo externo)
- ✅ El archivo existe y tiene permisos de lectura

---

## 🎯 Resumen de Cambios

### Archivo: `WelcomeView.swift`

**ANTES:**
```swift
Text("seinsense.")
    .font(.system(size: 48, weight: .bold))

Image("panther_hi")
    .resizable()
```

**DESPUÉS:**
```swift
Text("SEISENSE")
    .font(.system(size: 48, weight: .bold))
    .tracking(1.5)

if let uiImage = UIImage(named: "your_panther_image") {
    Image(uiImage: uiImage)
        .resizable()
```

---

## 💡 Recomendación

Para mejor organización, **usa la Opción 1** (Assets.xcassets):
- ✅ Más fácil de manejar
- ✅ Soporta múltiples resoluciones automáticamente
- ✅ Se incluye en el bundle de la app
- ✅ Mejor rendimiento

---

## 🚀 ¿Necesitas Ayuda?

Si tienes problemas:

1. Verifica que el archivo `.png` exista
2. Revisa el nombre exacto (sensible a mayúsculas/minúsculas)
3. Asegúrate de que el proyecto compile sin errores
4. Ejecuta en simulador para ver el resultado

¡Listo! Ahora puedes usar tu propia imagen de pantera personalizada. 🐾
