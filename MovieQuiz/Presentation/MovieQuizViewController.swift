import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    private var correctAnswers = 0
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        hideImageView()
        hideNoButton()
        hideYesButton()
        hideTextLabel()
        
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        presenter.viewController = self
        
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func hideBorder() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func hideTextLabel() {
        textLabel.alpha = 0.0
    }
    
    func showTextLabel() {
        textLabel.alpha = 1.0
    }
    
    func hideImageView() {
        imageView.alpha = 0.0
    }
    
    func showImageView() {
        imageView.alpha = 1.0
    }
    
    func hideYesButton() {
        yesButton.alpha = 0.0
    }
    
    func hideNoButton() {
        noButton.alpha = 0.0
    }
    
    func showYesButton() {
        yesButton.alpha = 1.0
    }
    
    func showNoButton() {
        noButton.alpha = 1.0
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
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didFailToLoadImage(movie: MostPopularMovie) {
        let viewModel = AlertModel(title: "Ошибка", message: "Не удалось загрузить изображение", buttonText: "Попробовать еще раз", accessibilityIdentifier: "FailedLoadImageAlert", closure: { [weak self] in
            self?.disableNoButton()
            self?.disableYesButton()
            
            DispatchQueue.global().async { [weak self] in
                guard let tryImage = self?.questionFactory?.generateImage(movie: movie) else {return}
                
                
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = UIImage(data: tryImage) ?? UIImage()
                    self?.enableYesButton()
                    self?.enableYesButton()
                }
            }
        })
        alertPresenter?.show(quiz: viewModel)
    }
    
    func showAlert(alert: UIAlertController) {
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showLoadingIndicator() {
        disableYesButton()
        disableNoButton()
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let viewModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз", accessibilityIdentifier: "ShowNetworkErrorAlert", closure: { [weak self] in
            
            self?.presenter.resetQuestionIndex()
            self?.correctAnswers = 0
            self?.noButton.isEnabled = true
            self?.yesButton.isEnabled = true
            self?.imageView.layer.borderColor = UIColor.clear.cgColor
            self?.questionFactory?.loadData()
        })
        alertPresenter?.show(quiz: viewModel)
    }
    
    func show(quiz step: QuizStepViewModel) {
      imageView.image = step.image
      textLabel.text = step.question
      counterLabel.text = step.questionNumber
    }
    
    func provideDataToAlert(viewModel: AlertModel) {
        alertPresenter?.show(quiz: viewModel)
    }
    
    
    func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect {
            correctAnswers += 1
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.statisticService = self.statisticService
            self.presenter.showNextQuestionOrResults()
            }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
}
