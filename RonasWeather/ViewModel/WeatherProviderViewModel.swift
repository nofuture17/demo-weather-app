import Foundation

class WeatherProviderViewModel {
    enum WeatherResult {
        case success(WeatherViewModel)
        case error(NSError)
    }
    
    private let weatherProvider: WeatherProvider
    
    init(weatherProvider: WeatherProvider) {
        self.weatherProvider = weatherProvider
    }
    
    func callWeather(forCity city: String, completion: @escaping (WeatherResult) -> Void) {
        weatherProvider.callWeather(forCity: city) { (result) in
            switch result {
            case .error(let error):
                completion(WeatherResult.error(error))
            case.success(let weather):
                completion(WeatherResult.success(WeatherViewModel(weather: weather)))
            }
        }
    }
}
