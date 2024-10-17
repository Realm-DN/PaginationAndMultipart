//
//  ToastVC.swift
//  XITechMT
//
//  Created by Dev Rana on 17/10/24.
//

import UIKit

class Toast {
    static func showToast(message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return }
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        toastContainer.layer.cornerRadius = 25
        toastContainer.alpha = 0.0

        let toastLabel = UILabel()
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = toastLabel.font.withSize(12)
        toastLabel.text = message
        toastLabel.numberOfLines = 0

        toastContainer.addSubview(toastLabel)
        window.addSubview(toastContainer)
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        toastLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            toastContainer.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 65),
            toastContainer.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -65),
            toastContainer.topAnchor.constraint(equalTo: window.topAnchor, constant: 75),
            
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 15),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -15),
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 15),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -15)
        ])
        UIView.animate(withDuration: 0.5, animations: {
            toastContainer.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
}
