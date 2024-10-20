//
//  CustomExerciseDetailView.swift
//  Peak-Fitness
//
//  Created by James Robinson on 22/07/2024.
//

import SwiftUI

class ExerciseViewModel: ObservableObject {
    @Published var exercise: Exercise

    init(exercise: Exercise) {
        self.exercise = exercise
    }
}

struct CustomExerciseDetailView: View {
    @StateObject var exerciseViewModel: ExerciseViewModel
    @State private var showingAlert = false
    @State private var alertMessage: String = ""
    @EnvironmentObject var navigationManager: NavigationManager
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Text(exerciseViewModel.exercise.name)
                .font(.largeTitle)
                .padding()

            Text("\(exerciseViewModel.exercise.count)")
                .font(.largeTitle)
                .padding()

            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    Button(action: {
                        generateHapticFeedback()
                        updateExerciseCountLocally(change: "increase")
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
                        updateExerciseCountLocally(change: "increase10")
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
                        updateExerciseCountLocally(change: "decrease")
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
                        updateExerciseCountLocally(change: "decrease10")
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
            fetchExerciseCount()
        }
        .onReceive(timer) { _ in
            fetchExerciseCount()
        }
        .padding()
    }

    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private func updateExerciseCountLocally(change: String) {
        // Update locally first
        switch change {
        case "increase":
            exerciseViewModel.exercise.count += 1
        case "increase10":
            exerciseViewModel.exercise.count += 10
        case "decrease":
            exerciseViewModel.exercise.count -= 1
        case "decrease10":
            exerciseViewModel.exercise.count -= 10
        default:
            break
        }

        // Then make the network request
        updateExerciseCount(change: change)
    }

    private func updateExerciseCount(change: String) {
        APIService.shared.updateCustomExercise(exerciseID: exerciseViewModel.exercise.id, change: change) { result in
            switch result {
            case .success(let count):
                self.exerciseViewModel.exercise.count = count
            case .failure(let error):
                // Revert the local change if the update fails
                switch change {
                case "increase":
                    self.exerciseViewModel.exercise.count -= 1
                case "increase10":
                    self.exerciseViewModel.exercise.count -= 10
                case "decrease":
                    self.exerciseViewModel.exercise.count += 1
                case "decrease10":
                    self.exerciseViewModel.exercise.count += 10
                default:
                    break
                }
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }

    private func fetchExerciseCount() {
        APIService.shared.getCustomExercises { result in
            switch result {
            case .success(let exercises):
                if let updatedExercise = exercises.first(where: { $0.id == self.exerciseViewModel.exercise.id }) {
                    self.exerciseViewModel.exercise = updatedExercise
                }
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }
}
