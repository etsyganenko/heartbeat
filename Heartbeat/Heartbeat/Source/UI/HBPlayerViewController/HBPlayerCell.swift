//
//  HBPlayerCell.swift
//  Heartbit
//
//  Created by Artem on 6/13/16.
//  Copyright © 2016 IDAP. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit

class HBPlayerCell: UITableViewCell {

    // MARK: - Accessors

    var audioFileName: NSString?
    
    var playButtonHandler: ((button: UIButton, filePath: String) -> Void)?
    var processButtonHandler: ((button: UIButton, fileName: String, filePath: String) -> Void)?
    
    @IBOutlet var playButton: UIButton?
    @IBOutlet var processButton: UIButton?
    
    @IBOutlet var titleLabel: UILabel?
    
    var filePath: String? {
        get {
            return NSBundle.mainBundle().pathForResource(self.audioFileName as String?, ofType:"wav")!
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel?.text = self.audioFileName as? String
    }
    
    // MARK: - Public
    
    @IBAction func onPlay(sender: UIButton) {
        self.playButtonHandler!(button: sender, filePath: self.filePath!)
    }
    
    @IBAction func onProcess(sender: UIButton) {
        self.processButtonHandler?(button: sender, fileName: self.audioFileName! as String, filePath: self.filePath!)
    }
}
