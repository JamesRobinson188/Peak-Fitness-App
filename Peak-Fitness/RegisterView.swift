//
//  RegisterView.swift
//  Peak-Fitness
//
//  Created by James Robinson on 21/07/2024.
//

import SwiftUI

struct RegisterView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var message: String = ""
    @State private var showingAlert = false
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            Button(action: {
                guard validateFields() else { return }

                APIService.shared.register(username: username, password: password) { result in
                    switch result {
                    case .success(let message):
                        DispatchQueue.main.async {
                            self.message = message
                            self.navigationManager.navigate(to: .tabView)
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.message = error.localizedDescription
                            self.showingAlert = true
                        }
                    }
                }
            }) {
                Text("Register")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15.0)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Registration Status"), message: Text(message), dismissButton: .default(Text("OK")))
            }

            Button(action: {
                self.navigationManager.navigate(to: .login)
            }) {
                Text("Already have an account? Login")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 20)
            }
        }
        .padding()
    }

    private func validateFields() -> Bool {
        if username.count < 2 {
            self.message = "Username must be at least 2 characters long"
            self.showingAlert = true
            return false
        }

        if password.count < 8 {
            self.message = "Password must be at least 8 characters long"
            self.showingAlert = true
            return false
        }

        if !password.contains(where: { $0.isUppercase }) {
            self.message = "Password must contain at least one uppercase letter"
            self.showingAlert = true
            return false
        }

        if !password.contains(where: { $0.isLowercase }) {
            self.message = "Password must contain at least one lowercase letter"
            self.showingAlert = true
            return false
        }

        if !password.contains(where: { $0.isNumber }) {
            self.message = "Password must contain at least one number"
            self.showingAlert = true
            return false
        }

        if password != confirmPassword {
            self.message = "Passwords do not match"
            self.showingAlert = true
            return false
        }

        return true
    }
}
