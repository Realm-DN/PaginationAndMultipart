//
//  String+Extension.swift
//  XITechMT
//
//  Created by Dev Rana on 17/10/24.
//

import UIKit

extension String {
    
    func isFieldEmpty() -> Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    func isPhoneNumberValid() -> Bool {
        let phoneRegex = "^[0-9]{6,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    func isValidEmail() -> Bool {
        let finalEmail = self.trimmingCharacters(in: .whitespaces)
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: finalEmail)
    }
}
