//
//  PushupsView.swift
//  Peak-Fitness
//
//  Created by James Robinson on 22/07/2024.
//

import SwiftUI
import UIKit

struct PushupsView: View {
    @State private var pushupCount: Int = 0
    @State private var showingAlert = false
    @State private var alertMessage: String = ""
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Pushups")
                .font(.largeTitle)
                .padding()

            Text("\(pushupCount)")
                .font(.largeTitle)
                .padding()

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button(action: {
                        generateHapticFeedback()
                        updatePushupCount(change: "increase")
                    }) {
                        Text("+1")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.green)
                            .cornerRadius(15.0)
                    }

                    Button(action: {
                        generateHapticFeedback()
                        updatePushupCount(change: "increase10")
                    }) {
                        Text("+10")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.green)
                            .cornerRadius(15.0)
                    }
                }
                .frame(height: UIScreen.main.bounds.height / 4)
                .padding([.leading, .trailing], 20)

                HStack(spacing: 20) {
                    Button(action: {
                        generateHapticFeedback()
                        updatePushupCount(change: "decrease")
                    }) {
                        Text("-1")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.red)
                            .cornerRadius(15.0)
                    }

                    Button(action: {
                        generateHapticFeedback()
                        updatePushupCount(change: "decrease10")
                    }) {
                        Text("-10")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.red)
                            .cornerRadius(15.0)
                    }
                }
                .frame(height: UIScreen.main.bounds.height / 4)
                .padding([.leading, .trailing], 20)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            fetchPushupCount()
        }
        .padding()
    }

    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func updatePushupCount(change: String) {
        APIService.shared.updateExerciseCount(type: "pushups", change: change) { result in
            switch result {
            case .success(let count):
                self.pushupCount = count
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }

    private func fetchPushupCount() {
        APIService.shared.getExerciseCount(type: "pushups") { result in
            switch result {
            case .success(let count):
                self.pushupCount = count
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }
}
