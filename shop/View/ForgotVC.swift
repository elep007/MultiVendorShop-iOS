//
//  ForgotVC.swift
//  shop
//
//  Created by Admin on 01/10/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import JTMaterialSpinner
import Toaster
class ForgotVC: UIViewController {
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var txtusername: UITextField!
    @IBOutlet weak var txtemail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        toastenvironment()
    }
    func toastenvironment(){
        let appearance = ToastView.appearance()
        appearance.backgroundColor = .black
        appearance.textColor = .white
        appearance.font = .boldSystemFont(ofSize: 16)
        appearance.textInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        appearance.bottomOffsetPortrait = 100
        appearance.cornerRadius = 20
    }

    @IBAction func resetBtn(_ sender: Any) {
        if((txtemail.text! != "")&&(txtusername.text! != ""))
        {
                self.view.addSubview(spinnerView)
                spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
                spinnerView.circleLayer.lineWidth = 2.0
                spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
                spinnerView.beginRefreshing()
            
                let parameters: Parameters = ["username": txtusername.text!, "email": txtemail.text! ]
                
                Alamofire.request(Global.baseUrl + "resetpassword.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                    print(response)
                    if let value = response.value as? [String: AnyObject] {
                        print(value)
                        let status = value["status"] as! String
                        if status == "ok" {
                            self.spinnerView.endRefreshing()
                            Toast(text: "Successfully, Please check your email").show()
                            
                        }else{
                            self.spinnerView.endRefreshing()
                            Toast(text: "Reset password Error").show()
                        }
                    }
                    else{
                        Toast(text: "No internet").show()
                    }
                }
        } else{
            Toast(text: "Please Fill the Empty Field").show()
        }
    }
    @IBAction func gotoBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
