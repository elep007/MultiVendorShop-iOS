//
//  buyerMainVC.swift
//  shop
//
//  Created by Admin on 28/09/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import JTMaterialSpinner
import Alamofire
import SDWebImage
import Toaster
class BuyerMainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    var loginVC : LoginVC!
    var buyerallshopVC: BuyerAllShopVC!
    var buyeroneshopVC : BuyerOneShopVC!
    var buyerproductVC : BuyerProductVC!
    var buyerallproductVC: BuyerAllProductVC!
    var buyerbasketVC : BuyerBasketVC!
    var buyefavVC: BuyerFavVC!
    
    var spinnerView = JTMaterialSpinner()
    var allproduct = [Product]()
    var allshop = [Shop]()
    
    @IBOutlet weak var shopCV: UICollectionView!
    @IBOutlet weak var ProductCV: UICollectionView!
    override func viewDidLoad() {
        ProductCV.delegate = self
        ProductCV.dataSource = self
        
        shopCV.delegate = self
        shopCV.dataSource = self
        super.viewDidLoad()
        toastenvironment()
        
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
    
    func setready(){
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        allshop = []
        allproduct = []
        let parameters: Parameters = ["userid":Defaults.getNameAndValue(Defaults.USERID_KEY)]
        
        Alamofire.request(Global.baseUrl + "getbuyermain.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                let status_shop = value["status_shop"] as! String
                let status_product = value["status_product"] as! String
                if status == "ok" {
                    if status_shop == "ok"{
                        let shops = value["allshop"] as? [[String: Any]]
                        for i in 0 ... (shops?.count)!-1 {
                            let shop_id = shops?[i]["id"] as! String
                            let shop_name = shops?[i]["shopname"] as! String
                            let shop_email = shops?[i]["shopemail"] as! String
                            let shop_mobile = shops?[i]["shopmobile"] as! String
                            let shop_address = shops?[i]["shopaddress"] as! String
                            let shop_location = shops?[i]["shoplocation"] as! String
                            let shop_image = shops?[i]["shopimg"] as! String
                            let shop_fav = shops?[i]["shopfav"] as! String
                           
                            let shopcell = Shop(id: shop_id, name: shop_name, email: shop_email, mobile: shop_mobile, address: shop_address, location: shop_location, image: shop_image, fav: shop_fav)
                            self.allshop.append(shopcell)
                        }
                        
                    }else{
                        Toast(text: "No shop data").show()
                    }
                    if status_product == "ok"{
                        let products = value["allproduct"] as? [[String: Any]]
                        for i in 0 ... (products?.count)!-1 {
                            let product_id = products?[i]["id"] as! String
                            let product_shop_id = products?[i]["shopid"] as! String
                            let product_name = products?[i]["productname"] as! String
                            let product_price = products?[i]["productvalue"] as! String
                            let product_image = products?[i]["productimg"] as! String
                            let product_fav = products?[i]["productfav"] as! String
                            let product_des = products?[i]["productdes"] as! String
                            
                            let productcell = Product(id: product_id, shopid: product_shop_id, name: product_name, price: product_price, image: product_image, fav: product_fav, description: product_des)
                            self.allproduct.append(productcell)
                        }
                    }else{
                        Toast(text: "No product data").show()
                    }
                    self.spinnerView.endRefreshing()
                    self.shopCV.reloadData()
                    self.ProductCV.reloadData()
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
    
    @IBAction func productShowBtn(_ sender: Any) {
        self.buyerallproductVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerallproductVC") as? BuyerAllProductVC
        self.present(self.buyerallproductVC, animated: true, completion: nil)
    }
    
    @IBAction func shopshowBtn(_ sender: Any) {
        self.buyerallshopVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerallshopVC") as? BuyerAllShopVC
        self.present(self.buyerallshopVC, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        Defaults.save("", with: Defaults.USERNAME_KEY)
        Defaults.save("", with: Defaults.USERPASSWORD_KEY)
        self.loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginVC
        self.present(self.loginVC, animated: true, completion: nil)
    }
    
    @IBAction func basketBtn(_ sender: Any) {
        self.buyerbasketVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerbasketVC") as? BuyerBasketVC
        self.present(self.buyerbasketVC, animated: true, completion: nil)
    }
    @IBAction func favoriteBtn(_ sender: Any) {
        self.buyefavVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerfavVC") as? BuyerFavVC
        self.present(self.buyefavVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView.tag == 100) {
            if(allproduct.count > 5){
                return 5
            }else{
                return allproduct.count
            }
        }else {
            if(allshop.count > 10){
                return 10
            }else{
                return allshop.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView.tag == 100){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! buyerproductCell
            let oneproduct : Product
            oneproduct = allproduct[indexPath.row]
            let image_url = oneproduct.image.components(separatedBy: "_split_")
            let ImgUrl = Global.imageUrl + image_url[0]
            cell.productImg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
            cell.productName.text = oneproduct.name
            return cell
        }
        else {
            let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! buyershopCell
            let oneshop : Shop
            oneshop = allshop[indexPath.row]
            let ImgUrl = Global.imageUrl + oneshop.image
            cell1.shopImg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
            cell1.shopName.text = oneshop.name
            return cell1
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView.tag == 100){
            Defaults.save(allproduct[indexPath.row].id, with: Defaults.PRODUCTID_KEY)
            Defaults.save(allproduct[indexPath.row].name, with: Defaults.PRODUCTNAME_KEY)
            Defaults.save(allproduct[indexPath.row].shopid, with: Defaults.PRODUCTSHOPID_KEY)
            Defaults.save(allproduct[indexPath.row].price, with: Defaults.PRODUCTPRICE_KEY)
            Defaults.save(allproduct[indexPath.row].fav, with: Defaults.PRODUCTFAV_KEY)
            Defaults.save(allproduct[indexPath.row].image, with: Defaults.PRODUCTIMAGE_KEY)
            Defaults.save(allproduct[indexPath.row].description, with: Defaults.PRODUCTDES_KEY)
            self.buyerproductVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerproductVC") as? BuyerProductVC
            self.present(self.buyerproductVC, animated: true, completion: nil)
        }
        else{
            Defaults.save(allshop[indexPath.row].id, with: Defaults.SHOPID_KEY)
            Defaults.save(allshop[indexPath.row].name, with: Defaults.SHOPNAME_KEY)
            Defaults.save(allshop[indexPath.row].email, with: Defaults.SHOPEMAIL_KEY)
            Defaults.save(allshop[indexPath.row].mobile, with: Defaults.SHOPMOBILE_KEY)
            Defaults.save(allshop[indexPath.row].address, with: Defaults.SHOPADDRESS_KEY)
            Defaults.save(allshop[indexPath.row].location, with: Defaults.SHOPLOCATION_KEY)
            Defaults.save(allshop[indexPath.row].image, with: Defaults.SHOPIMG_KEY)
            Defaults.save(allshop[indexPath.row].fav, with: Defaults.SHOPFAV_KEY)
            
            self.buyeroneshopVC = self.storyboard?.instantiateViewController(withIdentifier: "buyeroneshopVC") as? BuyerOneShopVC
            self.present(self.buyeroneshopVC, animated: true, completion: nil)
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView.tag == 200){
            return CGSize(width: (UIScreen.main.bounds.size.width - 40) / 2, height: (UIScreen.main.bounds.size.width - 40) / 2 + 10)
        }
        else{
            return CGSize(width: 129 , height:136)
        }
    }
}
