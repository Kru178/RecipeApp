//
//  RecipeViewController.swift
//  RecipeApp
//
//  Created by Bair Nadtsalov on 3.06.2023.
//

import UIKit

final class RecipeViewController: UIViewController {
    
    // MARK: - UI
    
    // TODO: add dots as placeholder?
    private let nameLabel = UILabel.makeLabel(text: "Name")
    private let nameTextField = CustomTextField.makeTextField()
    private let scrollView = CustomScrollView()
    
    private let rightButton = UIButton.makeButton(withImage: "shareImage")
    private let leftButton = UIButton.makeButton(withImage: "editImage")
    private lazy var containerView = ButtonsConteinerView(leftButton: leftButton, rightButton: rightButton)
    
    private lazy var isEditingMode = false {
        didSet {
            setButtons(isEditing: isEditingMode)
        }
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    
    // MARK: - Private methods
    
    private func configureView() {
        
        isEditingMode = false
        
        view.backgroundColor = Colors.mainBackgroundColor
        
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(scrollView)
        view.addSubview(containerView)
        
        view.directionalLayoutMargins = Metrics.Margins.recipeScreenMargins
        let margins = view.layoutMarginsGuide
        let content = scrollView.contentLayoutGuide
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: margins.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            nameLabel.topAnchor.constraint(equalToSystemSpacingBelow: containerView.bottomAnchor, multiplier: 1),
            nameLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            
            nameTextField.topAnchor.constraint(equalToSystemSpacingBelow: nameLabel.bottomAnchor, multiplier: 1),
            nameTextField.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: nameLabel.font.pointSize * 1.5),
            
            scrollView.widthAnchor.constraint(equalTo: content.widthAnchor, multiplier: 1),
            
            scrollView.topAnchor.constraint(equalToSystemSpacingBelow: nameTextField.bottomAnchor, multiplier: 1),
            scrollView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        ])
    }
    
    @objc private func shareButtonTapped() {
        // Prepare the text to share
        let recipeName = nameTextField.text ?? ""
//        let recipeIngredients = ingredientsTextView.text ?? ""
//        let recipeMethod = methodTextView.text ?? ""
//        let recipeLink = linkTextField.text ?? ""
        
        let shareText = "Recipe Name: \(recipeName)"
        
        let activityViewController = UIActivityViewController(activityItems: [shareText],
                                                              applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func editButtonTapped() {
        // Toggle editing
        isEditingMode.toggle()
        nameTextField.becomeFirstResponder()
    }
    
    @objc func cancelChanges() {
        print("cancel")
        isEditingMode.toggle()
        view.endEditing(true)
    }
    
    @objc func saveRecipe() {
        print("save recipe")
        isEditingMode.toggle()
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    private func setButtons(isEditing: Bool) {
        
        let leftButtonImageName = isEditing ? "saveImage" : "editImage"
        let rightButtonImageName = isEditing ? "cancelImage" : "shareImage"
        leftButton.setImage(UIImage(named: leftButtonImageName), for: .normal)
        rightButton.setImage(UIImage(named: rightButtonImageName), for: .normal)
        
        if isEditing {
            leftButton.removeTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            leftButton.addTarget(self, action: #selector(saveRecipe), for: .touchUpInside)
            rightButton.removeTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
            rightButton.addTarget(self, action: #selector(cancelChanges), for: .touchUpInside)
        } else {
            leftButton.removeTarget(self, action: #selector(saveRecipe), for: .touchUpInside)
            leftButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            rightButton.removeTarget(self, action: #selector(cancelChanges), for: .touchUpInside)
            rightButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        }
    }
    
}

// MARK: - Private extensions

private extension UILabel {
    
    static func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.AmericanTypewriter, size: 18.0)
        label.textColor = .white
        label.text = text
        return label
    }
}

private extension UIButton {
    static func makeButton(withImage image: String) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        button.setImage(UIImage(named: image), for: .normal)
        return button
    }
}
