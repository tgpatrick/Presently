//
//  String.swift
//  Presently
//
//  Created by Thomas Patrick on 8/24/23.
//

import SwiftUI

extension String {
    func isValidURL() -> Bool {
        if let url = URL(string: self), url.host != nil {
          return true
        }
        return false
    }
    
    func getURLIfValid() -> URL? {
        if let url = URL(string: self), url.host != nil {
            return url
        } else {
            return nil
        }
    }
}
