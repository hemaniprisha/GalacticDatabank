import UIKit

struct QuizQuestion {
    let text: String
    let answers: [QuizAnswer]
}

struct QuizAnswer {
    let text: String
    /// Simple scoring towards an archetype
    let characterKey: String
}

class QuizViewController: UIViewController {
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            text: "What role do you naturally take in a group?",
            answers: [
                QuizAnswer(text: "Leader with a moral compass", characterKey: "luke"),
                QuizAnswer(text: "Strategic diplomat", characterKey: "leia"),
                QuizAnswer(text: "Charming rogue", characterKey: "han"),
                QuizAnswer(text: "Calculated enforcer", characterKey: "vader")
            ]
        ),
        QuizQuestion(
            text: "How do you approach risk?",
            answers: [
                QuizAnswer(text: "I trust in hope and take the leap", characterKey: "luke"),
                QuizAnswer(text: "I weigh every angle first", characterKey: "leia"),
                QuizAnswer(text: "Never tell me the odds", characterKey: "han"),
                QuizAnswer(text: "Risk is a tool to gain power", characterKey: "vader")
            ]
        ),
        QuizQuestion(
            text: "Pick a preferred weapon:",
            answers: [
                QuizAnswer(text: "Blue lightsaber", characterKey: "luke"),
                QuizAnswer(text: "Sharp mind and sharp words", characterKey: "leia"),
                QuizAnswer(text: "Blaster at my side", characterKey: "han"),
                QuizAnswer(text: "Red lightsaber", characterKey: "vader")
            ]
        )
    ]
    
    private var currentIndex: Int = 0
    private var scores: [String: Int] = [:]
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .systemYellow
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Character Quiz"
        setupLayout()
        showCurrentQuestion()
    }
    
    private func setupLayout() {
        view.addSubview(questionLabel)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func showCurrentQuestion() {
        guard currentIndex < questions.count else {
            showResult()
            return
        }
        let question = questions[currentIndex]
        questionLabel.text = question.text
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for answer in question.answers {
            let button = UIButton(type: .system)
            var config = UIButton.Configuration.filled()
            config.title = answer.text
            config.baseBackgroundColor = .darkGray
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            button.configuration = config
            button.addAction(UIAction { [weak self] _ in
                self?.select(answer: answer)
            }, for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    private func select(answer: QuizAnswer) {
        scores[answer.characterKey, default: 0] += 1
        currentIndex += 1
        showCurrentQuestion()
    }
    
    private func showResult() {
        let best = scores.max { $0.value < $1.value }?.key ?? "luke"
        let message: String
        switch best {
        case "luke":
            message = "You are most like Luke Skywalker: hopeful, principled, and drawn to adventure."
        case "leia":
            message = "You are most like Leia Organa: strategic, brave, and an inspiring leader."
        case "han":
            message = "You are most like Han Solo: witty, independent, but loyal when it counts."
        case "vader":
            message = "You are most like Darth Vader: powerful, driven, and wrestling with destiny."
        default:
            message = "The Force is strong with you, in your own unique way."
        }
        
        let alert = UIAlertController(title: "Your Star Wars Match", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
