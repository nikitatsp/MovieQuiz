import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var accessibilityIdentifier: String
    var closure: (() -> Void)
    
    init(title: String, message: String, buttonText: String, accessibilityIdentifier: String, closure: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.buttonText = buttonText
        self.accessibilityIdentifier = accessibilityIdentifier
        self.closure = closure
    }
}
