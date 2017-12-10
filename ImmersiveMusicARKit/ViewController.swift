//
//  ViewController.swift
//  ImmersiveMusicARKit
//
//  Created by Dustin Freeman on 2017-12-09.
//  Copyright © 2017 Dustin Freeman. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ModelIO
import SceneKit.ModelIO

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
    
        loadAudioAssets()
        
        addRandomObjs()
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
        let povCollisionSphere = SCNNode.init(geometry:SCNSphere.init(radius: 0.08))
        povCollisionSphere.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        //when uncommented, its centered on the POV itself, making the device a percussion instrument.
//        povCollisionSphere.position = SCNVector3(0, 0, -0.5)
        povCollisionSphere.physicsBody = SCNPhysicsBody.init(type: SCNPhysicsBodyType.kinematic, shape: nil)
        povCollisionSphere.physicsBody?.categoryBitMask = 1
        povCollisionSphere.physicsBody?.collisionBitMask = 1
        povCollisionSphere.physicsBody?.contactTestBitMask = 1
        povCollisionSphere.name = "povCollisionSphere"
        sceneView.pointOfView?.addChildNode(povCollisionSphere)
        
        //"jazz lighting"
        let lightNode = SCNNode.init()
        sceneView.scene.rootNode.addChildNode(lightNode)
        lightNode.position = SCNVector3(10, 0, 10)
        lightNode.eulerAngles = SCNVector3(Float.pi, 0, 0)
        let light = SCNLight.init()
        lightNode.light = light
        light.type = .directional
        light.intensity = 1000
        light.color = UIColor.red

        let lightNode2 = SCNNode.init()
        sceneView.scene.rootNode.addChildNode(lightNode2)
        lightNode2.position = SCNVector3(-10, -10, 0)
        let light2 = SCNLight.init()
        lightNode2.light = light2
        light2.type = .directional
        light2.intensity = 500
        light2.color = UIColor.white
    }
    
    func randFloat() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    func randColour() -> UIColor {
        return UIColor.init(red: randFloat(), green: randFloat(), blue: randFloat(), alpha: 1)
    }
    
    func loadSax() -> SCNNode {
        guard let url = Bundle.main.url(forResource:"art.scnassets/Saxophone_01", withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }
        
        let asset = MDLAsset.init(url: url)
        let object = asset.object(at:0)
//        guard let object = asset.object(at:0) /*as? MDLMesh*/ else {
//            fatalError("Failed to get mesh from asset.")
//        }
        let node = SCNNode(mdlObject: object)
        node.scale = SCNVector3(0.006, 0.006, 0.006)
        return node
//        return SCNNode.init()
    }
    
    func addRandomObjs() {
        var lickColours: [UIColor] = []
        for _ in 0..<lickAudioSources.count {
            lickColours.append(randColour())
        }
        
        let sax = loadSax()
        
        var lickIndex = 0
        for x in -5...5 {
            for y in -1...(-1) {
                for z in -5...5 {
                    if x == 0 && y == 0 && z == 0 {
                        //IGNORE THE START POSITION
                        continue
                    }
                    
                    let node = Instrument.init(audioSource: lickAudioSources[lickIndex])
                    
                    node.geometry = sax.geometry?.copy() as? SCNGeometry
                    node.scale = sax.scale
                    node.eulerAngles = SCNVector3(0,Float.pi, 0)
                    for i in 0..<node.geometry!.materials.count {
                        node.geometry?.materials[i] = node.geometry?.materials[i].copy() as! SCNMaterial
                    }
                    
                    for m in node.geometry!.materials {
                        m.diffuse.contents = lickColours[lickIndex]
                    }
                    let shrink = Float(0.15)
                    node.position = SCNVector3(x, y, z) * shrink
                    let physicsGeometry = SCNSphere.init(radius: CGFloat(node.boundingSphere.radius * node.scale.x))
                    let physicsShape = SCNPhysicsShape.init(geometry: physicsGeometry, options: nil)
                    node.physicsBody = SCNPhysicsBody.init(type: SCNPhysicsBodyType.kinematic, shape: physicsShape)
                    node.physicsBody?.categoryBitMask = 1
                    node.physicsBody?.collisionBitMask = 1
                    node.physicsBody?.contactTestBitMask = 1
                    node.name = "instrument"
                    if let particleSystem = SCNParticleSystem.init(named: "PlayingParticleSystem.scnp", inDirectory: "art.scnassets") {
                        particleSystem.particleColor = lickColours[lickIndex]
                        particleSystem.birthRate = 0
                        node.addParticleSystem(particleSystem)
                    }
                    sceneView.scene.rootNode.addChildNode(node)
                    
                    lickIndex = (lickIndex + 1) % lickAudioSources.count
                }
            }
        }
    }
    
    var testAudioSource: SCNAudioSource!
    var backBeatAudioSource: SCNAudioSource!
    var lickAudioSources: [SCNAudioSource] = []
    func loadAudioAssets() {
        testAudioSource = SCNAudioSource.init(named: "art.scnassets/beltHandle1.mp3")
        backBeatAudioSource = SCNAudioSource.init(named: "art.scnassets/Breakbeat-135.aif")
        backBeatAudioSource.loops = true
        
        let lickFiles = ["Breakbeat Paradise Sample - Bigband Horns 04.mp3",
                         "Breakbeat Paradise Sample - Bigband Horns 06.mp3",
                         "Breakbeat Paradise Sample - Bigband Horns 08.mp3",
                         "Breakbeat Paradise Sample - Jazzy Saxlines   02.mp3",
                         "Breakbeat Paradise Sample - Jazzy Saxlines   04.mp3",
                         "Breakbeat Paradise Sample - Jazzy Saxlines   05.mp3",
                         "Breakbeat Paradise Sample - Jazzy Saxlines   06.mp3"]
        for file in lickFiles {
            guard let source = SCNAudioSource.init(named: "art.scnassets/" + file) else {
                continue
            }
            lickAudioSources.append(source)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        toggleBackBeat()
    }
    
    func toggleBackBeat() {
        guard let pov = sceneView?.pointOfView else {
            return
        }
        
        if pov.audioPlayers.count > 0 {
            pov.removeAllAudioPlayers()
            return
        }
        
        let backBeatPlayer = SCNAudioPlayer.init(source: backBeatAudioSource)
        pov.addAudioPlayer(backBeatPlayer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let pov = sceneView.pointOfView else {
            return
        }
        
        struct LastTime {
            static var position: SCNVector3 = SCNVector3Zero
        }
        
        let deltaPosition = pov.position - LastTime.position
        LastTime.position = pov.position
//        print(pov.position)
        
//        if pov.position.y > 0.15 && deltaPosition.y > 0 {
//            let audio = SCNAudioPlayer.init(source: testAudioSource)
//            pov.addAudioPlayer(audio)
//        }
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("contact " + String.init(describing:contact.nodeA.name) + " <-> " + String.init(describing:contact.nodeB.name))
        
        let instrument = contact.nodeA is Instrument ? contact.nodeA as? Instrument : contact.nodeB as? Instrument
        
        //interrupt other playback
        instrument?.removeAllAudioPlayers()

        if let source = instrument?.audioSource {
            let audio = SCNAudioPlayer.init(source: source)
            instrument?.addAudioPlayer(audio)
            
            if let particleSystem = instrument?.particleSystems?.first {
                particleSystem.birthRate = 50
                audio.didFinishPlayback = {
                    particleSystem.birthRate = 0
                }
            }
        }
        
    }
}
