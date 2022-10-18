import AppTrackingTransparency
import Foundation

protocol Authorizer {
    
    var authorizationStatus: ATTrackingManager.AuthorizationStatus { get }
    
    func requestTrackingAuthorization(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void)
}

class DataTracker {
    private let authorizer: Authorizer
    
    init(authorizer: Authorizer) {
        self.authorizer = authorizer
    }
    
    func userAuthorizedATT(completion: @escaping(Bool) -> Void) {
        switch authorizer.authorizationStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            authorizer.requestTrackingAuthorization { status in
                completion(status == .authorized)
            }
        default:
            completion(false)
        }
    }
}

final class ATTrackingAuthorizer: Authorizer {
    var authorizationStatus: ATTrackingManager.AuthorizationStatus {
        return ATTrackingManager.trackingAuthorizationStatus
    }
    
    func requestTrackingAuthorization(completion: @escaping (ATTrackingManager.AuthorizationStatus) -> Void) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: completion)
    }
}
