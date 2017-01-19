//
//  StringExt.swift
//  JSON
//
//  Created by Juan Alvarez on 4/5/15.
//  Copyright (c) 2015 Alvarez Productions. All rights reserved.
//

import Foundation

extension String {
    
    func substring(_ range: Range<Int>) -> String? {
        if range.lowerBound < 0 || range.upperBound > self.characters.count {
            return nil
        }
        
        let range = (characters.index(startIndex, offsetBy: range.lowerBound) ..< characters.index(startIndex, offsetBy: range.upperBound))
        
        return self[range]
    }
}
