import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewControllerProtocol?
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
            self.viewController = viewController
            statisticService = StatisticServiceImplementation()
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            viewController.showLoadingIndicator()
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadImage(movie: MostPopularMovie) {
        let viewModel = AlertModel(title: "Ошибка", message: "Не удалось загрузить изображение", buttonText: "Попробовать еще раз", accessibilityIdentifier: "FailedLoadImageAlert", closure: { [weak self] in
            self?.viewController?.disableNoButton()
            self?.viewController?.disableYesButton()
            
            DispatchQueue.global().async { [weak self] in
                guard let tryImage = self?.questionFactory?.generateImage(movie: movie) else {return}
                
                
                DispatchQueue.main.async { [weak self] in
                    self?.viewController?.imageView.image = UIImage(data: tryImage) ?? UIImage()
                    self?.viewController?.enableYesButton()
                    self?.viewController?.enableYesButton()
                }
            }
        })
        viewController?.alertPresenter?.show(quiz: viewModel)
    }
    
    func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        
        let viewModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз", accessibilityIdentifier: "ShowNetworkErrorAlert", closure: { [weak self] in
            
            self?.restartGame()
            self?.correctAnswers = 0
            self?.viewController?.enableNoButton()
            self?.viewController?.enableYesButton()
            self?.viewController?.hideBorder()
            self?.questionFactory?.loadData()
        })
            viewController?.alertPresenter?.show(quiz: viewModel)
    }
    
    
        
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
    }
        
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
        
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.showImageView()
            self?.viewController?.showYesButton()
            self?.viewController?.showNoButton()
            self?.viewController?.enableYesButton()
            self?.viewController?.enableNoButton()
            self?.viewController?.showTextLabel()
            
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.disableNoButton()
        viewController?.disableYesButton()
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            
            self?.showNextQuestionOrResults()
            }
    }
    
    func showNextQuestionOrResults() {
        if isLastQuestion() {
            
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
            let viewModel = AlertModel(title: "Раунд окончен", message: message, buttonText: "Начать еще раз", accessibilityIdentifier: "GameResults", closure: { [weak self] in
                
                self?.restartGame()
                self?.correctAnswers = 0
                self?.viewController?.hideBorder()
                self?.questionFactory?.requestNextQuestion()
            })
            viewController?.alertPresenter?.show(quiz: viewModel)
            
        } else {
            self.viewController?.hideBorder()
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
            if isCorrectAnswer {
                correctAnswers += 1
            }
        }
}
