//
//  HBFilterParameter.swift
//  Heartbeat
//
//  Created by Artem on 6/15/16.
//  Copyright © 2016 IDAP. All rights reserved.
//

import UIKit

class HBFilterParameter: NSObject {

    // MARK: - Class Methods
    
    class func parameterFromDictionary(dictionary: NSDictionary) -> HBFilterParameter? {
        if let parameterName = dictionary[kHBKeyParameterName] as! String? {
            if let minimumValue = dictionary[kHBKeyMinimumValue] as! NSNumber? {
                if let maximumValue = dictionary[kHBKeyMaximumValue] as! NSNumber? {
                    if let parameterDescription = dictionary[kHBKeyParameterDescription] as! String? {
                        let parameterModel = HBFilterParameter(parameterName: parameterName,
                                                               parameterDescription: parameterDescription,
                                                               minimumValue: minimumValue.integerValue,
                                                               maximumValue: maximumValue.integerValue) as HBFilterParameter
                        
                        return parameterModel
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Initialization
    
    init(parameterName: String, parameterDescription: String, minimumValue: Int, maximumValue: Int) {
        self.parameterName = parameterName
        self.parameterDescription = parameterDescription
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        
        super.init()
    }
    
    // MARK: - Accessors
    
    var parameterName: String?
    var parameterDescription: String?
    
    var minimumValue: Int?
    var maximumValue: Int?
    var currentValue: Int?
    
    var parameterValueChangeHandler: ((value: Double, name: String) -> Void)?
}
