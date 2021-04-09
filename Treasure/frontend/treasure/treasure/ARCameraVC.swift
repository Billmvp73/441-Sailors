//
//  CameraVC.swift
//  treasure
//
//  Created by pyhuang on 3/27/21.
//

import UIKit
import SceneKit
import AVFoundation
import CoreLocation

protocol ARCameraDelegate: UIViewController {
    func onReturn(_ result: Puzzle)
}
//
//protocol ReturnDelegate: UIViewController {
//    func onReturn(_ result: Puzzle)
//}

class ARCameraVC: UIViewController{
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var leftIndicator: UILabel!
    @IBOutlet weak var rightIndicator: UILabel!
    var cameraSession: AVCaptureSession?
    var cameraLayer: AVCaptureVideoPreviewLayer?
    var target: ARItem!
    var locationManger = CLLocationManager()
    var heading: Double = 0
    var userLocation = CLLocation()
//    var puzzles: [Puzzle]?
    var puzzleTarget: Puzzle?
    weak var arCameraDelegate: ARCameraDelegate?
//    var secondsRemaining = 5
//    @IBOutlet weak var countDownTimer: UILabel!
//    var timer: Timer?
    let scene = SCNScene()
    let cameraNode = SCNNode()
    let targetNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
    
    override func viewDidLoad() {
      super.viewDidLoad()
      
      loadCamera()
      self.cameraSession?.startRunning()
      self.locationManger.delegate = self
      self.locationManger.startUpdatingHeading()
//      loadCamera()
      sceneView.scene = scene
      cameraNode.camera = SCNCamera()
      cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
      scene.rootNode.addChildNode(cameraNode)
      target = ARItem(itemDescription: "", location: CLLocation(latitude: 0, longitude: 0), itemNode: nil)
      // failed to handle word type puzzle
      let isTarget = setupTarget()
        if isTarget == false{
        self.navigationController?.popViewController(animated: true)
      }
    }
    
    override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    }
    
    func createCaptureSession() -> (session: AVCaptureSession?, error: NSError?) {
      var error: NSError?
      var captureSession: AVCaptureSession?
      
      let backVideoDevice = AVCaptureDevice.default( .builtInWideAngleCamera, for: AVMediaType.video, position: .back)
      
      if backVideoDevice != nil {
        var videoInput: AVCaptureDeviceInput!
        do {
          videoInput = try AVCaptureDeviceInput(device: backVideoDevice!)
        } catch let error1 as NSError {
          error = error1
          videoInput = nil
        }
        
        if error == nil {
          captureSession = AVCaptureSession()
          
          if captureSession!.canAddInput(videoInput) {
            captureSession!.addInput(videoInput)
          } else {
            error = NSError(domain: "", code: 0, userInfo: ["description": "Error adding video input."])
          }
        } else {
          error = NSError(domain: "", code: 1, userInfo: ["description": "Error creating capture device input."])
        }
      } else {
        error = NSError(domain: "", code: 2, userInfo: ["description": "Back video device not found."])
      }
      
      return (session: captureSession, error: error)
    }
    
    func loadCamera() {
      let captureSessionResult = createCaptureSession()
      
      guard captureSessionResult.error == nil, let session = captureSessionResult.session else {
        print("Error creating capture session")
        return
      }
      
      self.cameraSession = session
      let cameraLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession!)
      cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
      cameraLayer.frame = self.view.bounds
      self.view.layer.insertSublayer(cameraLayer, at: 0)
      self.cameraLayer = cameraLayer
    }
    
    func repositionTarget() {
      let heading = getHeadingForDirectionFromCoordinate(from: userLocation, to: target.location)
      
      let delta = heading - self.heading
      
      if delta < -15.0 {
        leftIndicator.isHidden = false
        rightIndicator.isHidden = true
      } else if delta > 15 {
        leftIndicator.isHidden = true
        rightIndicator.isHidden = false
      } else {
        leftIndicator.isHidden = true
        rightIndicator.isHidden = true
      }
      
        let distance = userLocation.distance(from: target.location)
      
      if let node = target.itemNode {
        if node.parent == nil {
          node.position = SCNVector3(x: Float(delta), y: 0, z: Float(-distance))
          scene.rootNode.addChildNode(node)
        } else {
          node.removeAllActions()
          node.runAction(SCNAction.move(to: SCNVector3(x: Float(delta), y: 0, z: Float(-distance)), duration: 0.2))
        }
      }
    }
    
    func radiansToDegrees(_ radians: Double) -> Double {
      return (radians) * (180.0 / Double.pi)
    }
    
    func degreesToRadians(_ degrees: Double) -> Double {
      return (degrees) * (Double.pi / 180.0)
    }
    
    func getHeadingForDirectionFromCoordinate(from: CLLocation, to: CLLocation) -> Double {
      let fLat = degreesToRadians(from.coordinate.latitude)
      let fLng = degreesToRadians(from.coordinate.longitude)
      let tLat = degreesToRadians(to.coordinate.latitude)
      let tLng = degreesToRadians(to.coordinate.longitude)
      
      let degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)))
      
      if degree >= 0 {
        return degree
      } else {
        return degree + 360
      }
    }

    func setupTarget() -> Bool?{
//        let puzzle = puzzles?.popLast()
        if let puzzle = self.puzzleTarget{
            if let itemDescription = puzzle.type{
    //            let scene = SCNScene(named: "art.scnassets/\(itemDescription).usdz")

                let scene = SCNScene(named: "art.scnassets/\(itemDescription).usdz")
                let lightNode = SCNNode()
                lightNode.light = SCNLight()
                lightNode.light?.type = .omni
                lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
                scene?.rootNode.addChildNode(lightNode)
                
                // 6: Creating and adding ambien light to scene
                let ambientLightNode = SCNNode()
                ambientLightNode.light = SCNLight()
                ambientLightNode.light?.type = .ambient
                ambientLightNode.light?.color = UIColor.darkGray
                scene?.rootNode.addChildNode(ambientLightNode)
    //            let enemy = scene?.rootNode.childNode(withName: "toy_car", recursively: true)
    //            if itemDescription == "car" {
    //              enemy?.position = SCNVector3(x: 0, y: -15, z: 0)
    //            } else {
    //              enemy?.position = SCNVector3(x: 0, y: 0, z: 0)
    //            }
                let node = SCNNode()
                let nodeArray = scene!.rootNode.childNodes
                for childNode in nodeArray{
                    node.addChildNode(childNode as SCNNode)
                }
                node.position = SCNVector3(x:0, y: 0, z:0)
    //            enemy.position = SCNVector3(x: 0, y: 0, z: 0)
    //            let node = SCNNode()
    //            node.addChildNode(enemy!)
                node.name = "puzzle"
                self.target.itemDescription = itemDescription
                self.target.itemNode = node
                if let geodata = puzzle.location{
                    self.target.location = CLLocation(latitude: geodata.lat, longitude: geodata.lon)
    //                self.target.location = CLLocation(latitude: 42.30099599327609, longitude: -83.71567403950316)
                }
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func completePuzzle(){
        
    }
    
//    @objc func updateCounting(){
//        if self.secondsRemaining > 0{
//            self.countDownTimer.text = "\(self.secondsRemaining)s"
//            self.secondsRemaining-=1
//        }else{
//            self.navigationController?.popViewController(animated: true)
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      //1
      let touch = touches.first!
      let location = touch.location(in: sceneView)
      let hitResult = sceneView.hitTest(location, options: nil)
      let fireBall = SCNParticleSystem(named: "Fireball.scnp", inDirectory: nil)
      
      let emitterNode = SCNNode()
      emitterNode.position = SCNVector3(x: 0, y: -5, z: 10)
      emitterNode.addParticleSystem(fireBall!)
      scene.rootNode.addChildNode(emitterNode)
      
      if hitResult.first != nil {
        target.itemNode?.runAction(SCNAction.sequence([SCNAction.wait(duration: 0.5), SCNAction.removeFromParentNode(), SCNAction.hide()]))
        let sequence = SCNAction.sequence(
          [SCNAction.move(to: target.itemNode!.position, duration: 0.5),
           SCNAction.wait(duration: 3.5),
            SCNAction.run({_ in
                DispatchQueue.main.async {
                    self.sceneView.scene?.rootNode.enumerateChildNodes { (node, _ ) in
                    node.removeFromParentNode()
                      }
                    let alert = UIAlertController(title: "Congratulations!", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {_ in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            self.dismiss(animated: true, completion: nil)
                            self.arCameraDelegate?.onReturn(self.puzzleTarget!)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })])
        emitterNode.runAction(sequence)
      } else {

        emitterNode.runAction(SCNAction.move(to: SCNVector3(x: 0, y: 0, z: -30), duration: 0.5))
      }
    }
  }

extension ARCameraVC: CLLocationManagerDelegate {
func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
  self.heading = fmod(newHeading.trueHeading, 360.0)
  repositionTarget()
}
}
