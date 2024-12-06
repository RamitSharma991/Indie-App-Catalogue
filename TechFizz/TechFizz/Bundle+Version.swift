//
//  Bundle+Version.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//


import Foundation

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
