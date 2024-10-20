//
//  CustomExercisesView.swift
//  Peak-Fitness
//
//  Created by James Robinson on 22/07/2024.
//

import SwiftUI

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CustomExercisesView: View {
    @State private var customExercises: [Exercise] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var newExerciseName = ""
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 20) // Add padding at the top

                Text("Custom Exercises")
                    .font(.largeTitle)
                    .padding()

                TextField("New Exercise Name", text: $newExerciseName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding([.leading, .trailing], 20)

                Button(action: {
                    addNewExercise()
                    UIApplication.shared.dismissKeyboard() // Dismiss the keyboard
                }) {
                    Text("Add Exercise")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
                .padding([.leading, .trailing], 20)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }

                List {
                    ForEach(customExercises) { exercise in
                        NavigationLink(destination: CustomExerciseDetailView(exerciseViewModel: ExerciseViewModel(exercise: exercise))
                                        .environmentObject(navigationManager)) {
                            HStack {
                                Text(exercise.name)
                                Spacer()
                                Text("\(exercise.count)")
                            }
                        }
                    }
                    .onDelete(perform: deleteExercise)
                }
                .listStyle(InsetGroupedListStyle())
            }
            .onAppear {
                fetchCustomExercises()
            }
        }
    }

    private func fetchCustomExercises() {
        APIService.shared.getCustomExercises { result in
            switch result {
            case .success(let exercises):
                self.customExercises = exercises
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }

    private func addNewExercise() {
        APIService.shared.addCustomExercise(name: newExerciseName) { result in
            switch result {
            case .success:
                self.fetchCustomExercises()
                self.newExerciseName = ""
            case .failure(let error):
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }

    private func deleteExercise(at offsets: IndexSet) {
        offsets.forEach { index in
            let exercise = customExercises[index]
            APIService.shared.deleteCustomExercise(exerciseID: exercise.id) { result in
                switch result {
                case .success:
                    self.customExercises.remove(at: index)
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                    self.showingAlert = true
                }
            }
        }
    }
}
