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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hasFinishedOnboarding: ", hasFinishedOnboarding)
        print("onboarding completed key", UserDefaults.standard.bool(forKey: Constants.ONBOARDING_COMPLETED_KEY))
        
        if UserDefaults.standard.bool(forKey: Constants.ONBOARDING_COMPLETED_KEY) || hasFinishedOnboarding {
            navigateToDashboard()
        } else {
            presentOnboarding()
        }
    }
    
    
    func presentOnboarding() {
        let taskViewController = ORKTaskViewController(task: OnboardingTaskFactory.makeOnboardingTask(), taskRun: nil)
        taskViewController.delegate = self
        taskViewController.modalPresentationStyle = .fullScreen
        taskViewController.view.tintColor = AppColor.dark
        present(taskViewController, animated: true)
    }
    
    func navigateToDashboard() {
        let mainTabBarController = MainTabBarController()

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            
            UIView.transition(
                        with: window,
                        duration: 0.5,
                        options: .transitionCrossDissolve,
                        animations: {
                            window.rootViewController = mainTabBarController
                        },
                        completion: nil
                    )
            
            window.rootViewController = mainTabBarController
            window.makeKeyAndVisible()
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

                    if let firstName = firstNameResult?.textAnswer,
                       let lastName = lastNameResult?.textAnswer,
                       let birthDate = birthDateResult?.dateAnswer {
                        let profile = UserProfile(firstName: firstName, lastName: lastName, birthDate: birthDate)
                        profile.save()
                    }
                    
                    self.hasFinishedOnboarding = true
                }
                // Navigazione dashboard
            }
            
            self.navigateToDashboard()
        }
    }
    
}
