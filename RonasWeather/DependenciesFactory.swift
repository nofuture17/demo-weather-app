class DependenciesFactory {
    private init() {}
    
    static private(set) var shared = DependenciesFactory()
    
    func getWeatherProviderViewModel() -> WeatherProviderProtocol {
        return WeatherProviderViewModel(weatherProvider: getWeatherProvider())
    }
    
    func getWeatherProvider() -> WeatherProvider {
        return OpenweathermapWeatherProvider(appid: "f908b83593c09853ea05dadbd4877a39")
    }
    
    func getLocationProviderViewModel() -> LocationProviderProtocol {
        return LocationProviderViewModel()
    }
}

extension WeatherProviderViewModel: WeatherProviderProtocol {}
extension LocationProviderViewModel: LocationProviderProtocol {}
