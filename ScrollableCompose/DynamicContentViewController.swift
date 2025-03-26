//
//  DynamicContentViewController.swift
//  ScrollableCompose
//
//  Created by ASHIS LAHA on 3/23/25.
//

import UIKit

class DynamicContentViewController: UIViewController {
    
    private let mainStackView = UIStackView()
    private let headerView = UILabel()
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    // bottom constraint of mainStackView
    // It handles keyboard appearance and dismiss scenario
    private var bottomConstraint: NSLayoutConstraint!
    
    // Handle scroll view height, so that it will go beyond certain limit
    private var scrollViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // Allows other interactions like button taps
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        setupViews()
        setupConstraints()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func dismissKeyboard() {
        // Dismisses the keyboard for any active text field or text view
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        // Calculate the keyboard height
        let keyboardHeight = keyboardFrame.height
        
        // Move the view up by keyboard height
        UIView.animate(withDuration: duration) {
            self.bottomConstraint.constant = -keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        // Restore original position
        UIView.animate(withDuration: duration) {
            self.bottomConstraint.constant = 0
        }
    }
    
    /*
     view-hierarchy (top-down):
     |--> mainStackView (stackView)
     |      |--> headerView (sticky - non-scrollable)
     |      |--> scroll view (UIScrollView)
     |      |         |--> contentStackView (UIStackView)
     |      |                      |--> Text View
     |      |                      |--> UIView
     |      |                      |--> Text View
     */
    private func setupViews() {
        // Main stack view setup
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        mainStackView.distribution = .fill
        mainStackView.layer.cornerRadius = 8.0
        mainStackView.layer.borderColor = UIColor.gray.cgColor
        mainStackView.layer.borderWidth = 1
        view.addSubview(mainStackView)
        
        // Header view setup (your static view)
        headerView.backgroundColor = .green
        headerView.text = "This is non-scrollable header"
        headerView.textAlignment = .center
        mainStackView.addArrangedSubview(headerView)
        
        // ScrollView setup
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        mainStackView.addArrangedSubview(scrollView)
        
        // Content stack view setup
        contentStackView.axis = .vertical
        contentStackView.spacing = 10
        contentStackView.distribution = .fill
        scrollView.addSubview(contentStackView)
        
        // Add your dynamic content
        addContentItems()
    }
    
    private func addContentItems() {
        // Add your UIViews and UITextViews to contentStackView
        // Example:
        addTextView(text: "Type your text here...")
        addView(height: 80)
        addTextView(text: "Type ..")
    }
    
    /*
     view-hierarchy (top-down):
     |--> mainStackView (stackView)
     |      |--> headerView (sticky - non-scrollable)
     |      |--> scroll view (UIScrollView)
     |      |         |--> contentStackView (UIStackView)
     |      |                      |--> Text View
     |      |                      |--> UIView
     |      |                      |--> Text View
     */
    private func setupConstraints() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomConstraint = mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        
        let contentHeight = contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: contentHeight)
        
        NSLayoutConstraint.activate([
            // Main stack view constraints
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            bottomConstraint,
            
            // Header height constraint - adjust as needed
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            // Content stack view constraints
            scrollView.topAnchor.constraint(equalTo: contentStackView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentStackView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor),
            
            // scroll view width will be controlled by contentStackView
            scrollView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            
            // Scroll will grow based on contentStackView height.
            scrollViewHeightConstraint
        ])
    }
    
    private func addTextView(text: String) {
        let textView = UITextView()
        textView.isScrollEnabled = false // Important for auto-sizing
        textView.text = text
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.delegate = self
        textView.layer.cornerRadius = 8.0
        textView.layer.borderColor = UIColor.systemBlue.cgColor
        textView.layer.borderWidth = 1
        
        contentStackView.addArrangedSubview(textView)
        
        // Set minimum height
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
    }
    
    private func addView(height: CGFloat) {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "Another label with text - part of scrollable scrollview. It will scroll when content height > 250"
        label.textAlignment = .center
        label.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        label.heightAnchor.constraint(equalToConstant: height).isActive = true
        contentStackView.addArrangedSubview(label)
    }
    
    public func addViewToStackTop() {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Dynamic Label at top"
        label.textAlignment = .center
        label.backgroundColor = .systemYellow.withAlphaComponent(0.3)
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentStackView.insertArrangedSubview(label, at: 0)
        updateScrollViewHeight()
    }

    public func removeViewFromStackTop() {
        let subviews = contentStackView.arrangedSubviews
        guard let firstView = subviews.first else { return }
        if firstView is UITextView {
            // stop if it is UITextView
            return
        }
        
        firstView.removeFromSuperview()
        contentStackView.removeArrangedSubview(firstView)
        
        updateScrollViewHeight()
    }
    
    public func addViewToStackBottom() {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Dynamic Label at bottom"
        label.textAlignment = .center
        label.backgroundColor = .systemYellow.withAlphaComponent(0.3)
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let lastIndex = contentStackView.arrangedSubviews.count
        contentStackView.insertArrangedSubview(label, at: lastIndex)
        updateScrollViewHeight()
    }

    public func removeViewFromStackBottom() {
        let subviews = contentStackView.arrangedSubviews
        guard let lastView = subviews.last else { return }
        if lastView is UITextView {
            // stop if it is UITextView
            return
        }
        
        lastView.removeFromSuperview()
        contentStackView.removeArrangedSubview(lastView)
        
        updateScrollViewHeight()
    }
}

// MARK: - UITextViewDelegate
extension DynamicContentViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        // Trigger layout update when text changes
        updateScrollViewHeight()
    }
    
    func updateScrollViewHeight() {
        let contentHeight = contentStackView.bounds.height // Get actual content height
        // let contentHeight = contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        let maxScrollViewHeight: CGFloat = 250 // Define upper limit for scroll view height

        if contentHeight >= maxScrollViewHeight {
            scrollViewHeightConstraint.constant = maxScrollViewHeight
        } else {
            scrollViewHeightConstraint.constant = contentHeight
        }

        view.layoutIfNeeded() // Apply the constraint updates
    }
}
