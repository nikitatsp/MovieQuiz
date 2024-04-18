import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    private var presenter: MovieQuizPresenter!
    var alertPresenter: AlertPresenterProtocol?
    
    @IBOutlet var imageView: UIImageView!
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
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(delegate: self)
        
        showLoadingIndicator()
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
        activityIndicator.isHidden = false 
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    
    func show(quiz step: QuizStepViewModel) {
      imageView.image = step.image
      textLabel.text = step.question
      counterLabel.text = step.questionNumber
    }
    
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    

    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
}
