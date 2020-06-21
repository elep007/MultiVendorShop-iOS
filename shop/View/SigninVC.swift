//
//  SigninVC.swift
//  shop
//
//  Created by Admin on 30/09/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import JTMaterialSpinner
import Toaster

class SigninVC: UIViewController {
    var signmapviewVC :SignMapViewVC!
    var imagePicker = UIImagePickerController()
    var spinnerView = JTMaterialSpinner()
    var shopimage : UIImage!
    var shopimage_sel = 0
    @IBOutlet weak var buyerV: UIView!
    @IBOutlet weak var sellerV: UIView!
    @IBOutlet weak var sel_role: UISegmentedControl!
    @IBOutlet weak var imageV: UIView!
    //Buyer
    @IBOutlet weak var txtBuyerUsername: UITextField!
    @IBOutlet weak var txtBuyerPassword: UITextField!
    @IBOutlet weak var txtBuyerConPassword: UITextField!
    @IBOutlet weak var txtBuyerMobile: UITextField!
    @IBOutlet weak var txtBuyeremail: UITextField!
    
    //Seller
    @IBOutlet weak var shopImg: UIImageView!
    @IBOutlet weak var ImageSelBtn: UIButton!
    @IBOutlet weak var txtSellerName: UITextField!
    @IBOutlet weak var txtsellerPassword: UITextField!
    @IBOutlet weak var txtSellerConPassword: UITextField!
    @IBOutlet weak var txtSelleremail: UITextField!
    @IBOutlet weak var txtSellerMobile: UITextField!
    @IBOutlet weak var txtShopName: UITextField!
    @IBOutlet weak var InputShopAddress: UITextField!
    
    @IBOutlet weak var txtShopLocation: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toastenvironment()
        setready()
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
    func setready(){
        imageV.layer.borderWidth = 2
        imageV.layer.masksToBounds = false
        imageV.layer.borderColor = UIColor.white.cgColor
        imageV.layer.cornerRadius = 10
        imageV.clipsToBounds = true
    }
    func setvalue(){
        InputShopAddress.text = Defaults.getNameAndValue(Defaults.ADDRESS_KEY)
        txtShopLocation.text = Defaults.getNameAndValue(Defaults.LOCATION_KEY)
    }
    
    
    @IBAction func setLocationBTn(_ sender: Any) {
        signmapviewVC = self.storyboard?.instantiateViewController(withIdentifier: "signmapviewVC") as? SignMapViewVC
        signmapviewVC.signinVC = self
        self.present(signmapviewVC, animated: true, completion: nil)
    }
    
    @IBAction func shopimageBtn(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))        
        self.present(alert, animated: true, completion: nil)
    }
    //MARK: - Open the camera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            //If you dont want to edit the photo then you can set allowsEditing to false
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        else{
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Choose image from camera roll
    
    func openGallary(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        //If you dont want to edit the photo then you can set allowsEditing to false
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selRoleSeg(_ sender: Any) {
        switch sel_role.selectedSegmentIndex
        {
        case 0:
            buyerV.isHidden = false
            sellerV.isHidden = true
        case 1:
            buyerV.isHidden = true
            sellerV.isHidden = false
        default:
            break
        }
    }
    

    @IBAction func signupsellerBtn(_ sender: Any) {
        if(shopimage_sel == 1){
            if((txtSellerName.text! != "")&&(txtsellerPassword.text! != "")&&(txtSellerConPassword.text! != "") && (txtSelleremail.text! != "") && (txtSellerMobile.text! != "") && (txtShopName.text! != "") &&  (txtShopLocation.text! != "") && (InputShopAddress.text! != ""))
            {
                if(txtsellerPassword.text! == txtSellerConPassword.text!){
                    self.view.addSubview(spinnerView)
                    spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
                    spinnerView.circleLayer.lineWidth = 2.0
                    spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
                    spinnerView.beginRefreshing()
                    
                    let data = shopimage.jpegData(compressionQuality: 0.6)
                    let strBase64 = data!.base64EncodedString(options: .lineLength64Characters)
                    
                    let parameters: Parameters = ["username": txtSellerName.text!, "password": txtsellerPassword.text!, "email": txtSelleremail.text! , "mobile": txtSellerMobile.text! , "shopname": txtShopName.text!, "shoplocation": txtShopLocation.text!, "shopaddress": InputShopAddress.text!, "shopimage": strBase64]
                    
                    Alamofire.request(Global.baseUrl + "signupseller.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                        print(response)
                        if let value = response.value as? [String: AnyObject] {
                            self.spinnerView.endRefreshing()
                            print(value)
                            let status = value["status"] as! String
                            if status == "ok" {
                                Toast(text: "Sign Up Successfully").show()
                            }else if status == "existuser"{
                                Toast(text: "This username already exist").show()
                            }else if status == "existemail"{
                                Toast(text: "This email already exist").show()
                            }else{
                                Toast(text: "Signup error").show()
                            }
                        }
                        else{
                            self.spinnerView.endRefreshing()
                            Toast(text: "No internet").show()
                        }
                    }
                }else{
                    Toast(text: "Password not equal").show()
                }
            } else{
                Toast(text: "Please Fill the Empty Field").show()
            }
            
        }
        else{
            Toast(text: "Please Input the shop Image").show()
        }
    }
    
    @IBAction func signupbuyerBtn(_ sender: Any) {
        if((txtBuyerUsername.text! != "")&&(txtBuyerPassword.text! != "")&&(txtBuyerConPassword.text! != "") && (txtBuyeremail.text! != "") && (txtBuyerMobile.text! != ""))
        {
            if(txtBuyerConPassword.text! == txtBuyerPassword.text!){
                self.view.addSubview(spinnerView)
                spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
                spinnerView.circleLayer.lineWidth = 2.0
                spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
                spinnerView.beginRefreshing()
                let parameters: Parameters = ["username": txtBuyerUsername.text!, "password": txtBuyerPassword.text!, "email": txtBuyeremail.text! , "mobile": txtBuyerMobile.text!]
                print(Global.baseUrl + "signupbuyer.php")
                Alamofire.request(Global.baseUrl + "signupbuyer.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                    print(response)
                    if let value = response.value as? [String: AnyObject] {
                        self.spinnerView.endRefreshing()
                        print(value)
                        let status = value["status"] as! String
                        if status == "ok" {
                            Toast(text: "Sign Up Successfully").show()
                        }else if status == "existuser"{
                            Toast(text: "This username already exist").show()
                        }else if status == "existemail"{
                            Toast(text: "This email already exist").show()
                        }else{
                            Toast(text: "Signup error").show()
                        }
                    }
                    else{
                        self.spinnerView.endRefreshing()
                        Toast(text: "No internet").show()
                    }
                }
            }else{                
                Toast(text: "Password not equal").show()
            }
        } else{
            Toast(text: "Please Fill the Empty Field").show()
        }
    }
    
    @IBAction func gologinpageBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func gologinBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: - UIImagePickerControllerDelegate

extension SigninVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        /*
         Get the image from the info dictionary.
         If no need to edit the photo, use `UIImagePickerControllerOriginalImage`
         instead of `UIImagePickerControllerEditedImage`
         */

        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            print(editedImage)
            shopimage = editedImage
            shopimage_sel = 1
            self.shopImg.image = editedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}


