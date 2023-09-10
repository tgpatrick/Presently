//
//  String.swift
//  Presently
//
//  Created by Thomas Patrick on 8/24/23.
//

import SwiftUI

extension String {
    func getURLIfValid() -> URL? {
        if let url = URL(string: self), UIApplication.shared.canOpenURL(url) {
            return url
        } else {
            return nil
        }
    }
}
