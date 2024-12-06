//
//  SettingsManager.swift
//  TechFizz
//
//  Created by Ramit Sharma on 28/11/24.
//

import SwiftUI

class SettingsManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var fontSize: Double {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }
    
    @Published var selectedRegion: String {
        didSet {
            UserDefaults.standard.set(selectedRegion, forKey: "selectedRegion")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.fontSize = UserDefaults.standard.double(forKey: "fontSize")
        self.selectedRegion = UserDefaults.standard.string(forKey: "selectedRegion") ?? "US"
    }
}
