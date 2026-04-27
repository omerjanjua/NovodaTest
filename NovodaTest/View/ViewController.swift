//
//  ViewController.swift
//  NovodaTest
//
//  Created by Omer Janjua on 26/04/2026.
//

import UIKit

class ViewController: UIViewController {

    private let viewModel = UsersViewModel()

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableView.self))
        loadUsers()
    }
    
    private func loadUsers() {
        Task {
            do {
                try await viewModel.fetchUsers()
                // Update UI on the main thread
                await MainActor.run {
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

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfUsers()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: String(describing: UITableView.self))
        let user = viewModel.users[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = user.displayName
        content.secondaryText = String(user.reputation)
        content.image = UIImage(systemName: "person.circle")
        content.imageProperties.cornerRadius = 20
        content.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        content.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        cell.contentConfiguration = content
        
        let isFollowed = viewModel.isFollowing(userAt: indexPath.row)
        cell.accessoryType = isFollowed ? .checkmark : .none
        
        Task {
            do {
                let image = try await viewModel.fetchImage(for: user)
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        viewModel.toggleFollow(at: indexPath.row)
        
        /* Update only the accessory of the visible cell
         instead of calling tableView.reloadData()
         */
        if let cell = tableView.cellForRow(at: indexPath) {
            let isNowFollowed = viewModel.isFollowing(userAt: indexPath.row)
            cell.accessoryType = isNowFollowed ? .checkmark : .none
        }
    }
}
