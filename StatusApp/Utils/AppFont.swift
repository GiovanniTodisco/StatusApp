//
//  AppColor.swift
//  StatusApp
//
//  Created by Area mobile on 04/04/25.
//

import UIKit

enum AppFont {
    static func custom(_ name: String, size: CGFloat) -> UIFont {
        return UIFont(name: name, size: size)!
    }

    static var title: UIFont {
        return custom("AvenirNextCyr-Bold", size: Constants.titleSize)
    }

    static var primary: UIFont {
        return custom("AvenirNextCyr-Regular", size: Constants.primaryTextSize)
    }
    
    static var description: UIFont {
        return custom("AvenirNextCyr-Thin", size: Constants.descriptionTextSize)
    }

    static var button: UIFont {
        return custom("AvenirNextCyr-Medium", size: Constants.buttonTextSize)
    }
}
