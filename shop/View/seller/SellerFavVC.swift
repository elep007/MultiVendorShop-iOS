//
//  SellerFavVC.swift
//  shop
//
//  Created by Admin on 04/10/2019.
//  Copyright © 2019 Admin. All rights reserved.
//

import UIKit
import Alamofire
import Toaster
import JTMaterialSpinner

class SellerFavVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var sellermainVC : SellermainVC!
    var loginVC : LoginVC!
    var selleraddproductVC : SellerAddProductVC!
    @IBOutlet weak var userTB: UITableView!
    var spinnerView = JTMaterialSpinner()
    var alluser = [User]()
    var favuserid : [String] = []
    override func viewDidLoad() {
        userTB.delegate = self
        userTB.dataSource = self
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
        alluser = []
        let parameters: Parameters = ["userid":Defaults.getNameAndValue(Defaults.USERID_KEY)]
        
        Alamofire.request(Global.baseUrl + "sellerfavpage.php", method: .post, parameters: parameters, encoding:JSONEncoding.default).responseJSON{ response in
            print(response)
            if let value = response.value as? [String: AnyObject] {
                print(value)
                let status = value["status"] as! String
                
                if status == "ok" {
                    let status_user = value["status_user"] as! String
                    if status_user == "ok"{
                        let users = value["allbuyer"] as? [[String: Any]]
                        for i in 0 ... (users?.count)!-1 {
                            let fav_id = users?[i]["favid"] as! String
                            let buyer_id = users?[i]["buyerid"] as! String
                            let buyer_name = users?[i]["buyername"] as! String
                            let buyer_email = users?[i]["buyeremail"] as! String
                            let buyer_mobile = users?[i]["buyermobile"] as! String
//
                            let buyercell = User(id: buyer_id, username: buyer_name, useremail: buyer_email, usermobile: buyer_mobile)
                            self.alluser.append(buyercell)
                            self.favuserid.append(fav_id)
                        }
//
                    }else{
                        Toast(text: "No user data").show()
                    }
                    self.spinnerView.endRefreshing()
                    self.userTB.reloadData()
                }else{
                    self.spinnerView.endRefreshing()
                    Toast(text: "No User data").show()
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
        self.sellermainVC = self.storyboard?.instantiateViewController(withIdentifier: "sellermainVC") as? SellermainVC
        self.present(self.sellermainVC, animated: true, completion: nil)
    }
    
    @IBAction func goAddproductBtn(_ sender: Any) {
        self.selleraddproductVC = self.storyboard?.instantiateViewController(withIdentifier: "selleraddproductVC") as? SellerAddProductVC
        self.present(self.selleraddproductVC, animated: true, completion: nil)
    }
    
    @IBAction func LogoutBtn(_ sender: Any) {
        Defaults.save("", with: Defaults.USERNAME_KEY)
        Defaults.save("", with: Defaults.USERPASSWORD_KEY)
        self.loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginVC
        self.present(self.loginVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alluser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.userTB.dequeueReusableCell(withIdentifier: "cell") as! sellerfavCell
        let oneuser : User
        oneuser = alluser[indexPath.row]
        cell.userName.text = oneuser.username
        cell.userMobile.text = oneuser.usermobile
        cell.useremail.text = oneuser.useremail
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
