import XCTest
import AppTrackingTransparency
@testable import DataTrackerAuthorizer

final class DataTrackerAuthorizerTests: XCTestCase {
    
    var authorizerSpy: AuthorizerSpy!
    var sut: DataTracker!
    
    override func setUp() {
        authorizerSpy = AuthorizerSpy()
        sut = DataTracker(authorizer: authorizerSpy)
    }
    
    override func tearDown() {
        sut = nil
        authorizerSpy = nil
    }
    
    func test_init_doesNotRequestTrackingAuthorizationOnAuthorizer() {
        XCTAssertEqual(authorizerSpy.requestTrackingAuthorizationCalled, false)
    }
    
    func test_userAuthorizedATT_returnsTrueWhenAuthorizerReturnsAuthorized() {
        assertAuthorizationStatus(authorizationStatus: .authorized, expected: true)
    }
    
    func test_userAuthorizedATT_returnsFalseWhenAuthorizerReturnsDenied() {
        assertAuthorizationStatus(authorizationStatus: .denied, expected: false)
    }
    
    func test_userAuthorizedATT_returnsFalseWhenAuthorizerReturnsRestricted() {
        assertAuthorizationStatus(authorizationStatus: .restricted, expected: false)
    }
    
    func test_userAuthorizedATT_callsRequestTrackingAuthorizationOnAuthorizerForNonDeterminedStatus() {
        authorizerSpy.authorizationStatus = .notDetermined
        let exp = expectation(description: "should complete")
        
        sut.userAuthorizedATT { isAuthorized in
            exp.fulfill()
        }
        
        authorizerSpy.requestTrackingAuthorizationCompletions[0](.authorized)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(self.authorizerSpy.requestTrackingAuthorizationCallsCount, 1)
    }
    
    func test_userAuthorizedATT_withNonDeterminedAutorizationStatus_returnsTrueOnAuthorizedUserResponse() {
        assertNonDeterminedStatus(respondedStatus: .authorized, expected: true)
    }
    
    func test_userAuthorizedATT_withNonDeterminedAutorizationStatus_returnsFalseOnDeniedUserResponse() {
        assertNonDeterminedStatus(respondedStatus: .denied, expected: false)
    }
    
    func test_userAuthorizedATT_withNonDeterminedAutorizationStatus_returnsFalseOnRestrictedUserResponse() {
        assertNonDeterminedStatus(respondedStatus: .restricted, expected: false)
    }
    
    private func assertAuthorizationStatus(authorizationStatus: ATTrackingManager.AuthorizationStatus, expected: Bool, file: StaticString = #filePath, line: UInt = #line) {
        authorizerSpy.authorizationStatus = authorizationStatus
        let exp = expectation(description: "should complete")
        
        var captureAuthorized: Bool?
        sut.userAuthorizedATT { isAuthorized in
            captureAuthorized = isAuthorized
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(captureAuthorized, expected, file: file, line: line)
    }
    
    private func assertNonDeterminedStatus(respondedStatus: ATTrackingManager.AuthorizationStatus, expected: Bool, file: StaticString = #filePath, line: UInt = #line) {
        authorizerSpy.authorizationStatus = .notDetermined
        let exp = expectation(description: "should complete")
        
        var captureAuthorized: Bool?
        sut.userAuthorizedATT { isAuthorized in
            captureAuthorized = isAuthorized
            exp.fulfill()
        }
        
        authorizerSpy.requestTrackingAuthorizationCompletions[0](respondedStatus)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(captureAuthorized, expected, file: file, line: line)
    }
    
    final class AuthorizerSpy: Authorizer {
        var authorizationStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
        
        var requestTrackingAuthorizationCallsCount: Int {
            requestTrackingAuthorizationCompletions.count
        }
        
        var requestTrackingAuthorizationCalled: Bool {
            requestTrackingAuthorizationCallsCount > 0
        }
        
        var requestTrackingAuthorizationCompletions: [(ATTrackingManager.AuthorizationStatus) -> Void] = []
        
        func requestTrackingAuthorization(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
            requestTrackingAuthorizationCompletions.append(completion)
        }
    }
}
