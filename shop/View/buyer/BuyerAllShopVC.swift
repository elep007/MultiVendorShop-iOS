//
//  buyerAllShopVC.swift
//  shop
//
//  Created by Admin on 28/09/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import SDWebImage
import JTMaterialSpinner
class BuyerAllShopVC: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    var loginVC : LoginVC!
    var buyermainVC : BuyerMainVC!
    var buyerallshopVC: BuyerAllShopVC!
    var buyeroneshopVC : BuyerOneShopVC!
    var buyerproductVC : BuyerProductVC!
    var buyerallproductVC: BuyerAllProductVC!
    var buyerbasketVC : BuyerBasketVC!
    var buyefavVC: BuyerFavVC!
    
    var spinnerView = JTMaterialSpinner()    
    @IBOutlet weak var AllShopCV: UICollectionView!
    var allshop = [Shop]()
    override func viewDidLoad() {
        AllShopCV.delegate = self
        AllShopCV.dataSource = self
        toastenvironment()        
        super.viewDidLoad()        
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
        let parameters: Parameters = ["userid":Defaults.getNameAndValue(Defaults.USERID_KEY)]
        
        Alamofire.request(Global.baseUrl + "buyerallshop.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                let status_shop = value["status_shop"] as! String
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
                   
                    self.spinnerView.endRefreshing()
                    self.AllShopCV.reloadData()
                    
                }else{
                    self.spinnerView.endRefreshing()
                    Toast(text: "No shop data").show()
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
    
    @IBAction func goFaveBtn(_ sender: Any) {
        self.buyefavVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerfavVC") as? BuyerFavVC
        self.present(self.buyefavVC, animated: true, completion: nil)
    }
    
    @IBAction func goBasketBtn(_ sender: Any) {
        self.buyerbasketVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerbasketVC") as? BuyerBasketVC
        self.present(self.buyerbasketVC, animated: true, completion: nil)
    }
    
    @IBAction func LogoutBtn(_ sender: Any) {
        Defaults.save("", with: Defaults.USERNAME_KEY)
        Defaults.save("", with: Defaults.USERPASSWORD_KEY)
        self.loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginVC
        self.present(self.loginVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allshop.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "cell"), for: indexPath) as! buyerallshopcell
        let oneshop : Shop
        oneshop = allshop[indexPath.row]
        
        
        cell.shopUV.layer.borderWidth = 1
        cell.shopUV.layer.masksToBounds = false
        cell.shopUV.layer.borderColor = UIColor.lightGray.cgColor
        cell.shopUV.layer.cornerRadius = 10
        cell.shopUV.clipsToBounds = true
        
        let ImgUrl = Global.imageUrl + oneshop.image
        cell.shopImg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
        cell.shopName.text = oneshop.name
        if(oneshop.fav == "yes"){
            cell.favImg.image = UIImage(named: "fav-red")
        }        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.size.width - 40) / 2, height: (UIScreen.main.bounds.size.width - 40) / 2 + 10)
       
    }

}
