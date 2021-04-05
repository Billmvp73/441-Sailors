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



@available(iOS 14.0, *)
class PopUpViewController: UIViewController,UIDocumentPickerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var modelnameText: UITextField!
    
    var modelname = ""
    var modelurl: URL!
    var newfilename = ""
    
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
        }, to: apiUrl, method: .post).response { response in
            switch (response.result) {
            case .success(let data):
                print("Imported!")
                guard let jsonObj = try? JSONSerialization.jsonObject(with: data!) as? [String:Any] else {
                    print("Import: failed JSON deserialization")
                    return
                }
                self.newfilename = jsonObj["filename"] as! String
            case .failure:
                print("Import failed")
            }
        }
        
        performSegue(withIdentifier: "ImportArInfo", sender: self)
        
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
        print("import result : \(myURL)")
    }
          

    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func get_type(url: URL) -> String{
        return url.pathExtension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! PuzzlesVC
        vc.model_name.append(self.modelname)
        vc.ar_url.append("https://174.138.33.66/media/"+self.newfilename+"."+self.get_type(url: self.modelurl))
        vc.list.append(self.newfilename)
        vc.model_files_name.append(self.newfilename+"."+self.get_type(url: self.modelurl))
    }
    
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

}
