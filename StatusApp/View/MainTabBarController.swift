//
//  MainTabBarController.swift
//  StatusApp
//
//  Created by Area mobile on 06/04/25.
//


import UIKit

protocol Loadable {
    func loadData() async throws
}

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColor.cardBackground

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance // <-- questa è la chiave!
        

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

        Task {
            await loadData()
        }
    }

    func loadData() async {
        let isHealthKitAuthorized = UserDefaults.standard.bool(forKey: Constants.HEALTHKIT_PERMISSION_KEY)
        if isHealthKitAuthorized {
            print("HealthKit autorizzato, caricamento dati...")
            // Carica i dati da HealthKit
            for viewController in viewControllers ?? [] {
                if let navController = viewController as? UINavigationController {
                    if let topViewController = navController.topViewController {
                        if let loadableViewController = topViewController as? Loadable {
                            print("Caricamento dati per \(type(of: loadableViewController))")
                            do {
                                try await loadableViewController.loadData()
                                print("Dati caricati correttamente per \(type(of: loadableViewController))")
                            } catch {
                                print("Errore durante il caricamento dei dati per \(type(of: loadableViewController)): \(error.localizedDescription)")
                            }
                        } else {
                            print("Il view controller \(type(of: topViewController)) non implementa il protocollo Loadable")
                        }
                    }
                }
            }
        } else {
            print("HealthKit non autorizzato")
            // Gestisci il caso in cui l'autorizzazione non è stata concessa
            // Ad esempio, mostra un messaggio di errore o reindirizza l'utente a una schermata di impostazioni
        }
    }

}
