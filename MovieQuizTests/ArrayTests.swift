import XCTest
@testable import MovieQuiz



class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1, 2, 5, 9]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 5)
        
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 2, 5, 9]
        // When
        let value = array[safe: 5]
        // Then
        XCTAssertNil(value)
    }
    
    

    
}
