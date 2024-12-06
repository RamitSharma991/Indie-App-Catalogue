class SettingsManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    @Published var selectedRegion: String {
        didSet {
            UserDefaults.standard.set(selectedRegion, forKey: "selectedRegion")
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.selectedRegion = UserDefaults.standard.string(forKey: "selectedRegion") ?? "US"
    }
} 