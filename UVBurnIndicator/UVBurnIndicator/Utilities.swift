//
//  Utilities.swift
//  UVBurnIndicator
//
//  Created by Akshit Saxena on 1/29/24.
//

import Foundation


class Utilities{
    func getStorage()->UserDefaults{
        return UserDefaults.standard
    }
    
    func setSkinType(value: String){
        let defaults = getStorage()
        defaults.setValue(value, forKey: defaultKeys.skinType)
        defaults.synchronize()
    }
    
    func getSkinType() -> String{
        let defaults = getStorage()
        if let result = defaults.string(forKey: defaultKeys.skinType){
            return result
        }
        return SkinType().type1
    }
}

