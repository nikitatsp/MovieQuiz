import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didDismissAlert()
    func showAlert(alert: UIAlertController)
}
