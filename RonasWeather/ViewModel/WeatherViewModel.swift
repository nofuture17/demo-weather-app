import UIKit

struct WeatherViewModel {
    enum Unit: String {
        case C, F
    }
    
    private let weather: Weather
    var weatherKind: String? {
        guard let weatherKind = weather.weatherKind else {
            return nil
        }
        return NSLocalizedString(weatherKind, comment: "")
    }
    var weatherKindImage: UIImage? {
        guard let icon = weather.icon else {
            return nil
        }
        return UIImage(ciImage: icon)
    }
    var pressure: String? {
        guard let pressure = weather.pressure else {
            return nil
        }
        
        return "\(pressure) " + NSLocalizedString("mm Hg", comment: "")
    }
    var humidity: String? {
        guard let humidity = weather.humidity else {
            return nil
        }
        
        return  "\(humidity)%"
    }
    var wind: String? {
        guard
            let windSpeed = weather.windSpeed,
            let windDirectionDegrees = weather.windDirectionDegrees
        else {
            return nil
        }
        
        var wind = "\(windSpeed) " + NSLocalizedString("m/s", comment: "")
        if let direction = calculateWindDirection(windDirectionDegrees: windDirectionDegrees) {
            wind += ", " + direction
        }
        
        return wind
    }
    var probabilityOfPrecipitation: String? {
        guard let probabilityOfPrecipitation = weather.probabilityOfPrecipitation else {
            return nil
        }
        
        return "\(probabilityOfPrecipitation)%"
    }
    
    init(weather: Weather) {
        self.weather = weather
    }
    
    func getTemperature(unit: Unit) -> String? {
        if let temperature = weather.temperature {
            return "\(calculateTemperatureUnits(temperature: temperature, unit: unit))˚\(unit)"
        } else {
            return nil
        }
    }
    
    private func calculateWindDirection(windDirectionDegrees: Int) -> String? {
        var direction: String?
        switch windDirectionDegrees {
        case 0...22, 338...360:
            direction = "northern"
        case 23..<68:
            direction = "northeast"
        case 68..<113:
            direction = "east"
        case 113..<158:
            direction = "southeast"
        case 158..<203:
            direction = "south"
        case 203..<248:
            direction = "southwest"
        case 248..<293:
            direction = "west"
        case 293...338:
            direction = "northwest"
        default:
            return nil
        }
        print(windDirectionDegrees)
        return NSLocalizedString(direction!, comment: "")
    }
    
    private func calculateTemperatureUnits(temperature: Int, unit: Unit) -> Int {
        if unit == .C {
            return temperature
        } else {
           return (temperature * 9/5) + 32
        }
    }
}
