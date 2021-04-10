//
//  PopUpViewController.swift
//  treasure
//
//  Created by xinyun shen on 4/4/21.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import Alamofire
import SceneKit


protocol PopUpReturnDelegate: UIViewController {
    func onReturn(_ modelname: String, _ arurl: String, _ modelfile_name: String)
}

@available(iOS 14.0, *)
class PopUpViewController: UIViewController,UIDocumentPickerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var modelnameText: UITextField!
    @IBOutlet weak var sceneView: SCNView!
    
    var modelname = ""
    var modelurl: URL!
    var newfilename = ""
    weak var popUpReturnDelegate: PopUpReturnDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        // Do any additional setup after loading the view.
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
    }
    
    @IBAction func submitModel(_ sender: Any) {
        self.modelname = modelnameText.text!
        
        guard let apiUrl = URL(string: "https://174.138.33.66/uploadar/") else {
            print("Imported: Bad URL")
            return
        }
        
        AF.upload(multipartFormData: { mpFD in
            if let token = UserID.shared.token?.data(using: .utf8) {
                mpFD.append(token, withName: "token")
            }
            if let name = self.modelname.data(using: .utf8) {
                mpFD.append(name, withName: "name")
            }
            mpFD.append(self.modelurl, withName: "ar")
            mpFD.append(self.get_type(url: self.modelurl).data(using: .utf8)!, withName: "type")
        }, to: apiUrl, method: .post).response { [self] response in
            switch (response.result) {
            case .success(let data):
                print("Imported!")
                guard let jsonObj = try? JSONSerialization.jsonObject(with: data!) as? [String:Any] else {
                    print("Import: failed JSON deserialization")
                    return
                }
                self.newfilename = jsonObj["filename"] as! String
                let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
                let filePath = cache?.appendingPathComponent(self.newfilename)
                do{
                    try FileManager.default.moveItem(atPath: self.modelurl.path,
                                                     toPath: filePath!.path)
                } catch{
                    print(error.localizedDescription)
                }
                popUpReturnDelegate?.onReturn(self.modelname, "https://174.138.33.66/media/"+self.newfilename, self.newfilename)
                dismiss(animated: true, completion: nil)
//                self.removeAnimate()
//                self.performSegue(withIdentifier: "ImportArInfo", sender: self)
            case .failure:
                print("Import failed")
            }
        }
    }
    
    func showAr(name: URL) {
//    func showAr() {
//        let downloadedScenePath = getDocumentsDirectory().appendingPathComponent(name)
//        print("local file path \(downloadedScenePath)")
        do {
            let scene = try SCNScene(url: name, options: nil)
//            let scene = try SCNScene(url: downloadedScenePath, options: nil)
            
    //        let scene = SCNScene(named: name)
            // 2: Add camera node
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            // 3: Place camera
            cameraNode.position = SCNVector3(x: 0, y: 10, z: 35)
            // 4: Set camera on scene
            scene.rootNode.addChildNode(cameraNode)
            
            // 5: Adding light to scene
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.position = SCNVector3(x: 0, y: 10, z: 35)
            scene.rootNode.addChildNode(lightNode)
            
            // 6: Creating and adding ambien light to scene
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light?.type = .ambient
            ambientLightNode.light?.color = UIColor.darkGray
            scene.rootNode.addChildNode(ambientLightNode)
            
                    
            // If you don't want to fix manually the lights
        //        sceneView.autoenablesDefaultLighting = true
            
            // Allow user to manipulate camera
            sceneView.allowsCameraControl = true
            
            // Show FPS logs and timming
            // sceneView.showsStatistics = true
            
            // Set background color
            sceneView.backgroundColor = UIColor.white
            
            // Allow user translate image
            sceneView.cameraControlConfiguration.allowsTranslation = false
            
            // Set scene settings
            sceneView.scene = scene
        } catch  {
            print("Error Loading Scene")
        }
    }
    
    func selectFiles() {
        let types = UTType.types(tag: "json",
                                 tagClass: UTTagClass.filenameExtension,
                                 conformingTo: nil)
        let documentPickerController = UIDocumentPickerViewController(
                forOpeningContentTypes: types)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        modelurl = myURL
        self.showAr(name: modelurl)
        print("import result : \(myURL)")
    }
          

    public func documentMenu(_ documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
//        dismiss(animated: true, completion: nil)
//        self.performSegue(withIdentifier: "ImportArInfo", sender: self)
        self.removeAnimate()
    }
    
    
    
    func get_type(url: URL) -> String{
        return url.pathExtension
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as! PuzzlesVC
//        if self.modelname != ""{
//            vc.model_name.append(self.modelname)
//            vc.ar_url.append("https://174.138.33.66/media/"+self.newfilename)
//            vc.list.append(self.newfilename)
//            vc.model_files_name.append(self.newfilename)
//        }
//    }
    
    @IBAction func closePopUp(_ sender: Any) {
        self.removeAnimate()
//        self.view.removeFromSuperview()
    }
    
    func showAnimate()
        {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            UIView.animate(withDuration: 0.25, animations: {
                self.view.alpha = 1.0
                self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            });
        }
        
        func removeAnimate()
        {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                self.view.alpha = 0.0;
                }, completion:{(finished : Bool)  in
                    if (finished)
                    {
                        self.view.removeFromSuperview()
                    }
            });
        }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            // Do any additional setup after loading the view.
            let importMenu = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
                importMenu.delegate = self
                importMenu.modalPresentationStyle = .formSheet
                self.present(importMenu, animated: true, completion: nil)
        }
}
