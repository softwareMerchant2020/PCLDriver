//
//  TouchIDAuthentication.swift
//  PCLDriver
//
//  Created by Sangeetha Gengaram on 4/19/20.
//  Copyright © 2020 Sangeetha Gengaram. All rights reserved.
//

import Foundation
import LocalAuthentication
enum BiometricType {
  case none
  case touchID
  case faceID
}
class BiometricIDAuth {
    let context = LAContext()
    var loginReason = "Logging in with Touch ID"

    
    func canEvaluatePolicy() -> Bool {
        let biometricPolicy = UserDefaults.standard.bool(forKey: "allowBiometrics")

      return (context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && biometricPolicy)
    }
    func biometricType() -> BiometricType {
      let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
      switch context.biometryType {
      case .none:
        return .none
      case .touchID:
        return .touchID
      case .faceID:
        return .faceID
    
      @unknown default:
        return .none
        
        }
    }
    func authenticateUser(completion: @escaping (String?) -> Void) {
        
      guard canEvaluatePolicy() else {
        completion("Touch ID not available")
        return
      }
        
      context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
        localizedReason: loginReason) { (success, evaluateError) in
          if success {
            DispatchQueue.main.async {
              completion(nil)
            }
          } else {
                                  
            let message: String
                                  
            switch evaluateError {
            case LAError.authenticationFailed?:
              message = "There was a problem verifying your identity."
            case LAError.userCancel?:
              message = "You pressed cancel."
            case LAError.userFallback?:
              message = "You pressed password."
            case LAError.biometryNotAvailable?:
              message = "Face ID/Touch ID is not available."
            case LAError.biometryNotEnrolled?:
              message = "Face ID/Touch ID is not set up."
            case LAError.biometryLockout?:
              message = "Face ID/Touch ID is locked."
            default:
              message = "Face ID/Touch ID may not be configured"
            }
              
            completion(message)
          }
      }
    }
}

