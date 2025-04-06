//
//  CustomConsentReviewStepViewController.swift
//  StatusApp
//
//  Created by Area mobile on 05/04/25.
//


import ResearchKit
import UIKit

class CustomConsentReviewStepViewController: ORKConsentReviewStepViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //view.backgroundColor = AppColor.cardBackground

        self.cancelButtonItem = nil
        self.title = nil
        
    }
        
}
