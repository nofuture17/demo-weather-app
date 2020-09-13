
import Foundation

class AppError: NSError {
    class var defaultDomain: String {
        return "RonasWeather.app"
    }
    class var defaultCode: Int {
        return 200
    }
    
    convenience init(userInfo message: String) {
        self.init(domain: type(of: self).defaultDomain, code: type(of: self).defaultCode, userInfo: [NSLocalizedDescriptionKey: message])
        
    }
}
