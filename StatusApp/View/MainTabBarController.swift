//
//  MainTabBarController.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//


import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inizializza i 4 ViewController principali:
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: nil)

        let chartsVC = ChartsViewController()
        chartsVC.tabBarItem = UITabBarItem(title: "Grafici", image: UIImage(systemName: "chart.bar"), selectedImage: nil)

        let surveysVC = SurveysViewController()
        surveysVC.tabBarItem = UITabBarItem(title: "Sondaggi", image: UIImage(systemName: "list.bullet"), selectedImage: nil)

        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "Profilo", image: UIImage(systemName: "person"), selectedImage: nil)

        // Facoltativo: Avvolgere ogni VC in una UINavigationController (se vuoi abilitare push, back, ecc.)
        let homeNav    = UINavigationController(rootViewController: homeVC)
        let chartsNav  = UINavigationController(rootViewController: chartsVC)
        let surveysNav = UINavigationController(rootViewController: surveysVC)
        let profileNav = UINavigationController(rootViewController: profileVC)

        viewControllers = [homeNav, chartsNav, surveysNav, profileNav]

        // Stile del tab bar (facoltativo)
        tabBar.tintColor = AppColor.dark
        tabBar.barTintColor = AppColor.accentCoral
    }
}
