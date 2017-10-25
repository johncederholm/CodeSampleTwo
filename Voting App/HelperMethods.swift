//
//  HelperMethods.swift
//  Voting App
//
//  Created by John Cederholm on 10/25/17.
//  Copyright © 2017 d2i LLC. All rights reserved.
//

import Foundation

class HelperMethods {
    
    class func getNumberPlacementString(number: Int) -> String {
        var numString:String!
        switch number {
        case 0: numString = ""
        case 1: numString = "st"
        case 2: numString = "nd"
        case 3: numString = "rd"
        default: numString = "th"
        }
        return numString
    }
    
}
