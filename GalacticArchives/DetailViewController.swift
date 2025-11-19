import UIKit

class DetailViewController: UIViewController {
    
    private let item: StarWarsItem
    private var isFavorite = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let shareButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Share This Entry"
        config.baseBackgroundColor = .systemYellow
        config.baseForegroundColor = .black
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    
    init(item: StarWarsItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure(with: item)
        loadFavoriteState()
        setupNavigationBar()
        setupButtonActions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(infoStackView)
        contentView.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalTo: headerImageView.widthAnchor, multiplier: 0.6),
            
            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            infoStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            infoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            shareButton.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 32),
            shareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: isFavorite ? "star.fill" : "star"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
        favoriteButton.tintColor = isFavorite ? .systemYellow : .systemGray
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    private func setupButtonActions() {
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    private func configure(with item: StarWarsItem) {
        titleLabel.text = item.name
        descriptionLabel.text = item.description
        
        // Set header image
        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.headerImageView.image = image
                    }
                } else {
                    self?.setPlaceholderImage()
                }
            }.resume()
        } else {
            setPlaceholderImage()
        }
        
        // Add info sections
        for (key, value) in item.additionalInfo {
            addInfoSection(title: key, content: value)
        }
    }
    
    private func setPlaceholderImage() {
        DispatchQueue.main.async { [weak self] in
            let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
            self?.headerImageView.image = UIImage(systemName: self?.item.type.iconName ?? "questionmark", withConfiguration: config)
            self?.headerImageView.contentMode = .scaleAspectFit
            self?.headerImageView.tintColor = .systemGray3
        }
    }
    
    private func addInfoSection(title: String, content: String) {
        let titleLabel = UILabel()
        titleLabel.text = title.uppercased()
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = .systemYellow
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = .systemFont(ofSize: 16, weight: .regular)
        contentLabel.textColor = .label
        contentLabel.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        infoStackView.addArrangedSubview(stackView)
    }
    
    // MARK: - Actions
    
    private func loadFavoriteState() {
        if let data = UserDefaults.standard.data(forKey: "favorites"),
           let decoded = try? JSONDecoder().decode([StarWarsItem].self, from: data) {
            isFavorite = decoded.contains { $0.url == item.url }
        } else {
            isFavorite = false
        }
    }

    @objc private func toggleFavorite() {
        if let data = UserDefaults.standard.data(forKey: "favorites"),
           var decoded = try? JSONDecoder().decode([StarWarsItem].self, from: data) {
            if let index = decoded.firstIndex(where: { $0.url == item.url }) {
                decoded.remove(at: index)
                isFavorite = false
            } else {
                decoded.append(item)
                isFavorite = true
            }
            if let encoded = try? JSONEncoder().encode(decoded) {
                UserDefaults.standard.set(encoded, forKey: "favorites")
            }
        } else {
            let newFavorites = [item]
            if let encoded = try? JSONEncoder().encode(newFavorites) {
                UserDefaults.standard.set(encoded, forKey: "favorites")
            }
            isFavorite = true
        }
        
        // Update button appearance
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: isFavorite ? "star.fill" : "star")
        navigationItem.rightBarButtonItem?.tintColor = isFavorite ? .systemYellow : .systemGray
        
        // Show feedback
        let message = isFavorite ? "Added to Favorites" : "Removed from Favorites"
        showToast(message: message)
    }
    
    @objc private func shareButtonTapped() {
        let text = "Check out \(item.name) in the Galactic Databank!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    private func showToast(message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            toastLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            toastLabel.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: [], animations: {
                toastLabel.alpha = 0.0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}
