//
//  FirstViewController.swift
//  BeerSalery
//
//  Created by Dani Lihardja on 2/20/18.
//  Copyright © 2018 Prince Hendrie. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage


class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var listBeers = [Beer]()
    var page = 1
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var indicatorView: DotActivityIndicatorView!
    let greenColor = UIColor(red: 96/255, green: 186/255, blue: 157/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        
        
        // get list beer from api.
        callAPI(page: String(page))
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listBeers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FirstViewTableViewCell
        let row = indexPath.row
        
        
        cell.name.text = listBeers[row].name
        cell.desc.text = listBeers[row].description
        cell.img.sd_setImage(with: URL(string: listBeers[row].image), placeholderImage: UIImage(named: "noImage.png"))
        cell.img.contentMode = UIViewContentMode.scaleAspectFit
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastItem = listBeers.count - 1
        if indexPath.row == lastItem {
            
             callAPI(page: String(page + 1))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DestinationViewController : FirstViewDetailViewController = segue.destination as! FirstViewDetailViewController
        
        let indexPath = tableView.indexPathForSelectedRow
        DestinationViewController.page = listBeers[(indexPath?.row)!].id
    }
    
    func callAPI(page:String) {
        
        self.startIndicator()
        
        Alamofire.request("https://api.punkapi.com/v2/beers?page=\(page)", method: .get).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                self.stopIndicator()
                let json = JSON(value)

                for item in json {
                    
                    var name:String = ""
                    var description:String = ""
                    var imageUrl:String = ""
                    var id = 0
                    
                    if item.1["name"] != nil { name = item.1["name"].string! }
                    if item.1["description"] != nil { description = item.1["description"].string! }
                    if item.1["image_url"] != nil { imageUrl = item.1["image_url"].string! }
                    if item.1["id"] != nil { id = item.1["id"].int! }
                    
                    let beer = Beer(id: id, name: name, description: description, image: imageUrl)
                    self.listBeers.append(beer)
                }
                
                self.tableView.reloadData()
                
            case .failure(let error):
                self.stopIndicator()
                print(error)
                self.alert(message: "Unable to connect to server please check your network connection", title: "Warning")
            }
        }
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
    
    func alert(message: String, title: String = "") {
        _ = SweetAlert().showAlert(title, subTitle: message, style: AlertStyle.warning, buttonTitle: "OK", buttonColor: greenColor, action: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

