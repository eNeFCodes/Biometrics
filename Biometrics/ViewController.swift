//
//  ViewController.swift
//  Biometrics
//
//  Created by Neil Francis Hipona on 2/28/22.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Test Biometrics", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.black, for: .normal)
        return button
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Not Authenticated"
        label.textAlignment = .center
        return label
    }()

    private enum Status {
        case `default`
        case authenticated
        case error
    }

    private var currentStatus: Status = .default {
        didSet {
            let auth = currentStatus  == .authenticated
            statusLabel.text = auth ? "Authenticated" : "Not Authenticated"
            statusLabel.textColor = auth ? .green : .red
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.


        view.addSubview(statusLabel)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 140),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),

            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])

        button.addTarget(self, action: #selector(triggerBiometrics), for: .touchUpInside)
    }

    @objc private func triggerBiometrics() {
        currentStatus = .default // reset

        let context = LAContext()
        context.localizedCancelTitle = "Use Default Login"

        var error: NSError?
        let policy: LAPolicy = .deviceOwnerAuthentication

        if context.canEvaluatePolicy(policy, error: &error) {
            context.evaluatePolicy(policy, localizedReason: "Log in using biometrics") { success, error in
                DispatchQueue.main.async { [unowned self] in
                    if success {
                        currentStatus = .authenticated
                    } else {
                        let errorMsg = error?.localizedDescription ?? "Failed to authenticate"
                        showError(errorMsg: errorMsg)
                    }
                }
            }
        } else {
            let errorMsg = error?.localizedDescription ?? "Can't evaluate policy"
            showError(errorMsg: errorMsg)
        }
    }

    private func showError(errorMsg: String) {
        currentStatus = .error
        let alert = UIAlertController.init(title: "Error", message: errorMsg, preferredStyle: .alert)
        alert.addAction(.init(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

