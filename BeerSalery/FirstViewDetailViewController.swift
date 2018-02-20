//
//  FirstViewDetailViewController.swift
//  BeerSalery
//
//  Created by Dani Lihardja on 2/20/18.
//  Copyright © 2018 Prince Hendrie. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class FirstViewDetailViewController: UIViewController {
    
    var page = Int()
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var bagroundViewDetails: UIView!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    @IBOutlet weak var indicatorView: DotActivityIndicatorView!
    let greenColor = UIColor(red: 96/255, green: 186/255, blue: 157/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.bordered, target: self, action: #selector(backTapp))
        navBar.leftBarButtonItem = backButton
        
        self.bagroundViewDetails.layer.borderWidth = 1
        self.bagroundViewDetails.layer.borderColor = UIColor.init(red:96/255.0, green:186/255.0, blue:157/255.0, alpha: 1.0).cgColor
        
        let dotParms = DotActivityIndicatorParms()
        dotParms.activityViewWidth = self.indicatorView.frame.size.width;
        dotParms.activityViewHeight = self.indicatorView.frame.size.height;
        dotParms.numberOfCircles = 3;
        dotParms.internalSpacing = 5;
        dotParms.animationDelay = 0.2;
        dotParms.animationDuration = 0.6;
        dotParms.animationFromValue = 0.3;
        dotParms.defaultColor = greenColor
        dotParms.isDataValidationEnabled = true;
        indicatorView.dotParms = dotParms
        self.view.addSubview(indicatorView)
        
        // get detail data from api
        callAPI(page: page)
    }
    
    @objc func backTapp() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func stopIndicator() {
        backgroundView.isHidden = false
        self.indicatorView.isHidden = true
        self.indicatorView.stopAnimating()
    }
    
    func startIndicator() {
        backgroundView.isHidden = true
        self.indicatorView.isHidden = false
        self.indicatorView.startAnimating()
    }

    func callAPI(page:Int) {
        
        self.startIndicator()
        
        Alamofire.request("https://api.punkapi.com/v2/beers/\(page)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                self.stopIndicator()
                let json = JSON(value)
                
                for item in json {
                    
                    var name:String = ""
                    var description:String = ""
                    var imageUrl:String = ""
                    var firstBrewed:String = ""
                    var yeast:String = ""
                    
                    if item.1["name"] != nil { name = item.1["name"].string! }
                    if item.1["description"] != nil { description = item.1["description"].string! }
                    if item.1["image_url"] != nil { imageUrl = item.1["image_url"].string! }
                    if item.1["first_brewed"] != nil { firstBrewed = item.1["first_brewed"].string! }
                    if item.1["ingredients"]["yeast"] != nil { yeast = item.1["ingredients"]["yeast"].string! }
                    
                    
                    var maltsData: String = ""
                    var hopsData: String = ""
                    
                    for malt in item.1["ingredients"]["malt"] {
                        
                        maltsData = maltsData + "\t\t- \((name: malt.1["name"].string!)) \((malt.1["amount"]["value"].number!)) \(malt.1["amount"]["unit"].string!)\n"
                    }
                    
                    for hops in item.1["ingredients"]["hops"] {
                        
                         hopsData = hopsData + "\t\t- \((name: hops.1["name"].string!)) \((hops.1["amount"]["value"].number!)) \(hops.1["amount"]["unit"].string!)\n"
                    }
                    
                   
                    
                    
                    
                    self.textArea.text = "\(name)\n\n\(description)\n\nFirst Brewed : \(firstBrewed)\n\nIngredients :\n\n\(maltsData)\n\n\(hopsData)\n\n\(yeast)"
                        
                    self.img.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "noImage.png"))
                    self.img.contentMode = UIViewContentMode.scaleAspectFit
                    
                }
                
                
            case .failure(let error):
                self.stopIndicator()
                print(error)
                self.alert(message: "Unable to connect to server please check your network connection", title: "Warning")
            }
        }
    }
    
    
    func alert(message: String, title: String = "") {
        _ = SweetAlert().showAlert(title, subTitle: message, style: AlertStyle.warning, buttonTitle: "OK", buttonColor: greenColor, action: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
