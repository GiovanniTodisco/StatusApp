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

    static var appName: UIFont {
        return custom("AvenirNextCyr-Bold", size: Constants.APP_NAME_SIZE)
    }

    static var titleIntro: UIFont {
        return custom("AvenirNextCyr-Bold", size: Constants.TITLE_SIZE_INTRO)
    }
    
    static var title: UIFont {
        return custom("AvenirNextCyr-Bold", size: Constants.TITLE_SIZE)
    }

    static var primary: UIFont {
        return custom("AvenirNextCyr-Regular", size: Constants.PRIMARY_TEXT_SIZE)
    }
    
    static var description: UIFont {
        return custom("AvenirNextCyr-Light", size: Constants.DESCRIPTION_TEXT_SIZE)
    }
    
    static var info: UIFont {
        return custom("AvenirNextCyr-ThinItalic", size: Constants.DESCRIPTION_TEXT_SIZE)
    }

    static var button: UIFont {
        return custom("AvenirNextCyr-Medium", size: Constants.BUTTON_TEXT_SIZE)
    }
}
