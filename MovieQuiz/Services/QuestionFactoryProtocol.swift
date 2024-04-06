import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    func loadData()
    func generateImage(movie: MostPopularMovie) -> Data
}
