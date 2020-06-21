//
//  BuyerProductVC.swift
//  shop
//
//  Created by Admin on 28/09/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import JTMaterialSpinner
import ImageSlideshow
import ValueStepper
class BuyerProductVC: UIViewController {
    var loginVC : LoginVC!
    var buyermainVC : BuyerMainVC!
    var buyerallshopVC: BuyerAllShopVC!
    var buyeroneshopVC : BuyerOneShopVC!
    var buyerproductVC : BuyerProductVC!
    var buyerallproductVC: BuyerAllProductVC!
    var buyerbasketVC : BuyerBasketVC!
    var buyefavVC: BuyerFavVC!
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var producttitle: UILabel!
    @IBOutlet weak var productimg: ImageSlideshow!
    @IBOutlet weak var shopimg: UIImageView!
    @IBOutlet weak var productname: UILabel!
    @IBOutlet weak var shopmobile: UILabel!
    @IBOutlet weak var shopname: UILabel!
    @IBOutlet weak var productprice: UILabel!
    @IBOutlet weak var productdes: UITextView!
    @IBOutlet weak var productcount: ValueStepper!
    @IBOutlet weak var productfavimg: UIImageView!
    @IBOutlet weak var favBtn: UIButton!
    var shop_location : String!
    var shop_mobile : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        toastenvironment()
        setlayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    func setlayout(){
        productdes.layer.borderWidth = 1
        productdes.layer.masksToBounds = false
        productdes.layer.borderColor = UIColor.lightGray.cgColor
        productdes.layer.cornerRadius = 10
        productdes.clipsToBounds = true
        
        shopimg.layer.borderWidth = 1
        shopimg.layer.masksToBounds = false
        shopimg.layer.borderColor = UIColor.white.cgColor
        shopimg.layer.cornerRadius = shopimg.frame.height/2
        shopimg.clipsToBounds = true
    }
    func setready(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["userid":Defaults.getNameAndValue(Defaults.USERID_KEY), "productid":Defaults.getNameAndValue(Defaults.PRODUCTID_KEY), "shopid":Defaults.getNameAndValue(Defaults.PRODUCTSHOPID_KEY)]
        
        Alamofire.request(Global.baseUrl + "buyeroneproduct.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                if status == "ok" {
                    self.spinnerView.endRefreshing()
                    let product_fav = value["fav"] as! String
                    let shop_name = value["shopname"] as! String
                    self.shop_mobile = value["shopmobile"] as! String
                    let shop_image = value["shopimg"] as! String
                    self.shop_location = value["shoplocation"] as! String                    
                    self.producttitle.text! = Defaults.getNameAndValue(Defaults.PRODUCTNAME_KEY)
                    self.productname.text! = Defaults.getNameAndValue(Defaults.PRODUCTNAME_KEY)
                    self.productdes.text! = Defaults.getNameAndValue(Defaults.PRODUCTDES_KEY)
                    self.productprice.text! = Defaults.getNameAndValue(Defaults.PRODUCTPRICE_KEY) + "$"
                    
                    let imgage_url = Defaults.getNameAndValue(Defaults.PRODUCTIMAGE_KEY)
                    let imgages_url = imgage_url.components(separatedBy: "_split_")
                    var inputSource: [InputSource] = []
                    for i in 0...imgages_url.count-1 {
                        inputSource.append(AlamofireSource(urlString: Global.imageUrl + imgages_url[i])!)
                    }
                    self.productimg.setImageInputs(inputSource)
                    
                    self.shopmobile.text! = self.shop_mobile
                    self.shopname.text! = shop_name
                    let ImgUrl = Global.imageUrl + shop_image
                    self.shopimg.sd_setImage(with: URL(string: ImgUrl), completed: nil)                    
                    if(product_fav == "yes"){
                        self.productfavimg.image = UIImage.init(named: "fav-red")
                        self.favBtn.isEnabled = false
                    }
                    
                }else{
                    self.spinnerView.endRefreshing()
                    Toast(text: "No product data").show()
                }
            }
            else{
                Toast(text: "No internet").show()
            }
        }
    }

    @IBAction func phonecallBtn(_ sender: Any) {
        let moblestr = "tel://" + shop_mobile
        print (moblestr)
        guard let number = URL(string: moblestr) else { return }
        UIApplication.shared.open(number)
    }
    
    @IBAction func locationBtn(_ sender: Any) {
        if let url = URL(string: "https://www.google.com/maps/@" + shop_location + ",18z"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    @IBAction func setfaveBtn(_ sender: Any) {
        if(Defaults.getNameAndValue(Defaults.PRODUCTFAV_KEY) == "no"){
            let parameters: Parameters = ["userid":Defaults.getNameAndValue(Defaults.USERID_KEY), "productid":Defaults.getNameAndValue(Defaults.PRODUCTID_KEY)]
            
            Alamofire.request(Global.baseUrl + "buyersetfavproduct.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
                print(response)
                if let value = response.value as? [String: AnyObject] {
                    print(value)
                    let status = value["status"] as! String
                    if status == "ok" {
                        self.spinnerView.endRefreshing()
                        self.favBtn.isEnabled = false
                        Toast(text: "Add Favourite shop").show()
                        self.productfavimg.image = UIImage(named: "fav-red")
                    }else{
                        self.spinnerView.endRefreshing()
                        Toast(text: "No product data").show()
                    }
                }
                else{
                    Toast(text: "No internet").show()
                }
            }
        }
    }
    
    @IBAction func addbasketBtn(_ sender: Any) {
        let alert = UIAlertController(title: "Do you add basket?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.addbasket()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
        
    }
    func addbasket(){
        let parameters: Parameters = ["userid":Defaults.getNameAndValue(Defaults.USERID_KEY), "productid":Defaults.getNameAndValue(Defaults.PRODUCTID_KEY), "count": productcount.value]
        
        Alamofire.request(Global.baseUrl + "buyeraddbasket.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                if status == "ok" {
                    self.spinnerView.endRefreshing()
                    Toast(text: "Success").show()
                }else{
                    self.spinnerView.endRefreshing()
                    Toast(text: "Add Basket Fail").show()
                }
            }
            else{
                Toast(text: "No internet").show()
            }
        }
    }
    @IBAction func buyBtn(_ sender: Any) {
        let alert = UIAlertController(title: "Do you buy this product?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.buy()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    func buy(){
        print("\(productcount.value)")
    }
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goHomeBtn(_ sender: Any) {
        self.buyermainVC = self.storyboard?.instantiateViewController(withIdentifier: "buyermainVC") as? BuyerMainVC
        self.present(self.buyermainVC, animated: true, completion: nil)
    }
    
    @IBAction func goFavBtn(_ sender: Any) {
        self.buyefavVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerfavVC") as? BuyerFavVC
        self.present(self.buyefavVC, animated: true, completion: nil)
    }
    
    @IBAction func goBasketBtn(_ sender: Any) {
        self.buyerbasketVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerbasketVC") as? BuyerBasketVC
        self.present(self.buyerbasketVC, animated: true, completion: nil)
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
        Defaults.save("", with: Defaults.USERNAME_KEY)
        Defaults.save("", with: Defaults.USERPASSWORD_KEY)
        self.loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginVC
        self.present(self.loginVC, animated: true, completion: nil)
    }
    
}
