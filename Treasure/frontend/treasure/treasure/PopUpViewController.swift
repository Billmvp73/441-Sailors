//
//  PopUpViewController.swift
//  treasure
//
//  Created by xinyun shen on 4/4/21.
//

import UIKit

class PopUpViewController: UIViewController {

    @IBOutlet weak var modelurlText: UITextField!
    @IBOutlet weak var modelnameText: UITextField!
    
    var modelname = ""
    var modelurl  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitModel(_ sender: Any) {
        self.modelurl = modelurlText.text!
        self.modelname = modelnameText.text!
        performSegue(withIdentifier: "ImportArInfo", sender: self)
        
    }
    
    func get_file_name(url_string: String) -> String{
        let model_name_arr = url_string.components(separatedBy: "/")
        let model_file_name = model_name_arr[model_name_arr.endIndex - 1]
        return model_file_name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! PuzzlesVC
        vc.model_name.append(self.modelname)
        vc.ar_url.append(self.modelurl)
        let model_file_name = self.get_file_name(url_string: self.modelurl)
        vc.model_files_name.append(model_file_name)
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
