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
        return UIFont.systemFont(ofSize: Constants.TITLE_SIZE, weight: .bold)
    }
    
    static var welcome: UIFont {
        return UIFont.systemFont(ofSize: Constants.WELCOME_SIZE, weight: .bold)
    }
    
    static var info: UIFont {
        return UIFont.systemFont(ofSize: Constants.DESCRIPTION_TEXT_SIZE, weight: .semibold)
    }
    
    static var description: UIFont {
        return UIFont.systemFont(ofSize: Constants.DESCRIPTION_TEXT_SIZE, weight: .regular)
    }
    
    static var italicDescription: UIFont {
        let descriptor = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .body)
            .withSymbolicTraits([.traitItalic, .traitBold])

        return UIFont(descriptor: descriptor!, size: Constants.DESCRIPTION_TEXT_SIZE)
    }
    
    static var italicInfo: UIFont {
        let descriptor = UIFontDescriptor
            .preferredFontDescriptor(withTextStyle: .body)
            .withSymbolicTraits([.traitItalic, .traitBold])

        return UIFont(descriptor: descriptor!, size: Constants.CAMPIONE_TEXT_SIZE)
    }
    
    static var button: UIFont {
        return UIFont.systemFont(ofSize: Constants.BUTTON_TEXT_SIZE, weight: .regular)
    }
    
    static var detail: UIFont {
        return UIFont.systemFont(ofSize: Constants.DETAIL_TEXT_SIZE, weight: .regular)
    }
}
