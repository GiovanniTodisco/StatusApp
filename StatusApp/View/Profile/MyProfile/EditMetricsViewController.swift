//
//  EditMetricsViewController.swift
//  StatusApp
//
//  Created by Area mobile on 22/04/25.
//

import UIKit

protocol EditMetricsViewControllerDelegate: AnyObject {
    func didUpdateMetrics()
}

class EditMetricsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    weak var delegate: EditMetricsViewControllerDelegate?

    private let heightPicker = UIPickerView()
    private let weightPicker = UIPickerView()
    private let heights = Array(30...300)
    private let weights = Array(30...300)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.backgroundColor

        guard let profile = UserProfile.load(),
              let currentHeight = Int(profile.height),
              let currentWeight = Int(profile.weight) else { return }

        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("edit_data", comment: "")
        titleLabel.font = AppFont.title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let heightTitle = UILabel()
        heightTitle.text = NSLocalizedString("form_height", comment: "")
        heightTitle.font = AppFont.info
        heightTitle.translatesAutoresizingMaskIntoConstraints = false

        let weightTitle = UILabel()
        weightTitle.text = NSLocalizedString("form_weight", comment: "")
        weightTitle.font = AppFont.info
        weightTitle.translatesAutoresizingMaskIntoConstraints = false

        heightPicker.dataSource = self
        heightPicker.delegate = self
        heightPicker.translatesAutoresizingMaskIntoConstraints = false
        if let index = heights.firstIndex(of: currentHeight) {
            heightPicker.selectRow(index, inComponent: 0, animated: false)
        }

        weightPicker.dataSource = self
        weightPicker.delegate = self
        weightPicker.translatesAutoresizingMaskIntoConstraints = false
        if let index = weights.firstIndex(of: currentWeight) {
            weightPicker.selectRow(index, inComponent: 0, animated: false)
        }

        // Horizontal stack for height
        let heightStack = UIStackView()
        heightStack.axis = .horizontal
        heightStack.spacing = 12
        heightStack.alignment = .center
        heightStack.translatesAutoresizingMaskIntoConstraints = false
        heightStack.addArrangedSubview(heightTitle)
        heightStack.addArrangedSubview(heightPicker)
        // Optionally, set a width for the label for alignment
        heightTitle.widthAnchor.constraint(equalToConstant: 80).isActive = true

        // Horizontal stack for weight
        let weightStack = UIStackView()
        weightStack.axis = .horizontal
        weightStack.spacing = 12
        weightStack.alignment = .center
        weightStack.translatesAutoresizingMaskIntoConstraints = false
        weightStack.addArrangedSubview(weightTitle)
        weightStack.addArrangedSubview(weightPicker)
        // Optionally, set a width for the label for alignment
        weightTitle.widthAnchor.constraint(equalToConstant: 80).isActive = true

        let heightCard = UIView()
        heightCard.backgroundColor = AppColor.backgroundColorCard
        heightCard.layer.cornerRadius = 12
        heightCard.layer.masksToBounds = true
        heightCard.translatesAutoresizingMaskIntoConstraints = false

        heightCard.addSubview(heightStack)
        NSLayoutConstraint.activate([
            heightStack.topAnchor.constraint(equalTo: heightCard.topAnchor, constant: 12),
            heightStack.bottomAnchor.constraint(equalTo: heightCard.bottomAnchor, constant: -12),
            heightStack.leadingAnchor.constraint(equalTo: heightCard.leadingAnchor, constant: 16),
            heightStack.trailingAnchor.constraint(equalTo: heightCard.trailingAnchor, constant: -16)
        ])

        let weightCard = UIView()
        weightCard.backgroundColor = AppColor.backgroundColorCard
        weightCard.layer.cornerRadius = 12
        weightCard.layer.masksToBounds = true
        weightCard.translatesAutoresizingMaskIntoConstraints = false

        weightCard.addSubview(weightStack)
        NSLayoutConstraint.activate([
            weightStack.topAnchor.constraint(equalTo: weightCard.topAnchor, constant: 12),
            weightStack.bottomAnchor.constraint(equalTo: weightCard.bottomAnchor, constant: -12),
            weightStack.leadingAnchor.constraint(equalTo: weightCard.leadingAnchor, constant: 16),
            weightStack.trailingAnchor.constraint(equalTo: weightCard.trailingAnchor, constant: -16)
        ])

        let stack = UIStackView(arrangedSubviews: [heightCard, weightCard])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false

        let saveButton = UIButton(type: .system)
        saveButton.setTitle(NSLocalizedString("save", comment: ""), for: .normal)
        saveButton.titleLabel?.font = AppFont.button
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = AppColor.primaryIcon
        saveButton.layer.cornerRadius = 10
        saveButton.addTarget(self, action: #selector(saveResult), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)
        view.addSubview(stack)
        view.addSubview(saveButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -54),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView == heightPicker ? heights.count : weights.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerView == heightPicker ? "\(heights[row]) cm" : "\(weights[row]) kg"
    }

    @objc private func saveResult() {
        let selectedHeight = heights[heightPicker.selectedRow(inComponent: 0)]
        let selectedWeight = weights[weightPicker.selectedRow(inComponent: 0)]

        guard var profile = UserProfile.load() else { return }
        profile.height = "\(selectedHeight)"
        profile.weight = "\(selectedWeight)"
        profile.save()

        delegate?.didUpdateMetrics()
        dismiss(animated: true)
    }
}
