import UIKit

class SearchViewController: UIViewController {
    
    private var searchResults: [StarWarsItem] = []
    private var recentSearches: [String] = []
    private var isSearching = false
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search all categories..."
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ItemCell.self, forCellReuseIdentifier: ItemCell.reuseIdentifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.keyboardDismissMode = .onDrag
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Search the Galaxy"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Find characters, planets, starships, and more..."
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        return view
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        loadRecentSearches()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Search"
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Hide empty cells
        tableView.tableFooterView = UIView()
    }
    
    private func setupSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
    // MARK: - Data Management
    
    private func loadRecentSearches() {
        // Load recent searches from UserDefaults
        if let searches = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
            recentSearches = searches
            updateEmptyState()
            tableView.reloadData()
        }
    }
    
    private func saveSearch(_ query: String) {
        // Add to recent searches if not already present
        if !recentSearches.contains(query) {
            recentSearches.insert(query, at: 0)
            // Keep only the last 5 searches
            if recentSearches.count > 5 {
                recentSearches = Array(recentSearches.prefix(5))
            }
            
            // Save to UserDefaults
            UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
        }
    }
    
    private func searchItems(query: String) {
        guard !query.isEmpty else {
            searchResults.removeAll()
            tableView.reloadData()
            return
        }
        
        NetworkManager.shared.searchItems(query: query) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    self.searchResults = items
                    self.updateEmptyState()
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print("Search error: \(error.localizedDescription)")
                    self.searchResults = []
                    self.updateEmptyState()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func updateEmptyState() {
        if isSearching {
            emptyStateView.isHidden = !searchResults.isEmpty
        } else {
            emptyStateView.isHidden = !recentSearches.isEmpty
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchResults.count
        } else {
            return section == 0 ? 1 : recentSearches.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ItemCell.reuseIdentifier,
                for: indexPath
            ) as? ItemCell else {
                return UITableViewCell()
            }
            
            let item = searchResults[indexPath.row]
            cell.configure(with: item)
            return cell
            
        } else if indexPath.section == 0 {
            // Surprise Me cell
            let cell = UITableViewCell(style: .default, reuseIdentifier: "SurpriseCell")
            cell.textLabel?.text = "🎲 Surprise Me!"
            cell.textLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell
            
        } else {
            // Recent search cell
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "RecentSearchCell")
            cell.textLabel?.text = recentSearches[indexPath.row]
            cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            cell.detailTextLabel?.text = "Tap to search again"
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.imageView?.image = UIImage(systemName: "clock.arrow.circlepath")
            cell.imageView?.tintColor = .systemYellow
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching {
            return searchResults.isEmpty ? nil : "Search Results"
        } else {
            return section == 1 && !recentSearches.isEmpty ? "Recent Searches" : nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSearching {
            let item = searchResults[indexPath.row]
            let detailVC = DetailViewController(item: item)
            navigationController?.pushViewController(detailVC, animated: true)
            
        } else if indexPath.section == 0 {
            // Surprise Me!
            fetchRandomItem()
            
        } else {
            // Recent search
            let query = recentSearches[indexPath.row]
            searchController.searchBar.text = query
            searchController.searchBar.becomeFirstResponder()
            searchItems(query: query)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !isSearching && indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && !isSearching && indexPath.section == 1 {
            recentSearches.remove(at: indexPath.row)
            UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
            
            if recentSearches.isEmpty {
                tableView.deleteSections(IndexSet(integer: 1), with: .automatic)
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            updateEmptyState()
        }
    }
}

// MARK: - UISearchResultsUpdating & UISearchBarDelegate

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        // This method is intentionally left empty
        // We'll handle search in searchBarSearchButtonClicked
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        isSearching = true
        saveSearch(query)
        searchItems(query: query)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchResults.removeAll()
        tableView.reloadData()
        updateEmptyState()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            searchResults.removeAll()
            tableView.reloadData()
            updateEmptyState()
        }
    }
}

// MARK: - Helper Methods

extension SearchViewController {
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func fetchRandomItem() {
        // SWAPI people endpoint has multiple pages; use a simple fixed range.
        let randomPage = Int.random(in: 1...9)
        NetworkManager.shared.fetchItems(type: .people, page: randomPage) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    guard let item = items.randomElement() else {
                        self.showAlert(title: "Surprise!", message: "No items available right now.")
                        return
                    }
                    let detailVC = DetailViewController(item: item)
                    self.navigationController?.pushViewController(detailVC, animated: true)
                case .failure(let error):
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
}
