//
//  APIService.swift
//  Peak-Fitness
//
//  Created by James Robinson on 21/07/2024.
//

import Foundation
import KeychainAccess

class APIService {
    static let shared = APIService()
    let baseURL = "https://www.peak-fitness.live/api"
    
    private let keychain = Keychain(service: "com.yourapp.peakfitness")

    // Login Method
    func login(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([String: String].self, from: data) {
                    if response["status"] == "success" {
                        self.saveCredentials(username: username, password: password)
                        completion(.success(response["message"] ?? "Logged in successfully"))
                    } else {
                        completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: response["message"] ?? "Invalid credentials"])))
                    }
                }
            }
        }.resume()
    }

    // Save Credentials
    private func saveCredentials(username: String, password: String) {
        keychain["username"] = username
        keychain["password"] = password
    }

    // Retrieve Credentials
    func retrieveCredentials() -> (username: String, password: String)? {
        if let username = keychain["username"], let password = keychain["password"] {
            return (username, password)
        }
        return nil
    }

    // Register Method
    func register(username: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/register") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([String: String].self, from: data) {
                    if response["status"] == "success" {
                        // Automatically log in the user after successful registration
                        self.login(username: username, password: password, completion: completion)
                    } else {
                        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: response["message"] ?? "Registration failed"])))
                    }
                }
            }
        }.resume()
    }

    // Get Leaderboards Method
    func getLeaderboards(completion: @escaping (Result<[User], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/leaderboards") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([User].self, from: data) {
                    completion(.success(response))
                } else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch leaderboard"])))
                }
            }
        }.resume()
    }

    // Update Settings Method
    func updateSettings(newUsername: String?, newPassword: String?, deleteAccount: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/settings") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        var body: [String: Any] = [:]
        if let newUsername = newUsername {
            body["new_username"] = newUsername
        }
        if let newPassword = newPassword {
            body["new_password"] = newPassword
        }
        body["delete_account"] = deleteAccount

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([String: String].self, from: data) {
                    if response["status"] == "success" {
                        completion(.success(response["message"] ?? "Settings updated successfully"))
                    } else {
                        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: response["message"] ?? "Failed to update settings"])))
                    }
                }
            }
        }.resume()
    }

    // Logout Method
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/logout") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([String: String].self, from: data) {
                    if response["status"] == "success" {
                        self.clearCredentials()
                        completion(.success(response["message"] ?? "Logged out successfully"))
                    } else {
                        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: response["message"] ?? "Failed to log out"])))
                    }
                }
            }
        }.resume()
    }

    // Clear Credentials
    private func clearCredentials() {
        keychain["username"] = nil
        keychain["password"] = nil
    }

    // Update Exercise Count Method
    func updateExerciseCount(type: String, change: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(type)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = ["change": change]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([String: Int].self, from: data) {
                    if let count = response["count"] {
                        completion(.success(count))
                    } else {
                        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to update count"])))
                    }
                }
            }
        }.resume()
    }

    // Get Exercise Count Method
    func getExerciseCount(type: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(type)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([String: Int].self, from: data) {
                    if let count = response["count"] {
                        completion(.success(count))
                    } else {
                        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch count"])))
                    }
                }
            }
        }.resume()
    }
    
    // Add Custom Exercise Method
    func addCustomExercise(name: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/exercises") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let body = ["exercise_name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([String: String].self, from: data) {
                    if response["status"] == "success" {
                        completion(.success(response["message"] ?? "Exercise added successfully"))
                    } else {
                        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: response["message"] ?? "Failed to add exercise"])))
                    }
                }
            }
        }.resume()
    }

    // Update Custom Exercise Method
    func updateCustomExercise(exerciseID: Int, change: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/exercises") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"

        let body = ["exercise_id": exerciseID, "change": change] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([String: Int].self, from: data) {
                    if let count = response["count"] {
                        completion(.success(count))
                    } else {
                        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to update count"])))
                    }
                }
            }
        }.resume()
    }

    // Delete Custom Exercise Method
    func deleteCustomExercise(exerciseID: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/exercises") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let body = ["exercise_id": exerciseID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([String: String].self, from: data) {
                    if response["status"] == "success" {
                        completion(.success(response["message"] ?? "Exercise deleted successfully"))
                    } else {
                        completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: response["message"] ?? "Failed to delete exercise"])))
                    }
                }
            }
        }.resume()
    }

    // Get Custom Exercises Method
    func getCustomExercises(completion: @escaping (Result<[Exercise], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/exercises") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let response = try? JSONDecoder().decode([Exercise].self, from: data) {
                    completion(.success(response))
                } else {
                    completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch exercises"])))
                }
            }
        }.resume()
    }
}

// User model
struct User: Codable, Identifiable {
    var id: String { username } // Assuming username is unique
    let username: String
    let pushups: Int
    let pullups: Int
    let points: Int
}

struct Exercise: Codable, Identifiable {
    var id: Int
    var name: String
    var count: Int
}
