//
//  ViewController.swift
//  ARDiceRoll
//
//  Created by Dhiva Krishna on 9/11/19.
//  Copyright © 2019 Dhiva Krishna. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //debug check to see how it finds the plane :)
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        //creates a 6 sided object
//        //units are in meters
//        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
//
//        //Materials
//        let material = SCNMaterial()
//        //diffuse refers to pretty much the base color of the object
//        material.diffuse.contents = UIColor.blue
//        //This property takes an array of properties, so you can add more as needed
//        cube.materials = [material]
//
//        //creating scene nodes
//        let node = SCNNode()
//        //SCNVector3: is a 3D vector that has an X,Y,Z coordinate plane
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        node.geometry = cube
//
        
//        //Make the Earth appear as the sphere with a texture
//        let sphere = SCNSphere(radius: 0.3)
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_nightmap.jpg")
//        sphere.materials = [material]
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0.1, z: -0.5)
//        node.geometry = sphere
//        //Here we are adding a child node to our rootnode in our scene
//        //This is what displays the object into the scene
//        sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        // WorldTracking works with A9 and above
        let configuration = ARWorldTrackingConfiguration()
        
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    //This method is used to detect a horizontal plane
    //Anchor: is a real world position and orientation to place objects in an AR scene
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("plane detected")
            let planeAnchor = anchor as! ARPlaneAnchor
            
            //creates a plane, similar to how we create a cube or sphere or object
            //DONT USE THE Y PLANE
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            
            //we have to rotate the frame so that it works in the right direction since we are using X and Z planes
            //rotates counter lcockwise so use the negative to rotate it clockwise!
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            
            let materialGrid = SCNMaterial()
            materialGrid.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [materialGrid]
            
            planeNode.geometry = plane
            //sceneView.scene.rootNode.addChildNode(planeNode)
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //Delegate method that detects touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchResponse = touches.first {
            let touchLocation = touchResponse.location(in: sceneView) //Location expects a node, and we use our sceneView bc thats where the touch event is initiated
            
            //hittest searches for real world objects/anchors and takes the 2D point from the sceneView into a 3D coordinate
            //touchResults is an array type
            let touchResults = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = touchResults.first {
                //print(hitResult)
                // Create a new scene using ship.scn file
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
                //Recursively will keep looking through the childNodes till it finds the right node
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
        
                //World Transform is a 4x4 matrix of data that was given from our hitResult
                //The coordinates to place our object are in the 4th column
                diceNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x,
                                               y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                                               z: hitResult.worldTransform.columns.3.z)
                    
                sceneView.scene.rootNode.addChildNode(diceNode)
                }

            }
            
//            if !touchResults.isEmpty{
//                print("Touch detected on plane")
//            } else {
//                print("touched not on plane")
//            }
        }
    }

}
