//
//  AppUtility.swift
//  ConnectDemo
//
//  Created by Ray Whaley on 8/14/23.
//

import UIKit
import os

struct AppUtility {
    // fetch value by key from environment config file
    static func getConfigValue(forKey key: String) -> String? {
        guard let dict = Bundle.main.infoDictionary else {
          fatalError("Plist file not found")
        }
        guard let rootURLstring = dict[key] as? String else {
              fatalError("Root URL not set in plist for this environment")
        }
        if rootURLstring.isEmpty {
            os_log("Warning: unset value for %@", log: .default, type: .info, key)
        }
        return rootURLstring
    }
}
