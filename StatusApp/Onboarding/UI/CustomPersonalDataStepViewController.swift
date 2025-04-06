//
//  CustomPersonalDataStepViewController.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//

import UIKit
import ResearchKit

class CustomPersonalDataStepViewController: ORKFormStepViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = AppColor.cardBackground
        self.cancelButtonItem = nil
        self.internalSkipButtonItem = nil
        
    }
}
