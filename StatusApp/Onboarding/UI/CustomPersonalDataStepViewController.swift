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

        self.cancelButtonItem = nil
        self.internalSkipButtonItem = nil

        let footerLabel = UILabel()
        footerLabel.text = NSLocalizedString("personal_data_footer", comment: "")
        footerLabel.textColor = AppColor.dark
        footerLabel.font = AppFont.info
        footerLabel.numberOfLines = 0
        footerLabel.textAlignment = .center
        footerLabel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(footerLabel)

        NSLayoutConstraint.activate([
            footerLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            footerLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            footerLabel.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            footerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
    }
}
