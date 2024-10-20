//
//  NavigationManager.swift
//  Peak-Fitness
//
//  Created by James Robinson on 21/07/2024.
//

import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    @Published var currentScreen: Screen = .login

    enum Screen {
        case login
        case register
        case tabView
    }

    func navigate(to screen: Screen) {
        DispatchQueue.main.async {
            self.currentScreen = screen
        }
    }
}
