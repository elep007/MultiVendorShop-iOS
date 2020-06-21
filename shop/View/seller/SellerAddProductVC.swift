//
//  SellerAddProductVC.swift
//  shop
//
//  Created by Admin on 03/10/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import OpalImagePicker
import ImageSlideshow
import Toaster
import JTMaterialSpinner
class SellerAddProductVC: UIViewController {
    var sellermainVC : SellermainVC!
    var loginVC : LoginVC!
    var selleraddproductVC : SellerAddProductVC!
    var sellerfavVC : SellerFavVC!
    var spinnerView = JTMaterialSpinner()
    var imagePicker = UIImagePickerController()
    var uploadimages : [UIImage] = []
    var fileupload : [String] = []
    @IBOutlet weak var productUV: ImageSlideshow!
    @IBOutlet weak var txtProductName: UITextField!
    @IBOutlet weak var txtProductPrice: UITextField!
    @IBOutlet weak var txtProductDes: UITextView!
    var isPhoto : String!
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
        productUV.layer.borderWidth = 1
        productUV.layer.masksToBounds = false
        productUV.layer.borderColor = UIColor.lightGray.cgColor
        productUV.layer.cornerRadius = 10
        productUV.clipsToBounds = true
    }
    
    @IBAction func SelImgBtn(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
        
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func AddProductBtn(_ sender: Any) {
        if(isPhoto == "yes"){
            fileupload = []
            if(txtProductName.text! != ""){
                if(txtProductPrice.text! != ""){
                    for i in 0 ... uploadimages.count-1{
                        let data = uploadimages[i].jpegData(compressionQuality: 0.5)
                        fileupload.append(data!.base64EncodedString(options: .lineLength64Characters))
                    }
                    let parameters :Parameters = ["shopid": Defaults.getNameAndValue(Defaults.SHOPID_KEY), "productname" : txtProductName.text!, "productvalue" : txtProductPrice.text!, "productimg" : fileupload, "productdes" : txtProductDes.text!]
                    Alamofire.request(Global.baseUrl + "selleraddproduct.php", method: .post, parameters: parameters, encoding:JSONEncoding.default ).responseJSON{ returnValue in
                        print(returnValue)
                        if let value = returnValue.value as? [String: AnyObject] {
                            let status = value["status"] as! String
                            
                            if status == "ok" {
                                self.spinnerView.endRefreshing()
                                Toast(text: "Add Product Successfully").show()
                            }
                            else{
                                self.spinnerView.endRefreshing()
                                Toast(text: "Error").show()
                            }
                        }
                    }
                    
                }else{
                    Toast(text: "Please insert product price").show()
                }
            }else{
                Toast(text: "Please insert product name").show()
            }
        }else{
            Toast(text: "Please select product images").show()
        }
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let title = (error == nil) ? "Success" : "Error"
        let message = (error == nil) ? "Image was saved" : "Image failed to save"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openCamera(){
        let imagePicker = UIImagePickerController()
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
        let imagePicker = OpalImagePickerController()
        imagePicker.imagePickerDelegate = self
        imagePicker.maximumSelectionsAllowed = 10
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func goHomeBtn(_ sender: Any) {
        self.sellermainVC = self.storyboard?.instantiateViewController(withIdentifier: "sellermainVC") as? SellermainVC
        self.present(self.sellermainVC, animated: true, completion: nil)
    }
    
    @IBAction func BackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func goFavBtn(_ sender: Any) {
        self.sellerfavVC = self.storyboard?.instantiateViewController(withIdentifier: "sellerfavVC") as? SellerFavVC
        self.present(self.sellerfavVC, animated: true, completion: nil)
    }
    
    @IBAction func LogoutBtn(_ sender: Any) {
        Defaults.save("", with: Defaults.USERNAME_KEY)
        Defaults.save("", with: Defaults.USERPASSWORD_KEY)
        self.loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginVC
        self.present(self.loginVC, animated: true, completion: nil)
    }
}
//MARK: - UIImagePickerControllerDelegate

extension SellerAddProductVC:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
            dismiss(animated: true, completion: nil)
            let selimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        UIImageWriteToSavedPhotosAlbum(selimage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension SellerAddProductVC: OpalImagePickerControllerDelegate {
    func imagePickerDidCancel(_ picker: OpalImagePickerController) {
        //Cancel action?
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingImages images: [UIImage]) {
        //Save Images, update UI
	    uploadimages = images
        isPhoto = "yes"
        var inputSource: [InputSource] = []
        if images.count == 1{
            inputSource.append(ImageSource(image: images[0]))
            
        }
        else{
            for i in 0...images.count-1 {
                inputSource.append(ImageSource(image: images[i]))
            }
        }
        self.productUV.setImageInputs(inputSource)
        //Dismiss Controller
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerNumberOfExternalItems(_ picker: OpalImagePickerController) -> Int {
        return 1
    }
    
    func imagePickerTitleForExternalItems(_ picker: OpalImagePickerController) -> String {
        return NSLocalizedString("External", comment: "External (title for UISegmentedControl)")
    }
    
    func imagePicker(_ picker: OpalImagePickerController, imageURLforExternalItemAtIndex index: Int) -> URL? {
        return URL(string: "https://placeimg.com/500/500/nature")
    }
}
