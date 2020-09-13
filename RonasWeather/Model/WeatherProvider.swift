import Foundation

enum WeatherProviderResult {
    case success(Weather)
    case error(NSError)
}

protocol WeatherProvider {
    func callWeather(forCity city: String, completion: @escaping (WeatherProviderResult) -> Void)
}
