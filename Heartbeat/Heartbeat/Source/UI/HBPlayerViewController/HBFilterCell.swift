//
//  HBFilterCell.swift
//  Heartbeat
//
//  Created by Artem on 6/14/16.
//  Copyright © 2016 IDAP. All rights reserved.
//

import UIKit
import AudioKit

class HBFilterCell: UICollectionViewCell, UITableViewDataSource {

    // MARK: - Accessors
    
    var model: HBFilter?
    
    @IBOutlet var filterNameLabel: UILabel?
    @IBOutlet var tableView: UITableView?
    
    // MARK: - Interface Handling
    
    // MARK: - Public
    
    func fillWithModel(model: HBFilter) -> () {
        self.model = model

        self.filterNameLabel?.text = model.filterName
        
        self.tableView?.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let parameters = self.model!.parameters as NSArray? else {
            return 0
        }
        
        return parameters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("HBFilterParameterCell") as? HBFilterParameterCell
        if nil == cell {
            cell = NSBundle.mainBundle().loadNibNamed("HBFilterParameterCell", owner: nil, options: nil).first as? HBFilterParameterCell
        }
        
        let filterParameter = self.model!.parameters![indexPath.row] as! HBFilterParameter
        
        // refactor
        let parameterName = filterParameter.parameterName! as String
        let audioKitFilter = self.model?.audioKitFilter as! AKNode
        filterParameter.currentValue = audioKitFilter.valueForKey(parameterName) as? Int
        
        cell!.fillWithModel(filterParameter)
        cell!.parameterValueChangeHandler = { (value: Double, name: String) -> Void in
            filterParameter.parameterValueChangeHandler!(value: value, name: name)
        }
        
        return cell!
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let cells = self.tableView?.visibleCells
        
        for cell in cells! {
            let filterParameterCell = cell as! HBFilterParameterCell
            let touchPoint = touch.locationInView(filterParameterCell)
            
            if CGRectContainsPoint(filterParameterCell.frame, touchPoint) {
                self.resignFirstResponder()
                return false
            }
        }
        
        return true
    }
}
