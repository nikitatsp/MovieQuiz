import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var imageView: UIImageView!
    
    var alertPresenter: MovieQuiz.AlertPresenterProtocol?
    
    func hideBorder() {}
    
    func hideTextLabel() {}
    
    func showTextLabel() {}
    
    func hideImageView() {}
    
    func showImageView() {}
    
    func hideYesButton() {}
    
    func hideNoButton() {}
    
    func showYesButton() {}
    
    func showNoButton() {}
    
    func enableYesButton() {}
    
    func disableYesButton() {}
    
    func enableNoButton() {}
    
    func disableNoButton() {}
    
    
    func showAlert(alert: UIAlertController) {}
    
    
    func showLoadingIndicator() {}
    
    func hideLoadingIndicator() {}
    
    
    func show(quiz step: QuizStepViewModel) {}
    
    
    func highlightImageBorder(isCorrectAnswer: Bool) {}
}

final class MovieQuizPresenterTests: XCTestCase {
        func testPresenterConvertModel() throws {
            let viewControllerMock = MovieQuizViewControllerMock()
            let sut = MovieQuizPresenter(viewController: viewControllerMock)
            
            let emptyData = Data()
            let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
            let viewModel = sut.convert(model: question)
            
             XCTAssertNotNil(viewModel.image)
            XCTAssertEqual(viewModel.question, "Question Text")
            XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
