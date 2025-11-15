import SwiftUI
import SceneKit

// MARK: - 3D Mood Jar with Real Physics
struct Mood3DJarView: View {
    let marbles: [MoodMarble]
    let isAnimated: Bool
    @State private var scene: SCNScene?
    
    init(marbles: [MoodMarble], isAnimated: Bool = true) {
        self.marbles = marbles
        self.isAnimated = isAnimated
    }
    
    var body: some View {
        ZStack {
            if let scene = scene {
                SceneKitView(scene: scene, isAnimated: isAnimated)
                    .frame(width: 300, height: 400)
            } else {
                ProgressView("Cargando tarro 3D...")
                    .frame(width: 300, height: 400)
            }
        }
        .onAppear {
            setupScene()
        }
    }
    
    private func setupScene() {
        let scene = SCNScene()
        
        // Setup camera
        setupCamera(in: scene)
        
        // Setup lighting
        setupLighting(in: scene)
        
        // Create glass jar
        createGlassJar(in: scene)
        
        // Add emotion spheres with physics
        addEmotionSpheres(in: scene)
        
        self.scene = scene
    }
    
    // MARK: - Camera Setup
    private func setupCamera(in scene: SCNScene) {
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 2, z: 8)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(cameraNode)
    }
    
    // MARK: - Lighting Setup (Soft Ambient + Spotlight)
    private func setupLighting(in scene: SCNScene) {
        // Ambient light (soft)
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.color = UIColor(white: 0.4, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLight)
        
        // Spotlight (accent glass shine)
        let spotlight = SCNNode()
        spotlight.light = SCNLight()
        spotlight.light?.type = .spot
        spotlight.light?.color = UIColor.white
        spotlight.light?.castsShadow = true
        spotlight.light?.shadowRadius = 3
        spotlight.light?.shadowColor = UIColor.black.withAlphaComponent(0.3)
        spotlight.light?.intensity = 1500
        spotlight.position = SCNVector3(x: 3, y: 5, z: 3)
        spotlight.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(spotlight)
        
        // Directional light (from back)
        let backLight = SCNNode()
        backLight.light = SCNLight()
        backLight.light?.type = .directional
        backLight.light?.color = UIColor(white: 0.3, alpha: 1.0)
        backLight.position = SCNVector3(x: -2, y: 3, z: -3)
        backLight.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(backLight)
    }
    
    // MARK: - Glass Jar Creation (True Glass Material)
    private func createGlassJar(in scene: SCNScene) {
        // Jar body (cylinder with rounded bottom)
        let jarBody = SCNNode()
        
        // Main cylinder
        let cylinderGeometry = SCNCylinder(radius: 1.5, height: 4.0)
        cylinderGeometry.radialSegmentCount = 48 // Smooth edges
        
        // Glass material with refraction
        let glassMaterial = SCNMaterial()
        glassMaterial.lightingModel = .physicallyBased
        
        // Transparency
        glassMaterial.transparency = 0.15
        glassMaterial.transparencyMode = .dualLayer
        
        // Note: SceneKit doesn't support direct IOR setting, but transparency + reflections simulate glass
        
        // Reflection (specular)
        glassMaterial.metalness.contents = 0.0
        glassMaterial.roughness.contents = 0.05 // Very smooth, shiny glass
        
        // Base color (slight blue tint)
        glassMaterial.diffuse.contents = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 0.2)
        
        cylinderGeometry.materials = [glassMaterial]
        jarBody.geometry = cylinderGeometry
        jarBody.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // Physics body for jar (static, concave shape for interior)
        let jarPhysicsShape = SCNPhysicsShape(
            geometry: cylinderGeometry,
            options: [.type: SCNPhysicsShape.ShapeType.concavePolyhedron]
        )
        jarBody.physicsBody = SCNPhysicsBody(type: .static, shape: jarPhysicsShape)
        jarBody.physicsBody?.restitution = 0.6 // Bounce factor
        jarBody.physicsBody?.friction = 0.3
        
        scene.rootNode.addChildNode(jarBody)
        
        // Jar bottom (hemisphere)
        let bottomGeometry = SCNSphere(radius: 1.5)
        bottomGeometry.segmentCount = 48
        let bottomMaterial = glassMaterial.copy() as! SCNMaterial
        bottomGeometry.materials = [bottomMaterial]
        
        let bottomNode = SCNNode(geometry: bottomGeometry)
        bottomNode.position = SCNVector3(x: 0, y: -2.0, z: 0)
        bottomNode.scale = SCNVector3(x: 1, y: 0.5, z: 1) // Flatten to hemisphere
        
        // Physics for bottom
        bottomNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        bottomNode.physicsBody?.restitution = 0.6
        bottomNode.physicsBody?.friction = 0.3
        
        scene.rootNode.addChildNode(bottomNode)
        
        // Metal lid (screw-top style)
        createMetalLid(in: scene)
    }
    
    // MARK: - Metal Lid
    private func createMetalLid(in scene: SCNScene) {
        let lidGeometry = SCNCylinder(radius: 1.7, height: 0.3)
        lidGeometry.radialSegmentCount = 48
        
        let metalMaterial = SCNMaterial()
        metalMaterial.lightingModel = .physicallyBased
        metalMaterial.diffuse.contents = UIColor(red: 0.55, green: 0.45, blue: 0.33, alpha: 1.0) // Bronze
        metalMaterial.metalness.contents = 0.8
        metalMaterial.roughness.contents = 0.3
        
        lidGeometry.materials = [metalMaterial]
        
        let lidNode = SCNNode(geometry: lidGeometry)
        lidNode.position = SCNVector3(x: 0, y: 2.3, z: 0)
        
        scene.rootNode.addChildNode(lidNode)
    }
    
    // MARK: - Emotion Spheres with Physics
    private func addEmotionSpheres(in scene: SCNScene) {
        // Enable physics world
        scene.physicsWorld.gravity = SCNVector3(x: 0, y: -9.8, z: 0) // Realistic gravity
        
        for (index, marble) in marbles.enumerated() {
            // Create sphere
            let sphereGeometry = SCNSphere(radius: 0.25)
            sphereGeometry.segmentCount = 32 // Smooth sphere
            
            // Emissive material with emoji texture
            let sphereMaterial = SCNMaterial()
            sphereMaterial.lightingModel = .physicallyBased
            
            // Color based on emotion
            let emotionColor = UIColor(Color(hex: marble.emotion.color))
            sphereMaterial.diffuse.contents = emotionColor
            
            // Emissive glow
            sphereMaterial.emission.contents = emotionColor.withAlphaComponent(0.5)
            sphereMaterial.emission.intensity = 0.8
            
            // Glossy surface
            sphereMaterial.metalness.contents = 0.2
            sphereMaterial.roughness.contents = 0.2
            
            // Add emoji as texture overlay
            if let emojiTexture = createEmojiTexture(emoji: marble.emotion.icon) {
                sphereMaterial.multiply.contents = emojiTexture
            }
            
            sphereGeometry.materials = [sphereMaterial]
            
            let sphereNode = SCNNode(geometry: sphereGeometry)
            
            // Random starting position above jar
            let randomX = Float.random(in: -0.8...0.8)
            let randomZ = Float.random(in: -0.8...0.8)
            let dropHeight = Float(3.0 + Double(index) * 0.3) // Stagger drops
            
            sphereNode.position = SCNVector3(x: randomX, y: dropHeight, z: randomZ)
            
            // Physics body (dynamic, rigid)
            sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: sphereGeometry, options: nil))
            sphereNode.physicsBody?.mass = 0.1
            sphereNode.physicsBody?.restitution = 0.7 // Bouncy
            sphereNode.physicsBody?.friction = 0.4
            sphereNode.physicsBody?.damping = 0.2 // Air resistance
            sphereNode.physicsBody?.angularDamping = 0.3 // Rotation damping
            
            // Add slight random impulse for natural fall
            let randomImpulse = SCNVector3(
                x: Float.random(in: -0.5...0.5),
                y: 0,
                z: Float.random(in: -0.5...0.5)
            )
            sphereNode.physicsBody?.applyForce(randomImpulse, asImpulse: true)
            
            scene.rootNode.addChildNode(sphereNode)
        }
    }
    
    // MARK: - Create Emoji Texture
    private func createEmojiTexture(emoji: String) -> UIImage? {
        let size = CGSize(width: 128, height: 128)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Clear background
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw emoji
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 100),
                .foregroundColor: UIColor.white
            ]
            
            let emojiString = emoji as NSString
            let emojiSize = emojiString.size(withAttributes: attributes)
            let emojiOrigin = CGPoint(
                x: (size.width - emojiSize.width) / 2,
                y: (size.height - emojiSize.height) / 2
            )
            
            emojiString.draw(at: emojiOrigin, withAttributes: attributes)
        }
    }
}

// MARK: - SceneKit View Wrapper
struct SceneKitView: UIViewRepresentable {
    let scene: SCNScene
    let isAnimated: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true // Enable rotation
        sceneView.autoenablesDefaultLighting = false // Use custom lighting
        sceneView.backgroundColor = .clear
        sceneView.isPlaying = isAnimated
        
        // Anti-aliasing for smooth rendering
        sceneView.antialiasingMode = .multisampling4X
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.isPlaying = isAnimated
    }
}

// MARK: - Preview
#Preview {
    let sampleMarbles = [
        MoodMarble(emotion: .happy, intensity: 0.8, position: MarblePosition()),
        MoodMarble(emotion: .sad, intensity: 0.6, position: MarblePosition()),
        MoodMarble(emotion: .anxious, intensity: 0.7, position: MarblePosition()),
        MoodMarble(emotion: .peaceful, intensity: 0.9, position: MarblePosition()),
        MoodMarble(emotion: .grateful, intensity: 0.8, position: MarblePosition()),
        MoodMarble(emotion: .excited, intensity: 0.7, position: MarblePosition()),
        MoodMarble(emotion: .angry, intensity: 0.5, position: MarblePosition()),
        MoodMarble(emotion: .stressed, intensity: 0.6, position: MarblePosition())
    ]
    
    Mood3DJarView(marbles: sampleMarbles, isAnimated: true)
        .background(Color.themeLightAqua)
}
