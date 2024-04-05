import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func enableYesButton() {
        yesButton.isEnabled = true
    }
    
    func disableYesButton() {
        yesButton.isEnabled = false
    }
    
    func enableNoButton() {
        noButton.isEnabled = true
    }
    
    func disableNoButton() {
        noButton.isEnabled = false
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.enableYesButton()
            self?.enableNoButton()
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func showAlert(alert: UIAlertController) {
        self.present(alert, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func showLoadingIndicator() {
        disableYesButton()
        disableNoButton()
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let viewModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз", closure: { [weak self] in
            
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.noButton.isEnabled = true
            self?.yesButton.isEnabled = true
            self?.imageView.layer.borderColor = UIColor.clear.cgColor
            self?.questionFactory?.loadData()
        })
        alertPresenter?.show(quiz: viewModel)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
      imageView.image = step.image
      textLabel.text = step.question
      counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            guard let totalAccuracy = statisticService?.totalAccuracy else {
                return
            }
            guard let gamesCount = statisticService?.gamesCount else {
                return
            }
            guard let bestGame = statisticService?.bestGame else {
                return
            }
            let recordString = "\(bestGame.correct)/\(bestGame.total) (\(bestGame.dateFormatter()))"
            
            let message = "Ваш результат: \(correctAnswers)/10 \nКоличество сыгранных квизов: \(gamesCount) \nРекорд: \(recordString) \nСредняя точность: \(NSString(format:"%.2f", totalAccuracy))%"
            let viewModel = AlertModel(title: "Раунд окончен", message: message, buttonText: "Начать еще раз", closure: { [weak self] in
                
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.noButton.isEnabled = true
                self?.yesButton.isEnabled = true
                self?.imageView.layer.borderColor = UIColor.clear.cgColor
                self?.questionFactory?.requestNextQuestion()
            })
            alertPresenter?.show(quiz: viewModel)
            
        } else {
            self.imageView.layer.borderColor = UIColor.clear.cgColor
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect {
            correctAnswers += 1
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
            }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    

    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}

