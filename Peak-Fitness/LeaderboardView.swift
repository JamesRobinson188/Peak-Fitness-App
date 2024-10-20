//
//  LeaderboardView.swift
//  Peak-Fitness
//
//  Created by James Robinson on 21/07/2024.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var users: [User] = []
    @State private var errorMessage: String?
    @State private var showingAlert = false
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        VStack {
            Spacer()
                .frame(height: 20) // Add padding at the top

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            ScrollView {
                ForEach(users) { user in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.username)
                            .font(.headline)
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("\(user.points) Points")
                        }
                        .font(.subheadline)
                        HStack {
                            Text("\(user.pushups) Pushups")
                            Spacer()
                            Text("\(user.pullups) Pullups")
                        }
                        .font(.subheadline)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
            }
            .refreshable {
                loadLeaderboards()
            }
            .onAppear {
                loadLeaderboards()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
        .navigationBarTitle("Leaderboard")
        .navigationBarHidden(true) // Ensure the navigation bar is hidden
    }

    private func loadLeaderboards() {
        APIService.shared.getLeaderboards { result in
            switch result {
            case .success(let users):
                self.users = users
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showingAlert = true
            }
        }
    }
}
