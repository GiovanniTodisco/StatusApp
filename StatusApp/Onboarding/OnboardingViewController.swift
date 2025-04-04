//
//  OnboardingViewController.swift
//  StatusApp
//
//  Created by Area mobile on 04/04/25.
//


import UIKit
import ResearchKit

class OnboardingViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentOnboarding()
    }

    func presentOnboarding() {
        let taskViewController = ORKTaskViewController(task: OnboardingTaskFactory.makeOnboardingTask(), taskRun: nil)
        taskViewController.delegate = self
        taskViewController.modalPresentationStyle = .fullScreen
        taskViewController.view.tintColor = AppColor.primary
        present(taskViewController, animated: true)
    }
}

extension OnboardingViewController: ORKTaskViewControllerDelegate {

    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        return CustomIntroStepViewController(step: step)
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true) {
            if reason == .completed {
                print("Onboarding completato!")
                UserDefaults.standard.set(true, forKey: Constants.onboardingCompletedKey)
                // Navigazione dashboard
                 
                 
            }
        }
    }
}
