//
//  Constants.swift
//  UVBurnIndicator
//
//  Created by Akshit Saxena on 1/29/24.
//

import Foundation


struct defaultKeys{
    static let skinType = "skinType"
}
struct SkinType{
    
    let type1 = "Type 1 - Pale/Light"
    let type2 = "Type 2 - White/Fair"
    let type3 = "Type 3 - Medium"
    let type4 = "Type 4 - Olive Brwon"
    let type5 = "Type 5 - Dark Brown"
    let type6 = "Type 6 - Very Dark/Black"
}
    
struct weatherUrl{
    private let baseUrl = "https://api.worldweatheronline.com/premium/v1/weather.ashx"
    private let key = "&key=1a71a5cf6c2a44a7a3003215243001"
    
    private let numDaysForecast = "&num_of_days=1"
    private let format = "&format=json"
    
    private var coordStr = ""
    
    init(lat: String, long: String){
        self.coordStr = "?q=\(lat), \(long)"
    }
    
    func getFullUrl()->String{
        return baseUrl + coordStr + key + numDaysForecast + format
    }
}

struct BurnTime{
    let burnType1: Double = 67
    let burnType2: Double = 100
    let burnType3: Double = 200
    let burnType4: Double = 300
    let burnType5: Double = 400
    let burnType6: Double = 500
}
