//
//  HBFilterParameterCell.swift
//  Heartbeat
//
//  Created by Artem on 6/15/16.
//  Copyright © 2016 IDAP. All rights reserved.
//

import UIKit

class HBFilterParameterCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.slider?.setThumbImage(UIImage(named: "SliderIcon"), forState: UIControlState.Normal)
        self.slider?.setThumbImage(UIImage(named: "SliderIcon"), forState: UIControlState.Selected)
        self.slider?.setThumbImage(UIImage(named: "SliderIcon"), forState: UIControlState.Highlighted)
    }

    // MARK: - Accessors
    
    var model: HBFilterParameter?
    
    @IBOutlet var slider: UISlider?
    @IBOutlet var parameterDescriptionLabel: UILabel?
    @IBOutlet var parameterValueLabel: UILabel?
    
    var parameterValueChangeHandler: ((value: Double, name: String) -> Void)?
    
    // MARK: - Public
    
    func fillWithModel(model: HBFilterParameter) -> () {
        self.model = model
        
        self.parameterDescriptionLabel?.text = model.parameterDescription
        self.parameterValueLabel?.text = NSString(format: "%d", model.currentValue!) as String
        
        self.slider?.minimumValue = Float(model.minimumValue!)
        self.slider?.maximumValue = Float(model.maximumValue!)
        self.slider?.setValue(Float(model.currentValue!), animated: false)
        self.slider?.continuous = true
    }
    
    // MARK: - Interface Handling
    
    @IBAction func changeParameterValue(sender: UISlider) {
        let parameterName = self.model!.parameterName as String?
        
        self.parameterValueLabel?.text = String(Int(sender.value))
        self.model?.currentValue = Int(sender.value)
        self.parameterValueChangeHandler!(value: Double(sender.value), name: parameterName!)
    }
}
