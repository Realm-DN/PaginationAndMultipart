//
//  CustomButton.swift
//  XITechMT
//
//  Created by Dev Rana on 17/10/24.
//

import Foundation

import UIKit
// 1
//get from "https://betterprogramming.pub/how-to-create-a-button-with-loading-indicator-in-ios-b579e063b91c"
class LoaderButton: UIButton {
    // 2
    var spinner = UIActivityIndicatorView()
    // 3
    var isLoading = false {
        didSet {
            // whenever `isLoading` state is changed, update the view
            updateView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // 4
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        // 5
        spinner.hidesWhenStopped = true
        // to change spinner color
        spinner.color = .black
        // default style
        spinner.style = .medium
        
        // 6
        // add as button subview
        addSubview(spinner)
        // set constraints to always in the middle of button
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    // 7
    func updateView() {
        if isLoading {
            spinner.startAnimating()
            titleLabel?.alpha = 0
            imageView?.alpha = 0
            // to prevent multiple click while in process
            isEnabled = false
        } else {
            spinner.stopAnimating()
            titleLabel?.alpha = 1
            imageView?.alpha = 0
            isEnabled = true
        }
    }
}
