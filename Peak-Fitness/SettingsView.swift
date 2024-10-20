//
//  SettingsView.swift
//  Peak-Fitness
//
//  Created by James Robinson on 22/07/2024.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SettingsView: View {
    @State private var newUsername: String = ""
    @State private var newPassword: String = ""
    @State private var showingAlert = false
    @State private var alertMessage: String = ""
    @State private var showingDeleteConfirmation = false
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 20) {
                TextField("New Username", text: $newUsername)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(5.0)
                
                SecureField("New Password", text: $newPassword)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(5.0)
                
                Button(action: {
                    UIApplication.shared.endEditing()
                    APIService.shared.updateSettings(newUsername: newUsername.isEmpty ? nil : newUsername, newPassword: newPassword.isEmpty ? nil : newPassword, deleteAccount: false) { result in
                        switch result {
                        case .success(let message):
                            self.alertMessage = message
                            self.showingAlert = true
                        case .failure(let error):
                            self.alertMessage = error.localizedDescription
                            self.showingAlert = true
                        }
                    }
                }) {
                    Text("Update Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10.0)
            .shadow(radius: 10.0)
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 20) {
                Button(action: {
                    APIService.shared.logout { result in
                        switch result {
                        case .success:
                            self.navigationManager.navigate(to: .login)
                        case .failure(let error):
                            self.alertMessage = error.localizedDescription
                            self.showingAlert = true
                        }
                    }
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Button(action: {
                    self.showingDeleteConfirmation = true
                }) {
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Settings"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $showingDeleteConfirmation) {
                    Alert(title: Text("Delete Account"), message: Text("Are you sure you want to delete your account? This action cannot be undone."), primaryButton: .destructive(Text("Delete")) {
                        APIService.shared.updateSettings(newUsername: nil, newPassword: nil, deleteAccount: true) { result in
                            switch result {
                            case .success(let message):
                                self.alertMessage = message
                                self.showingAlert = true
                                self.navigationManager.navigate(to: .login)
                            case .failure(let error):
                                self.alertMessage = error.localizedDescription
                                self.showingAlert = true
                            }
                        }
                    }, secondaryButton: .cancel())
                }
            }
            
            Spacer()
        }
        .padding(.top, 50) // Adjust this value as needed to bring everything slightly lower
        .navigationBarTitle("Settings", displayMode: .inline)
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
    }
}
