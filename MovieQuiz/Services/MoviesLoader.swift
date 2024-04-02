import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()
    
    private var mostPopularMoviesUrl: URL {
            guard let url = URL(string: "https://tv-api.com/en/API/MostPopularMovies/k_zcuw1ytf") else {
                preconditionFailure("Unable to construct mostPopularMoviesUrl")
            }
            return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    
                    let filteredItems = mostPopularMovies.items.filter { $0.rating != nil }
                                    
                    // Создаем новую структуру MostPopularMovies с отфильтрованным массивом элементов
                    let filteredMovies = MostPopularMovies(errorMessage: mostPopularMovies.errorMessage, items: filteredItems)
                    
                    handler(.success(filteredMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    } 
}
