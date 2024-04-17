//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Никита Цепляев on 14.04.2024.
//

import XCTest



final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
        
    override func setUpWithError() throws {
            try super.setUpWithError()
            
            app = XCUIApplication()
            app.launch()
            
            // это специальная настройка для тестов: если один тест не прошёл,
            // то следующие тесты запускаться не будут; и правда, зачем ждать?
            continueAfterFailure = false
    }
    override func tearDownWithError() throws {
            try super.tearDownWithError()
            
            app.terminate()
            app = nil
    }
    
    
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
        
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"] 
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["No"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["GameResults"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Раунд окончен")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Начать еще раз")
    }
    
    
}
