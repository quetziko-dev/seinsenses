# 🏥 Configuración de Permisos HealthKit para Sueño

## ⚠️ IMPORTANTE: Configuración Requerida

Para que el servicio de sueño funcione con HealthKit, necesitas agregar permisos en `Info.plist` y habilitar HealthKit capability.

---

## 📝 Paso 1: Agregar Capability en Xcode

### A. Habilitar HealthKit:

1. **Abre tu proyecto en Xcode**
2. **Selecciona el target** "hackathonss"
3. **Ve a la pestaña "Signing & Capabilities"**
4. **Click en "+ Capability"**
5. **Busca y agrega "HealthKit"**
6. ✅ Verás que aparece "HealthKit" en la lista de capabilities

---

## 📝 Paso 2: Agregar Permisos en Info.plist

### Opción 1: Desde Xcode (RECOMENDADO)

1. **Selecciona el archivo Info.plist** en el navigator
2. **Agrega las siguientes claves:**

```
Privacy - Health Share Usage Description
Privacy - Health Update Usage Description
```

3. **Para cada una, agrega el valor:**

```
Privacy - Health Share Usage Description:
"Necesitamos acceso a tus datos de sueño para mostrarte tu progreso de descanso"

Privacy - Health Update Usage Description:
"No escribimos datos, solo leemos tu información de sueño"
```

---

### Opción 2: Editar Info.plist como XML

Si prefieres editar el XML directamente:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Otras configuraciones existentes -->
    
    <!-- ✨ AGREGAR PERMISOS DE HEALTHKIT: -->
    <key>NSHealthShareUsageDescription</key>
    <string>Necesitamos acceso a tus datos de sueño para mostrarte tu progreso de descanso</string>
    
    <key>NSHealthUpdateUsageDescription</key>
    <string>No escribimos datos, solo leemos tu información de sueño</string>
    
    <!-- Más configuraciones -->
</dict>
</plist>
```

---

## 🎯 ¿Por Qué es Necesario?

Apple requiere que **todas las apps que usan HealthKit** expliquen:
1. **Qué datos van a leer** (NSHealthShareUsageDescription)
2. **Qué datos van a escribir** (NSHealthUpdateUsageDescription)

En nuestro caso:
- ✅ **Solo LEEMOS** datos de sueño (HKCategoryTypeIdentifier.sleepAnalysis)
- ❌ **NO ESCRIBIMOS** datos (pero Apple requiere la descripción de todos modos)

---

## 🔐 Permisos que Solicitamos

### Tipos de Datos HealthKit:

```swift
// En SleepService.swift:
let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
let typesToRead: Set<HKObjectType> = [sleepType]

healthStore.requestAuthorization(
    toShare: nil,        // ❌ NO escribimos
    read: typesToRead    // ✅ Solo leemos sueño
)
```

**Datos que LEEMOS:**
- ✅ Análisis de sueño (.sleepAnalysis)
  - Hora de dormir
  - Hora de despertar
  - Estado: dormido, en cama, despierto

**Datos que NO tocamos:**
- ❌ Actividad física
- ❌ Frecuencia cardíaca
- ❌ Pasos
- ❌ Otros datos de salud

---

## 🚫 LO QUE NO HACEMOS

### ⚠️ IMPORTANTE - Limitaciones de iOS:

**NO accedemos a:**
- ❌ "Última vez que el usuario usó el teléfono"
- ❌ Screen Time data
- ❌ Uso de apps individuales
- ❌ Tiempo de pantalla global

**¿Por qué NO?**
- iOS **NO ofrece una API pública** para acceder a estos datos
- Screen Time está completamente sandboxed
- Solo el usuario puede ver sus datos de Screen Time en Configuración
- **No hay forma confiable** de obtener esta información

**Nuestra solución:**
1. **HealthKit** como fuente principal (oficial, confiable, preciso)
2. **Entrada manual** como fallback (simple, no intrusivo)

---

## 🧪 Cómo Verificar que Funciona

### 1. Agrega los permisos en Info.plist

### 2. Habilita HealthKit capability

### 3. Ejecuta la app (Cmd + R)

### 4. Cuando se solicite permiso de HealthKit:

```
┌─────────────────────────────────────┐
│ "seinsense" desea acceder a:        │
│                                     │
│ ✓ Sueño                             │
│                                     │
│ Necesitamos acceso a tus datos de   │
│ sueño para mostrarte tu progreso    │
│                                     │
│  [No Permitir]  [Permitir]          │
└─────────────────────────────────────┘
```

### 5. Toca "Permitir"

### 6. ✅ El servicio puede leer datos de sueño

---

## 📱 Gestión de Permisos

### Si el usuario deniega el permiso:

La app automáticamente usa **entrada manual** como fallback:
- No se rompe la funcionalidad
- Usuario puede registrar manualmente su sueño
- Mensaje amigable: "Registra tu hora de dormir manualmente"

### Para reactivar HealthKit:

```
iPhone Settings
  ↓
Salud (Health)
  ↓
Compartir datos
  ↓
Apps
  ↓
seinsense
  ↓
Activar "Sueño"
```

---

## 🔄 Flujo Completo de Permisos

```
App solicita permiso HealthKit
    ↓
┌─────────────────────────────┐
│ Usuario acepta              │
│    ↓                        │
│ ✅ SleepService.fetch...    │
│    ↓                        │
│ Datos de Salud              │
│    ↓                        │
│ source = .healthKit         │
└─────────────────────────────┘

┌─────────────────────────────┐
│ Usuario rechaza             │
│    ↓                        │
│ ⚠️ SleepService devuelve nil│
│    ↓                        │
│ Vista muestra entrada manual│
│    ↓                        │
│ Usuario registra horas      │
│    ↓                        │
│ source = .manual            │
└─────────────────────────────┘
```

---

## ✅ Checklist de Configuración

- [ ] Xcode → Target → Signing & Capabilities
- [ ] Agregar "HealthKit" capability
- [ ] Agregar `NSHealthShareUsageDescription` en Info.plist
- [ ] Agregar `NSHealthUpdateUsageDescription` en Info.plist
- [ ] Escribir mensajes descriptivos
- [ ] Guardar cambios
- [ ] Ejecutar app (Cmd + R)
- [ ] Probar solicitud de permisos
- [ ] Verificar que SleepService funciona
- [ ] Probar fallback manual si se deniega
- [ ] ✅ Todo listo

---

## 📊 Ejemplo de Mensajes

### Sugerencias de Texto para Info.plist:

**NSHealthShareUsageDescription (español):**
```
"Necesitamos acceso a tus datos de sueño para mostrarte tu progreso de descanso y ayudarte a mejorar tu bienestar"
```

**NSHealthShareUsageDescription (inglés):**
```
"We need access to your sleep data to show your rest progress and help improve your wellness"
```

**NSHealthUpdateUsageDescription (español):**
```
"No modificamos tus datos de salud, solo los leemos para tu beneficio"
```

**NSHealthUpdateUsageDescription (inglés):**
```
"We don't modify your health data, we only read it for your benefit"
```

---

## 🎉 Resultado Final

Con esta configuración:

✅ **HealthKit habilitado** - Capability agregado  
✅ **Permisos configurados** - Info.plist actualizado  
✅ **Solo lectura** - No escribimos datos  
✅ **Sueño únicamente** - Solo .sleepAnalysis  
✅ **Fallback manual** - Si usuario deniega  
✅ **No intrusivo** - NO accedemos a Screen Time  
✅ **Seguro** - Solo datos que el usuario autorice  

**¡El sistema de sueño con HealthKit está configurado correctamente!** 🏥✨
