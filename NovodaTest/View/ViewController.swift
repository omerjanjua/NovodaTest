//
//  ViewController.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import UIKit

class ViewController: UIViewController {

    private let service = UserService()
    private let imageService = ImageService()
    private var users: [User] = []
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableView.self))
        loadUsers()
    }
    
    private func loadUsers() {
        Task {
            do {
                let fetchedUsers = try await service.fetchUsers()
                // Update UI on the main thread
                await MainActor.run {
                    self.users = fetchedUsers
                    self.tableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    self.showErrorAlert(error)
                }
            }
        }
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: UITableView.self))
        let user = users[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = user.displayName
        content.secondaryText = String(user.reputation)
        content.image = UIImage(systemName: "person.circle")
        content.imageProperties.cornerRadius = 20
        content.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        content.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        cell.contentConfiguration = content
        
        Task {
            do {
                let image = try await imageService.fetchImage(from: user.profileImageURL)
                content.image = image
                cell.contentConfiguration = content
            } catch {
                await MainActor.run {
                    self.showErrorAlert(error)
                }
            }
        }
        
        return cell
    }
}

