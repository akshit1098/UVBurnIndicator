//
//  ViewController.swift
//  UVBurnIndicator
//
//  Created by Akshit Saxena on 1/29/24.
//

import UIKit
import MapKit
import Alamofire
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var uvIndex = 8
    var burnTime: Double = 10
    
    @IBOutlet weak var bigTimeLabel: UILabel!
    
    
    @IBAction func reminMeButtonClicked(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted{
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "Time's UP", arguments: nil)
                
                content.body = NSString.localizedUserNotificationString(forKey: "You are begining to burn! Please put on sunblock, clothing", arguments: nil)
                
                content.sound = UNNotificationSound.default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                let request = UNNotificationRequest(identifier: "will burn", content: content, trigger: trigger)
                center.add(request)
            }
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var skinTypeLabel: UILabel!
    
    var skinType = SkinType().type1{
        didSet{
            skinTypeLabel.text = "Skin: " + self.skinType
            Utilities().setSkinType(value: skinType)
        }
        
    }
    
    let locationManager = CLLocationManager()
    var coords = CLLocationCoordinate2D(latitude: 40, longitude: 40)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        skinType = Utilities().getSkinType()
        skinTypeLabel.text = "skin: " + skinType
        updateUI(dataSuccess: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location Location Changed")
        
        
        if status == .authorizedWhenInUse{
            getLocation()
           
        } else if status == .denied {
            let alert = UIAlertController(title: "Error", message: "Go to Settings and allow this app to access your location", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    func getLocation(){
        if let loc = locationManager.location?.coordinate{
            coords = loc
            getWeatherData()
        }
    }
    
    
    @IBAction func changeSkinClicked(_ sender: Any) {
        
        let alert = UIAlertController(title: "Skin Type", message: "Please choose skin type", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: SkinType().type1, style: .default, handler: { (action) in
            self.skinType = SkinType().type1
            self.updateUI(dataSuccess: true)
        }))
        alert.addAction(UIAlertAction(title: SkinType().type2, style: .default, handler: { (action) in
            self.skinType = SkinType().type2
            self.updateUI(dataSuccess: true)
        }))
        alert.addAction(UIAlertAction(title: SkinType().type3, style: .default, handler: { (action) in
            self.skinType = SkinType().type3
            self.updateUI(dataSuccess: true)
        }))
        alert.addAction(UIAlertAction(title: SkinType().type4, style: .default, handler: { (action) in
            self.skinType = SkinType().type4
            self.updateUI(dataSuccess: true)
        }))
        alert.addAction(UIAlertAction(title: SkinType().type5, style: .default, handler: { (action) in
            self.skinType = SkinType().type5
            self.updateUI(dataSuccess: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
// Parsing the JSON data steps:
/*
 JSON Format: {
    "data": {
        "ClimateAverages": [
            {
 
            }
        ],
        "weather": [
            {
                    "uvIndex": "2",
            }
        ]
    }
 }
 
 1. assign variable data as data (of json) which is dictionary of String keys and AnyObject values.
 2. assign weatherArray for weather of JSON data which is an array of dictionaries.
 3. Extract the first element of the array (using weatherArray[0] and then access "uvIndex").
 */
    func getWeatherData() {
        let url = weatherUrl(lat: String(coords.latitude), long: String(coords.longitude)).getFullUrl()

        if let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            AF.request(encodedUrl, method: .get).responseJSON { response in
                switch response.result {
                case .success(let value):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value, options: [])
                        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject]

                        if let data = jsonObject?["data"] as? [String: AnyObject],
                           let weatherArray = data["weather"] as? [[String: AnyObject]],
                           let uv = weatherArray[0]["uvIndex"] as? String {
                               if let uvI = Int(uv) {
                                   self.uvIndex = uvI
                                   print("At last... UVIndex = \(uvI)")
                                   self.updateUI(dataSuccess: true)
                                   
                               }
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                        self.updateUI(dataSuccess: false)
                    }

                    
                case .failure(let error):
                    print("Error \(error)")
                    self.updateUI(dataSuccess: false)
                }
            }
        } else {
            print("Error encoding URL")
            self.updateUI(dataSuccess: false)
        }
    }
    
    func updateUI(dataSuccess: Bool){
        
        DispatchQueue.main.async{
            //failure
            if !dataSuccess{
                self.statusLabel.text = "Failed..retrying..."
                self.getWeatherData()
                return
                
            }
            //success
            self.calculateBurnTime()
            print("burn Time: \(self.burnTime)")
            self.activityIndicator.stopAnimating()
            self.statusLabel.text = "Got UV Data"
            self.bigTimeLabel.text = String(self.burnTime)
            
            
        }
        
    }
    
    func calculateBurnTime(){
        var minToBurn: Double = 10
        switch skinType{
        case SkinType().type1:
            minToBurn = BurnTime().burnType1
        
        case SkinType().type2:
            minToBurn = BurnTime().burnType2
        
        case SkinType().type3:
            minToBurn = BurnTime().burnType3
        
        case SkinType().type4:
            minToBurn = BurnTime().burnType4
        
        case SkinType().type5:
            minToBurn = BurnTime().burnType5
        
        case SkinType().type6:
            minToBurn = BurnTime().burnType6
        
        default:
            minToBurn = BurnTime().burnType1
            
        }
        
        burnTime = minToBurn/Double(self.uvIndex)
    }



}

