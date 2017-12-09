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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]

        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        // Set the scene to the view
//        sceneView.scene = scene
    
        addRandomObjs()
        
        loadAudioAssets()
    }
    
    func randFloat() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    func randColour() -> UIColor {
        return UIColor.init(red: randFloat(), green: randFloat(), blue: randFloat(), alpha: 1)
    }
    
    func addRandomObjs() {
        for x in -5...5 {
            for y in -5...5 {
                for z in -5...5 {
                    let node = SCNNode.init(geometry: SCNSphere.init(radius: 0.08))
                    node.geometry?.firstMaterial?.diffuse.contents = randColour()
                    let shrink = Float(0.4)
                    node.position = SCNVector3(shrink*Float(x), shrink*Float(y), shrink*Float(z))
                    sceneView.scene.rootNode.addChildNode(node)
                }
            }
        }
    }
    
    var testAudioSource: SCNAudioSource!
    func loadAudioAssets() {
        testAudioSource = SCNAudioSource.init(named: "art.scnassets/beltHandle1.mp3")
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

        print(pov.position)
        
        if pov.position.y > 0.15 && deltaPosition.y > 0 {
            print("play audio")
            let audio = SCNAudioPlayer.init(source: testAudioSource)
            pov.addAudioPlayer(audio)
        }
        
    }
}
