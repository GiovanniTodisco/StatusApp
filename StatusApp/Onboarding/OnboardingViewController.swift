//
//  OnboardingViewController.swift
//  StatusApp
//
//  Created by Area mobile on 04/04/25.
//

import UIKit
import ResearchKit
import HealthKit

class OnboardingViewController: UIViewController {
    
    private var hasFinishedOnboarding = false
    private var loadingIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hasFinishedOnboarding: ", hasFinishedOnboarding)
        print("onboarding completed key", UserDefaults.standard.bool(forKey: Constants.ONBOARDING_COMPLETED_KEY))
        
        if UserDefaults.standard.bool(forKey: Constants.ONBOARDING_COMPLETED_KEY) || hasFinishedOnboarding {
            navigateToDashboard()
        } else {
            presentOnboarding()
        }
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        view.addSubview(spinner)
        loadingIndicator = spinner
    }
    
    
    func presentOnboarding() {
        let taskViewController = ORKTaskViewController(task: OnboardingTaskFactory.makeOnboardingTask(), taskRun: nil)
        taskViewController.delegate = self
        taskViewController.modalPresentationStyle = .fullScreen
        taskViewController.view.tintColor = AppColor.primaryIcon
        present(taskViewController, animated: true)
    }
    
    func navigateToDashboard(completion: (() -> Void)? = nil) {
        let splashVC = SplashViewController()
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            window.rootViewController = splashVC
            window.makeKeyAndVisible()
            
            Task {
                let isHealthKitGranted = UserDefaults.standard.bool(forKey: Constants.HEALTHKIT_PERMISSION_KEY)
                if !isHealthKitGranted {
                    await self.requestHealthKitAuthorization()
                }
                
                let mainTabBarController = MainTabBarController()
                UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = mainTabBarController
                }, completion: { _ in
                    window.makeKeyAndVisible()
                    completion?()
                })
            }
        } else {
            completion?()
        }
    }
    
    func requestHealthKitAuthorization() async {
        do {
            let isAuthorized = try await HealthKitManager.shared.requestAuthorization()
            print("HealthKit autorizzato: \(isAuthorized)")
            UserDefaults.standard.set(isAuthorized, forKey: Constants.HEALTHKIT_PERMISSION_KEY)
        } catch {
            print("Errore durante la richiesta di autorizzazione a HealthKit: \(error.localizedDescription)")
        }
    }
}

extension OnboardingViewController: ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        
        switch step.identifier {
        case OnboardingConstants.introStep:
            return CustomIntroStepViewController(step: step)
        case OnboardingConstants.consentInfoStep:
            return CustomConsentInfoStepViewController(step: step)
        case OnboardingConstants.consentReviewStep:
            return CustomConsentReviewStepViewController(step: step)
        case OnboardingConstants.personalDataStep:
            return CustomPersonalDataStepViewController(step: step)
        default:
            return nil
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true) {
            if reason == .completed {
                print("Onboarding completato!")
                UserDefaults.standard.set(true, forKey: Constants.ONBOARDING_COMPLETED_KEY)
                
                if let personalDataResult = taskViewController.result.stepResult(forStepIdentifier: OnboardingConstants.personalDataStep) {
                    let firstNameResult = personalDataResult.result(forIdentifier: "firstName") as? ORKTextQuestionResult
                    let lastNameResult = personalDataResult.result(forIdentifier: "lastName") as? ORKTextQuestionResult
                    let birthDateResult = personalDataResult.result(forIdentifier: "birthDate") as? ORKDateQuestionResult
                    let heightResult = personalDataResult.result(forIdentifier: "height") as? ORKNumericQuestionResult
                    let weightResult = personalDataResult.result(forIdentifier: "weight") as? ORKNumericQuestionResult
                    
                    if let firstName = firstNameResult?.textAnswer?.trimmingCharacters(in: .whitespacesAndNewlines),
                       let lastName = lastNameResult?.textAnswer?.trimmingCharacters(in: .whitespacesAndNewlines),
                       let birthDate = birthDateResult?.dateAnswer,
                       let height = heightResult?.numericAnswer?.stringValue,
                       let weight = weightResult?.numericAnswer?.stringValue {
                        print("Dati raccolti - Nome: \(firstName), Cognome: \(lastName), Data di nascita: \(birthDate), Altezza: \(height), Peso: \(weight)")
                        let profile = UserProfile(firstName: firstName, lastName: lastName, birthDate: birthDate, height: height, weight: weight)
                        profile.save()
                        print("Profilo utente salvato correttamente")
                        _ = UIDevice.appUserID
                    }
                    
                    self.hasFinishedOnboarding = true
                    
                    self.navigateToDashboard {
                        let isHealthKitGranted = UserDefaults.standard.bool(forKey: Constants.HEALTHKIT_PERMISSION_KEY)
                        if !isHealthKitGranted {
                            Task {
                                await self.requestHealthKitAuthorization()
                            }
                        }
                    }
                }
                
            } else {
                self.navigateToDashboard()
            }
        }
    }
}
