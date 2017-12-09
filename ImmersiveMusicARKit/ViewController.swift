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
        
        let povCollisionSphere = SCNNode.init(geometry:SCNSphere.init(radius: 0.04))
        povCollisionSphere.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        //when uncommented, its centered on the POV itself, making the device a percussion instrument.
//        povCollisionSphere.position = SCNVector3(0, 0, -0.5)
        povCollisionSphere.physicsBody = SCNPhysicsBody.init(type: SCNPhysicsBodyType.kinematic, shape: nil)
        povCollisionSphere.physicsBody?.categoryBitMask = 1
        povCollisionSphere.physicsBody?.collisionBitMask = 1
        povCollisionSphere.physicsBody?.contactTestBitMask = 1
        povCollisionSphere.name = "povCollisionSphere"
        sceneView.pointOfView?.addChildNode(povCollisionSphere)
    }
    
    func randFloat() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    func randColour() -> UIColor {
        return UIColor.init(red: randFloat(), green: randFloat(), blue: randFloat(), alpha: 1)
    }
    
    func addRandomObjs() {
        var lickIndex = 0
        for x in -5...5 {
            for y in -5...5 {
                for z in -5...5 {
                    if x == 0 && y == 0 && z == 0 {
                        //IGNORE THE START POSITION
                        continue
                    }
                    
                    let node = Instrument.init(audioSource: lickAudioSources[lickIndex])
                    node.geometry = SCNSphere.init(radius: 0.04)
                    node.geometry?.firstMaterial?.diffuse.contents = randColour()
                    let shrink = Float(0.4)
                    node.position = SCNVector3(shrink*Float(x), shrink*Float(y), shrink*Float(z))
                    node.physicsBody = SCNPhysicsBody.init(type: SCNPhysicsBodyType.kinematic, shape: nil)
                    node.physicsBody?.categoryBitMask = 1
                    node.physicsBody?.collisionBitMask = 1
                    node.physicsBody?.contactTestBitMask = 1
                    node.name = "instrument"
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
        }
        
    }
}
