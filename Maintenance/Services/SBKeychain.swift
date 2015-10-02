//
//  SBKeychain.swift
//  Maintenance
//
//  Created by Jelle Vandenbeeck on 29/09/15.
//  Copyright © 2015 Soaring Book. All rights reserved.
//

import Foundation
import SSKeychain

class SBKeychain: NSObject {
    
    private let SBTokenService = "token.service"
    private let SBAccountName = "com.soaringbook.maintenance"
    
    // MARK: - Getter
    
    var token: String? {
        get {
            return SSKeychain.passwordForService(SBTokenService, account: SBAccountName)
        }
        set {
            if let newValue = newValue {
                SSKeychain.setPassword(newValue, forService: SBTokenService, account: SBAccountName)
            } else {
                SSKeychain.deletePasswordForService(SBTokenService, account: SBAccountName)
            }
        }
    }
    
    // MARK: - Initialization
    
    class var sharedInstance: SBKeychain {
        struct StaticSBKeychain {
            static let instance : SBKeychain = SBKeychain()
        }
        return StaticSBKeychain.instance
    }
}