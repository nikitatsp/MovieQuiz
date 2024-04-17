import UIKit

final class MovieQuizPresenter {
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService?
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
        
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
            viewController?.provideDataToAlert(viewModel: viewModel)
            
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
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
            if isCorrectAnswer {
                correctAnswers += 1
            }
        }
}
