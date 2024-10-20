//
//  PullupsView.swift
//  Peak-Fitness
//
//  Created by James Robinson on 22/07/2024.
//

import SwiftUI
import UIKit

struct PullupsView: View {
    @State private var pullupCount: Int = 0
    @State private var showingAlert = false
    @State private var alertMessage: String = ""
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Pullups")
                .font(.largeTitle)
                .padding()

            Text("\(pullupCount)")
                .font(.largeTitle)
                .padding()

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button(action: {
                        generateHapticFeedback()
                        updatePullupCount(change: "increase")
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
                        updatePullupCount(change: "increase10")
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
                        updatePullupCount(change: "decrease")
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
                        updatePullupCount(change: "decrease10")
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
            fetchPullupCount()
        }
        .padding()
    }

    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func updatePullupCount(change: String) {
        APIService.shared.updateExerciseCount(type: "pullups", change: change) { result in
            switch result {
            case .success(let count):
                self.pullupCount = count
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }

    private func fetchPullupCount() {
        APIService.shared.getExerciseCount(type: "pullups") { result in
            switch result {
            case .success(let count):
                self.pullupCount = count
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }
}
