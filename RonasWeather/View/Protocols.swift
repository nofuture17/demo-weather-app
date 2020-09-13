import CoreLocation
import UIKit

protocol LocationProviderProtocol {
    func callCityNameFromLocation(location: CLLocation, completion: @escaping (String?) -> Void)
}

protocol WeatherProviderProtocol {
    func callWeather(forCity city: String, completion: @escaping (WeatherProviderViewModel.WeatherResult) -> Void)
}

protocol DefaultControllerProtocol: class {
    func showError(with error: NSError?)
    func createError(text: String) -> ViewError
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

extension DefaultControllerProtocol {
    func showError(with error: NSError?) {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error?.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alertController, animated: true, completion: nil)
    }

    func createError(text: String) -> ViewError {
        return ViewError(userInfo: text)
    }
}
