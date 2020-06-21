//
//  BuyerAllProductVC.swift
//  shop
//
//  Created by Admin on 01/10/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import JTMaterialSpinner
import Toaster
import SDWebImage
class BuyerAllProductVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var loginVC : LoginVC!
    var buyermainVC : BuyerMainVC!
    var buyerallshopVC: BuyerAllShopVC!
    var buyeroneshopVC : BuyerOneShopVC!
    var buyerproductVC : BuyerProductVC!
    var buyerallproductVC: BuyerAllProductVC!
    var buyerbasketVC : BuyerBasketVC!
    var buyefavVC: BuyerFavVC!
    var spinnerView = JTMaterialSpinner()
    @IBOutlet weak var productTB: UITableView!
    var allproduct = [Product]()
    override func viewDidLoad() {
        super.viewDidLoad()
        productTB.delegate = self
        productTB.dataSource = self        
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
        allproduct = []
        let parameters: Parameters = ["userid":Defaults.getNameAndValue(Defaults.USERID_KEY)]
        
        Alamofire.request(Global.baseUrl + "buyerallproduct.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                let status_product = value["status_product"] as! String
                if status == "ok" {
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
                    self.productTB.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allproduct.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.productTB.dequeueReusableCell(withIdentifier: "cell") as! buyershopproductCell
        let oneproduct : Product
        oneproduct = allproduct[indexPath.row]
        let image_url = oneproduct.image.components(separatedBy: "_split_")
        let ImgUrl = Global.imageUrl + image_url[0]
        cell.productImg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
        cell.productName.text = oneproduct.name
        
        cell.productUV.layer.borderWidth = 1
        cell.productUV.layer.masksToBounds = false
        cell.productUV.layer.borderColor = UIColor.lightGray.cgColor
        cell.productUV.layer.cornerRadius = 10
        cell.productUV.clipsToBounds = true
        if(oneproduct.fav == "yes"){
            cell.productfavImg.image = UIImage(named: "fav-red")
        }        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
