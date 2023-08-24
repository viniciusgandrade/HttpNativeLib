//
//  CommonViewController.swift
//  HttpNativeLib
//
//  Created by Vinícius Gonçalves de Andrade on 09/08/23.
//

import Foundation

open class CommonViewController: UIViewController, UIScrollViewDelegate {
    var httpRequest = HttpRequest()
    var bundle = Bundle(url: Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent())
    private lazy var backgroundView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "background", in: bundle, compatibleWith: nil)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let spinnerView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.isHidden = true

        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()

        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var appLogoView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "app-logo", in: bundle, compatibleWith: nil)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var versionText: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fillProportionally
        view.spacing = 2
        let label1 = UILabel()
        label1.text = "Versão: \(httpRequest.getAppVersion())@\(httpRequest.getBuildVersion())"
        label1.font = UIFont.systemFont(ofSize: 16.0)
        label1.textColor = UIColor(red:130, green:130, blue:133, alpha:1.0000)

        view.addArrangedSubview(label1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var enabledBackgroundColor = UIColor(red: 0.17, green: 0.4, blue: 0.74, alpha: 1)
    var disabledBackgroundColor = UIColor(red: 0.17, green: 0.4, blue: 0.74, alpha: 0.4)

    private lazy var loginButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = enabledBackgroundColor
        view.tintColor = .white
        view.setTitle("Acessar", for: .normal)
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fillProportionally
        view.spacing = 2

        let label1 = UILabel()
        label1.text = "Acessar"
        label1.font = UIFont.systemFont(ofSize: 12.0)
        label1.textColor = UIColor(red:33, green:33, blue:33, alpha:1.0000)

        let label2 = UILabel()
        label2.text = "Minha conta"
        label2.font = UIFont.boldSystemFont(ofSize: 16.0)
        label2.textColor = UIColor(red:33, green:33, blue:33, alpha:1.0000)

        view.addArrangedSubview(label1)
        view.addArrangedSubview(label2)

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy public var cpfTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "CPF"
        textField.borderStyle = UITextField.BorderStyle.none
        textField.backgroundColor = .clear
        textField.font = UIFont.boldSystemFont(ofSize: 22.0)
        textField.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
        return textField
    }()

    private lazy var cpfView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 14

        let lineView = UIImageView(image: UIImage(named: "line", in: bundle, compatibleWith: nil))
        stackView.addArrangedSubview(cpfTextField)
        stackView.addArrangedSubview(lineView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy public var senhaTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Senha"
        textField.borderStyle = UITextField.BorderStyle.none
        textField.backgroundColor = .clear
        textField.font = UIFont.boldSystemFont(ofSize: 22.0)
        textField.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1)
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .go

        // Create a button for toggling the secure text entry
        let toggleButton = UIButton(type: .custom)
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        toggleButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        toggleButton.tintColor = UIColor(red: 0.17, green: 0.4, blue: 0.74, alpha: 1)
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        textField.rightView = toggleButton
        textField.rightViewMode = .always

        return textField
    }()

    private lazy var senhaView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 14

        let lineView = UIImageView(image: UIImage(named: "line", in: bundle, compatibleWith: nil))

        stackView.addArrangedSubview(senhaTextField)
        stackView.addArrangedSubview(lineView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var content: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 32

        stackView.addArrangedSubview(titleView)
        stackView.addArrangedSubview(cpfView)
        stackView.addArrangedSubview(senhaView)
        stackView.addArrangedSubview(loginButton)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
}

extension CommonViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateLoginButtonState()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    public func showLoading() {
        // Show the spinner view
        spinnerView.isHidden = false
    }

    public func hideLoading() {
        // Hide the spinner view
        spinnerView.isHidden = true
    }

    @objc func togglePasswordVisibility() {
        senhaTextField.isSecureTextEntry.toggle()

        if let toggleButton = senhaTextField.rightView as? UIButton {
            let imageName = senhaTextField.isSecureTextEntry ? "eye.slash" : "eye"
            if let image = UIImage(systemName: imageName) {
                toggleButton.setImage(image, for: .normal)
            }
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height - 100)
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @objc func formatCPF() {
        if let currentText = cpfTextField.text {
            let digitsOnly = currentText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            let formattedCPF = formataCPF(unformattedCPF: digitsOnly)

            cpfTextField.text = formattedCPF
            updateLoginButtonState()
        }
    }

    private func setupView() {
        view.backgroundColor = .white
        view.overrideUserInterfaceStyle = .light

        loginButton.addTarget(self, action: #selector(loginRequest), for: .touchUpInside)
        cpfTextField.delegate = self
        senhaTextField.delegate = self

        cpfTextField.addTarget(self, action: #selector(formatCPF), for: .editingChanged)

        view.addSubview(scrollView)

        scrollView.addSubview(backgroundView)
        scrollView.addSubview(appLogoView)
        scrollView.addSubview(content)
        scrollView.addSubview(versionText)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.widthAnchor.constraint(equalToConstant: view.bounds.width),
            backgroundView.heightAnchor.constraint(equalToConstant: view.bounds.height),
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appLogoView.widthAnchor.constraint(equalToConstant: 124),
            appLogoView.heightAnchor.constraint(equalToConstant: 18),
            appLogoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            appLogoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            content.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            content.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            content.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            content.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            versionText.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            versionText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
        view.addSubview(spinnerView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc open func loginRequest() {
        print("overrided method")
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UIAlertController
extension CommonViewController {
    func updateLoginButtonState() {
        let isValidCPF = cpfTextField.text?.isCPF ?? false
        let isValidPassword = isValidPasswordText(senhaTextField.text)
        loginButton.isEnabled = isValidCPF && isValidPassword
        if loginButton.isEnabled {
            loginButton.backgroundColor = enabledBackgroundColor
        } else {
            loginButton.backgroundColor = disabledBackgroundColor
        }
    }

    // Check if the password has more than one character
    func isValidPasswordText(_ password: String?) -> Bool {
        return (password?.count ?? 0) > 1
    }

    public func mensagemDeErro(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: "Atenção",
                message: message,
                preferredStyle: .alert
            )

            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)

            self.present(alertController, animated: true, completion: nil)
        }
    }

}


extension String {
    var isCPF: Bool {
        let numbers = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard numbers.count == 11 else { return false }

        let set = NSCountedSet(array: Array(numbers))
        guard set.count != 1 else { return false }

        let i1 = numbers.index(numbers.startIndex, offsetBy: 9)
        let i2 = numbers.index(numbers.startIndex, offsetBy: 10)
        let i3 = numbers.index(numbers.startIndex, offsetBy: 11)
        let d1 = Int(numbers[i1..<i2])
        let d2 = Int(numbers[i2..<i3])

        var temp1 = 0, temp2 = 0

        for i in 0...8 {
            let start = numbers.index(numbers.startIndex, offsetBy: i)
            let end = numbers.index(numbers.startIndex, offsetBy: i+1)
            let char = Int(numbers[start..<end])

            temp1 += char! * (10 - i)
            temp2 += char! * (11 - i)
        }

        temp1 %= 11
        temp1 = temp1 < 2 ? 0 : 11-temp1

        temp2 += temp1 * 2
        temp2 %= 11
        temp2 = temp2 < 2 ? 0 : 11-temp2

        return temp1 == d1 && temp2 == d2
    }
}

// MARK: - UITextFieldDelegate
extension CommonViewController: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cpfTextField {
            if textField.keyboardType != .numberPad {
                textField.keyboardType = .numberPad
                textField.reloadInputViews() // Refresh the input view to show the numeric keyboard
            }
        }
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        // Reset the keyboard type to its original state if needed
        textField.keyboardType = .default // Change to the appropriate keyboard type
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == senhaTextField {
            loginRequest()
            return false
        }
        return true
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == senhaTextField {
            updateLoginButtonState()
        }
        return true;
    }

    func formataCPF(unformattedCPF: String) -> String {
        let mask = "###.###.###-##"
        var maskedCPF = ""
        var index = unformattedCPF.startIndex

        for char in mask {
            if index == unformattedCPF.endIndex { break }

            if char == "#" {
                maskedCPF.append(unformattedCPF[index])
                index = unformattedCPF.index(after: index)
            } else {
                maskedCPF.append(char)
            }
        }

        return maskedCPF
    }

    public func removeCPFMascara(formattedCPF: String) -> String {
        return formattedCPF.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }


}
