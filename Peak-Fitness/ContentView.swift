//
//  ContentView.swift
//  Peak-Fitness
//
//  Created by James Robinson on 21/07/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var navigationManager = NavigationManager()
    @State private var isAttemptingAutoLogin = true

    var body: some View {
        Group {
            if isAttemptingAutoLogin {
                ProgressView("Loading...")
            } else {
                if navigationManager.currentScreen == .login || navigationManager.currentScreen == .register {
                    NavigationView {
                        switch navigationManager.currentScreen {
                        case .login:
                            LoginView()
                                .environmentObject(navigationManager)
                        case .register:
                            RegisterView()
                                .environmentObject(navigationManager)
                        default:
                            EmptyView()
                        }
                    }
                } else {
                    NavigationView {
                        TabView {
                            LeaderboardView()
                                .tabItem {
                                    Image(systemName: "house.fill")
                                    Text("Home")
                                }
                                .environmentObject(navigationManager)

                            PullupsView()
                                .tabItem {
                                    Image(systemName: "flame.fill")
                                    Text("Pull-ups")
                                }

                            PushupsView()
                                .tabItem {
                                    Image(systemName: "bolt.fill")
                                    Text("Pushups")
                                }

                            CustomExercisesView()
                                .tabItem {
                                    Image(systemName: "figure.walk")
                                    Text("Custom Exercises")
                                }
                                .environmentObject(navigationManager)

                            SettingsView()
                                .tabItem {
                                    Image(systemName: "gearshape.fill")
                                    Text("Settings")
                                }
                                .environmentObject(navigationManager)
                        }
                    }
                }
            }
        }
        .onAppear {
            attemptAutoLogin()
        }
    }

    private func attemptAutoLogin() {
        if let credentials = APIService.shared.retrieveCredentials() {
            APIService.shared.login(username: credentials.username, password: credentials.password) { result in
                DispatchQueue.main.async {
                    isAttemptingAutoLogin = false
                    switch result {
                    case .success:
                        navigationManager.navigate(to: .tabView)
                    case .failure(let error):
                        print("Auto-login failed: \(error.localizedDescription)")
                        navigationManager.navigate(to: .login)
                    }
                }
            }
        } else {
            isAttemptingAutoLogin = false
            navigationManager.navigate(to: .login)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
