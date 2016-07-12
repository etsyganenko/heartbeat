//
//  HBFilter.swift
//  Heartbeat
//
//  Created by Artem on 6/15/16.
//  Copyright © 2016 IDAP. All rights reserved.
//

import UIKit

class HBFilter: NSObject {
    
    // MARK: - Class Methods
    
    class func filterFromDictionary(dictionary: NSDictionary) -> HBFilter? {
        if let filterName = dictionary[kHBKeyFilterName] as! String? {
            let filterModel = HBFilter(filterName: filterName) as HBFilter
            if let parameters = dictionary[kHBKeyParameters] as! NSArray? {
                let mutableParameters = NSMutableArray()
                for parameter in parameters {
                    let parameterDictionary = parameter as! NSDictionary
                    let parameterModel = HBFilterParameter.parameterFromDictionary(parameterDictionary) as HBFilterParameter?
                    
                    parameterModel!.parameterValueChangeHandler = { (value: Double, name: String) -> Void in
                        filterModel.audioKitFilter!.setValue(value, forKey: name)
                    }
                    
                    mutableParameters.addObject(parameterModel!)
                }
                
                filterModel.parameters = mutableParameters
                filterModel.enabled = false
                
                return filterModel
            }
        }
        
        return nil
    }

    // MARK: - Initialization
    
    init(filterName: String) {
        self.filterName = filterName
        
        super.init()
    }
    
    // MARK: - Accessors
    
    var filterName: String?
    var parameters: NSArray?
    
    var audioKitFilter: AnyObject?
    
    var enabled: Bool?
}
