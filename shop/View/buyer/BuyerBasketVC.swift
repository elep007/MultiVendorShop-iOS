//
//  BuyerBasketVC.swift
//  shop
//
//  Created by Admin on 02/10/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import JTMaterialSpinner
import SDWebImage
import Toaster

class BuyerBasketVC: UIViewController ,UITableViewDataSource,UITableViewDelegate{
    var loginVC : LoginVC!
    var buyermainVC : BuyerMainVC!
    var buyerallshopVC: BuyerAllShopVC!
    var buyeroneshopVC : BuyerOneShopVC!
    var buyerproductVC : BuyerProductVC!
    var buyerallproductVC: BuyerAllProductVC!
    var buyerbasketVC : BuyerBasketVC!
    var buyefavVC: BuyerFavVC!
    var spinnerView = JTMaterialSpinner()
    var allproduct = [Product]()
    var allbasket = [Basket]()
    var total_money :Int = 0
    @IBOutlet weak var basketTB: UITableView!
    @IBOutlet weak var totalprice: UILabel!
    @IBOutlet weak var buyBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basketTB.delegate = self
        basketTB.dataSource = self
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
        self.view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height-50)/2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        allproduct = []
        allbasket = []
        let parameters: Parameters = ["userid":Defaults.getNameAndValue(Defaults.USERID_KEY)]
        
        Alamofire.request(Global.baseUrl + "buyerbasket.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                self.spinnerView.endRefreshing()
                print(value)
                let status = value["status"] as! String
                
                if status == "ok" {
                        let products = value["allproduct"] as? [[String: Any]]
                        for i in 0 ... (products?.count)!-1 {
                            let basket_id = products?[i]["basketid"] as! String
                            let product_id = products?[i]["productid"] as! String
                            let product_name = products?[i]["productname"] as! String
                            let product_price = products?[i]["productvalue"] as! String
                            let product_image = products?[i]["productimg"] as! String
                            let product_count = products?[i]["basketcount"] as! String
                            let basketcell = Basket(id: basket_id, productid: product_id, productname: product_name, productprice: product_price, productcount: product_count, productimg: product_image)
                            self.allbasket.append(basketcell)
                        }
                        self.totalmoney()
                        self.buyBtn.isEnabled = true                    
                    self.basketTB.reloadData()
                }else{
                    self.buyBtn.backgroundColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
                    self.buyBtn.isEnabled = false
                    Toast(text: "No product data").show()
                }
            }
            else{
                self.spinnerView.endRefreshing()
                Toast(text: "No internet").show()
            }
        }
    }
    func totalmoney(){
        total_money = 0;
        for i in 0 ... allbasket.count - 1
        {
            let product_price = Int(allbasket[i].productprice)
            let product_count = Int(allbasket[i].productcount)
            total_money = total_money + product_count! * product_price!
        }
        totalprice.text = "\(total_money)"
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func BuyProductBtn(_ sender: Any) {
        
    }
    @IBAction func LogoutBtn(_ sender: Any) {
        Defaults.save("", with: Defaults.USERNAME_KEY)
        Defaults.save("", with: Defaults.USERPASSWORD_KEY)
        self.loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginVC
        self.present(self.loginVC, animated: true, completion: nil)
    }
    
    @IBAction func goFavBtn(_ sender: Any) {
        self.buyefavVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerfavVC") as? BuyerFavVC
        self.present(self.buyefavVC, animated: true, completion: nil)
    }
    
    @IBAction func goHomeBtn(_ sender: Any) {
        self.buyermainVC = self.storyboard?.instantiateViewController(withIdentifier: "buyermainVC") as? BuyerMainVC
        self.present(self.buyermainVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allbasket.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.basketTB.dequeueReusableCell(withIdentifier: "cell") as! buyerbasketCell
        let onebasket : Basket
        onebasket = allbasket[indexPath.row]
        let image_url = onebasket.productimg.components(separatedBy: "_split_")
        let ImgUrl = Global.imageUrl + image_url[0]
       
        cell.productimg.sd_setImage(with: URL(string: ImgUrl), completed: nil)
        cell.productname.text = onebasket.productname
        cell.productcount.text = onebasket.productcount
        cell.productprice.text = onebasket.productprice + "$"
        cell.productV.layer.borderWidth = 1
        cell.productV.layer.masksToBounds = false
        cell.productV.layer.borderColor = UIColor.lightGray.cgColor
        cell.productV.layer.cornerRadius = 10
        cell.productV.clipsToBounds = true
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Defaults.save(allproduct[indexPath.row].id, with: Defaults.PRODUCTID_KEY)
//        Defaults.save(allproduct[indexPath.row].name, with: Defaults.PRODUCTNAME_KEY)
//        Defaults.save(allproduct[indexPath.row].shopid, with: Defaults.PRODUCTSHOPID_KEY)
//        Defaults.save(allproduct[indexPath.row].price, with: Defaults.PRODUCTPRICE_KEY)
//        Defaults.save(allproduct[indexPath.row].fav, with: Defaults.PRODUCTFAV_KEY)
//        Defaults.save(allproduct[indexPath.row].image, with: Defaults.PRODUCTIMAGE_KEY)
//        Defaults.save(allproduct[indexPath.row].description, with: Defaults.PRODUCTDES_KEY)
        
//        self.buyerproductVC = self.storyboard?.instantiateViewController(withIdentifier: "buyerproductVC") as? BuyerProductVC
//        self.present(self.buyerproductVC, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}
