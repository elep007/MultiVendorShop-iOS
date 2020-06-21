//
//  ViewController.swift
//  shop
//
//  Created by Admin on 26/09/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import iOSDropDown
import JTMaterialSpinner
import Toaster
import Alamofire
class LoginVC: UIViewController {
    var buyermainVC : BuyerMainVC!
    var sellermainVC : SellermainVC!
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var userNameLBL: UITextField!
    @IBOutlet weak var passWordLBL: UITextField!
    @IBOutlet weak var langSel: DropDown!
    var save_username : String!
    var save_password : String!
    override func viewDidLoad() {        
        super.viewDidLoad()
        langSel.optionArray = Global.languageSet
        save_username = Defaults.getNameAndValue(Defaults.USERNAME_KEY)
        save_password = Defaults.getNameAndValue(Defaults.USERPASSWORD_KEY)
        if(save_username != "")
        {
            userNameLBL.text! = save_username
            passWordLBL.text! = save_password
            loginfunc()
        }
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
    func loginfunc(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        
        let parameters: Parameters = ["username": userNameLBL.text!, "password": passWordLBL.text! ]
        
        Alamofire.request(Global.baseUrl + "verifyuser.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                self.spinnerView.endRefreshing()
                print(value)
                let status = value["status"] as! String
                
                if status == "ok" {
                    let userid = value["id"] as! String
                    let username = value["username"] as! String
                    let useremail = value["email"] as! String
                    let usermobile = value["mobile"] as! String
                    let useractive = value["active"] as! String
                    let userrole = value["role"] as! String
                    Defaults.save(userid, with: Defaults.USERID_KEY)
                    Defaults.save(username, with: Defaults.USERNAME_KEY)
                    Defaults.save(useremail, with: Defaults.USEREMAIL_KEY)
                    Defaults.save(usermobile, with: Defaults.USERMOBILE_KEY)
                    Defaults.save(self.passWordLBL.text!, with: Defaults.USERPASSWORD_KEY)
                    if(userrole == "buyer"){
                        self.buyermainVC = self.storyboard?.instantiateViewController(withIdentifier: "buyermainVC") as? BuyerMainVC
                        self.present(self.buyermainVC, animated: true, completion: nil)
                    }
                    else{
                        self.sellermainVC = self.storyboard?.instantiateViewController(withIdentifier: "sellermainVC") as? SellermainVC
                        self.present(self.sellermainVC, animated: true, completion: nil)
                    }
                
                }else if status == "wrongpassword"{
                    
                    Toast(text: "Password is wrong").show()
                }else{
                    Toast(text: "Unregistered User").show()
                }
            }
            else{
                self.spinnerView.endRefreshing()
                Toast(text: "No internet").show()
            }
        }
    }
    @IBAction func loginBtn(_ sender: Any) {
        if((userNameLBL.text! != "") && (passWordLBL.text! != "")){
            loginfunc()
        }else{
            Toast(text: "Fill the empty field").show()
        }
    }
    @IBAction func forgotPassBtn(_ sender: Any)
    {
    }    
    @IBAction func signUpBtn(_ sender: Any) {
    }
}
