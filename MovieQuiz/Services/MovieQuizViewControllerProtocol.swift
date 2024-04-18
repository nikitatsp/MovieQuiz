import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    var imageView: UIImageView! {get set}
    
    var alertPresenter: AlertPresenterProtocol? {get set}
    
    func hideBorder()
    
    func hideTextLabel()
    
    func showTextLabel()
    
    func hideImageView()
    
    func showImageView()
    
    func hideYesButton()
    
    func hideNoButton()
    
    func showYesButton()
    
    func showNoButton()
    
    func enableYesButton()
    
    func disableYesButton()
    
    func enableNoButton()
    
    func disableNoButton()
    
    
    func showAlert(alert: UIAlertController)
    
    
    func showLoadingIndicator()
    
    func hideLoadingIndicator()
    
    
    func show(quiz step: QuizStepViewModel) 
    
    
    func highlightImageBorder(isCorrectAnswer: Bool)
}

