//
//  sellermainVC.swift
//  shop
//
//  Created by Admin on 02/10/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import JTMaterialSpinner
import SDWebImage
class SellermainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    var loginVC : LoginVC!
    var selleraddproductVC : SellerAddProductVC!
    var sellerfavVC: SellerFavVC!
    @IBOutlet weak var productCV: UICollectionView!
    var spinnerView = JTMaterialSpinner()
    var allproduct = [Product]()
    override func viewDidLoad() {
        super.viewDidLoad()
        productCV.delegate = self
        productCV.dataSource = self
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
        allproduct = []
        let parameters: Parameters = ["useremail":Defaults.getNameAndValue(Defaults.USEREMAIL_KEY)]
        
        Alamofire.request(Global.baseUrl + "getsellermain.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                if status == "ok" {
                    let status_product = value["status_product"] as! String
                    let shop_id = value["shopid"] as! String
                    Defaults.save(shop_id, with: Defaults.SHOPID_KEY)
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
                    
                    self.productCV.reloadData()
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
    @IBAction func AddProductBtn(_ sender: Any) {
        self.selleraddproductVC = self.storyboard?.instantiateViewController(withIdentifier: "selleraddproductVC") as? SellerAddProductVC
        self.present(self.selleraddproductVC, animated: true, completion: nil)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allproduct.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! buyerproductCell
            let oneproduct : Product
            oneproduct = allproduct[indexPath.row]
            let image_url = oneproduct.image.components(separatedBy: "_split_")
        
            let ImgUrl = Global.imageUrl + image_url[0]
            
            cell.productImg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
            cell.productName.text = oneproduct.name
            return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
            Defaults.save(allproduct[indexPath.row].id, with: Defaults.PRODUCTID_KEY)
            Defaults.save(allproduct[indexPath.row].name, with: Defaults.PRODUCTNAME_KEY)
            Defaults.save(allproduct[indexPath.row].shopid, with: Defaults.PRODUCTSHOPID_KEY)
            Defaults.save(allproduct[indexPath.row].price, with: Defaults.PRODUCTPRICE_KEY)
            Defaults.save(allproduct[indexPath.row].fav, with: Defaults.PRODUCTFAV_KEY)
            Defaults.save(allproduct[indexPath.row].image, with: Defaults.PRODUCTIMAGE_KEY)
            Defaults.save(allproduct[indexPath.row].description, with: Defaults.PRODUCTDES_KEY)
//            self.buyerproductVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerproductVC") as? BuyerProductVC
//            self.present(self.buyerproductVC, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (UIScreen.main.bounds.size.width - 40) / 2, height: (UIScreen.main.bounds.size.width - 40) / 2 + 10)
       
    }
    
    
}
