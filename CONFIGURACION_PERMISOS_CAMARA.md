# 📷 Configuración de Permisos para Cámara

## ⚠️ IMPORTANTE: Permiso de Cámara Requerido

Para que la opción "Tomar foto" funcione, necesitas agregar la descripción de uso de cámara en el archivo `Info.plist`.

---

## 📝 Cómo Agregar el Permiso

### Opción 1: Desde Xcode (RECOMENDADO)

1. **Abre tu proyecto en Xcode**

2. **En el navigator izquierdo**, selecciona el archivo del proyecto (icono azul)

3. **Selecciona el target** "hackathonss"

4. **Ve a la pestaña "Info"**

5. **Busca o crea la sección "Custom iOS Target Properties"**

6. **Haz click en el botón "+"** para agregar una nueva propiedad

7. **En la lista desplegable**, busca:
   ```
   Privacy - Camera Usage Description
   ```
   O escribe directamente:
   ```
   NSCameraUsageDescription
   ```

8. **En el valor (Value)**, escribe:
   ```
   Necesitamos acceso a la cámara para tomar tu foto de perfil
   ```

9. **Guarda el proyecto** (Cmd + S)

---

### Opción 2: Editando Info.plist Directamente

Si prefieres editar el XML del Info.plist directamente:

1. **Localiza el archivo** `Info.plist` en tu proyecto

2. **Abre como código fuente** (Right-click → Open As → Source Code)

3. **Agrega estas líneas** dentro del `<dict>` principal:

```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para tomar tu foto de perfil</string>
```

**Ejemplo completo:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Otras configuraciones existentes -->
    
    <!-- ✨ AGREGAR ESTO: -->
    <key>NSCameraUsageDescription</key>
    <string>Necesitamos acceso a la cámara para tomar tu foto de perfil</string>
    
    <!-- Más configuraciones -->
</dict>
</plist>
```

---

## 🎯 ¿Por Qué es Necesario?

Apple requiere que **todas las apps que usan la cámara** expliquen al usuario **por qué** necesitan ese acceso.

Si NO agregas esta configuración:
- ❌ La app crasheará al intentar abrir la cámara
- ❌ No se mostrará el diálogo de permisos
- ❌ Error en consola: "This app has crashed because it attempted to access privacy-sensitive data..."

Con la configuración:
- ✅ Se muestra diálogo: "seinsense desea acceder a la cámara"
- ✅ Usuario ve tu mensaje: "Necesitamos acceso a la cámara para tomar tu foto de perfil"
- ✅ Usuario puede aceptar o rechazar
- ✅ Si acepta, la cámara funciona perfectamente

---

## 📋 Otros Permisos (NO Requeridos)

### Photo Library (Fototeca):
❌ **NO necesita permiso** porque usamos `PHPickerViewController` (iOS 14+)
- El sistema maneja todo automáticamente
- No requiere `NSPhotoLibraryUsageDescription`

### Files (Archivos):
❌ **NO necesita permiso** porque usamos `UIDocumentPickerViewController`
- El sistema maneja todo automáticamente
- No requiere permisos especiales

**Solo la cámara requiere configuración manual.**

---

## 🧪 Cómo Verificar que Funciona

### 1. Agrega el permiso en Info.plist

### 2. Ejecuta la app (Cmd + R)

### 3. Ve a ProfileEditView

### 4. Toca el avatar

### 5. Selecciona "Tomar foto"

### 6. **Primera vez:**
```
┌─────────────────────────────────┐
│ "seinsense" desea acceder a la  │
│ cámara                          │
│                                 │
│ Necesitamos acceso a la cámara  │
│ para tomar tu foto de perfil    │
│                                 │
│  [No Permitir]  [OK]            │
└─────────────────────────────────┘
```

### 7. Toca "OK"

### 8. ✅ La cámara se abre correctamente

---

## ⚙️ Gestión de Permisos

### Si el usuario rechaza el permiso:

1. La cámara NO se abrirá
2. El picker se cerrará automáticamente
3. Usuario debe ir a Settings para activar

### Para reactivar el permiso:

```
iPhone Settings
  ↓
[Tu App: "seinsense"]
  ↓
Camera → Toggle ON
```

---

## 🔧 Mensaje Personalizable

Puedes cambiar el mensaje a tu preferencia:

**Opciones de mensaje:**
```
"Toma tu foto de perfil con la cámara"
"Usa la cámara para tu avatar"
"Necesitamos la cámara para capturar tu foto"
"Personaliza tu perfil con una foto desde la cámara"
```

**Idiomas múltiples:**

Si quieres soportar múltiples idiomas, necesitas archivos de localización:
- `InfoPlist.strings` (es)
- `InfoPlist.strings` (en)

Ejemplo para español:
```
"NSCameraUsageDescription" = "Necesitamos acceso a la cámara para tomar tu foto de perfil";
```

---

## ✅ Checklist de Configuración

- [ ] Abrir proyecto en Xcode
- [ ] Agregar `NSCameraUsageDescription` en Info.plist
- [ ] Escribir mensaje descriptivo
- [ ] Guardar cambios
- [ ] Ejecutar app (Cmd + R)
- [ ] Probar opción "Tomar foto"
- [ ] Verificar que aparece diálogo de permisos
- [ ] Aceptar permiso
- [ ] Verificar que cámara funciona
- [ ] ✅ Todo listo

---

## 📱 Ejemplo Visual

### ANTES de agregar permiso:
```
Usuario toca "Tomar foto"
    ↓
❌ APP CRASH
❌ Error: "privacy-sensitive data without permission"
```

### DESPUÉS de agregar permiso:
```
Usuario toca "Tomar foto"
    ↓
✅ Aparece diálogo de permiso
    ↓
Usuario acepta
    ↓
✅ Cámara se abre
    ↓
Usuario toma foto
    ↓
✅ Foto guardada en perfil
```

---

## 🎉 ¡Listo!

Con esta configuración, las **3 opciones de foto de perfil** funcionarán perfectamente:

1. ✅ **Fototeca** - Sin configuración adicional
2. ✅ **Tomar foto** - Requiere NSCameraUsageDescription
3. ✅ **Seleccionar archivo** - Sin configuración adicional

**¡Solo falta agregar el permiso de cámara y todo funcionará!** 📸✨
