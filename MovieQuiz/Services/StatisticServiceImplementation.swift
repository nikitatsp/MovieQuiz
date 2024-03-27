import Foundation

final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
    
    
    func store(correct count: Int, total amount: Int) {
        var correctCount = userDefaults.integer(forKey: Keys.correct.rawValue)
        var totalCount = userDefaults.integer(forKey: Keys.total.rawValue)
        var resultGame = GameRecord(correct: count, total: amount, date: Date())
        
        correctCount += count
        totalCount += amount
        
        userDefaults.set(correctCount, forKey: Keys.correct.rawValue)
        userDefaults.set(totalCount, forKey: Keys.total.rawValue)
        
        if resultGame.isBetterThan(bestGame) {
            bestGame = resultGame
        }
        
        correctCount = userDefaults.integer(forKey: Keys.correct.rawValue)
        totalCount = userDefaults.integer(forKey: Keys.total.rawValue)
        
        var value1 = Double(correctCount)
        var value2 = Double(totalCount)
        
        totalAccuracy = (value1 / value2)*100
        
        gamesCount += 1
        
    }
    
    var totalAccuracy: Double = 0
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}
