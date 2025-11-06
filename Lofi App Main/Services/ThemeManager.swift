//
//  ThemeManager.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @AppStorage("isDarkMode") var isDarkMode: Bool = true {
        didSet {
            objectWillChange.send()
        }
    }

    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    private init() {}

    func toggleTheme() {
        isDarkMode.toggle()
    }

    func setTheme(isDark: Bool) {
        isDarkMode = isDark
    }
}
