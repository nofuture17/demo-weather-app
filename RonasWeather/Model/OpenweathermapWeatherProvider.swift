import Foundation
import Alamofire

class OpenweathermapWeatherProvider: WeatherProvider {
    private struct Parameters: Encodable {
        let q: String
        let appid: String
        let units = "metric"
    }
    
    private let appid: String
    private let baseUrl = "https://api.openweathermap.org/data/2.5/forecast"
    
    init(appid: String) {
        self.appid = appid
    }
    
    func callWeather(forCity city: String, completion: @escaping (WeatherProviderResult) -> Void) {
        AF.request(baseUrl, parameters: Parameters(q: city, appid: appid))
        .validate()
        .responseJSON { (result) in
            guard result.error == nil else {
                completion(WeatherProviderResult.error(ModelError(userInfo: "Weather recieving error")))
                return
            }
            
            guard
                let json = result.value as? [String: AnyObject],
                let weather = self.decodeWeather(json: json)
            else {
                completion(WeatherProviderResult.error(ModelError(userInfo: "Weather not recieved")))
                return
            }
            
            completion(WeatherProviderResult.success(weather))
        }
    }
    
    private func decodeWeather(json: [String: AnyObject]) -> Weather? {
        guard
            let list = json["list"] as? [[String: AnyObject]],
            let actual = list.first,
            let temperature = actual["main"]?["temp"] as? Double,
            let weather = actual["weather"] as? [[String: AnyObject]],
            let kind = weather[0]["main"] as? String,
            let pressure = actual["main"]?["pressure"] as? Int,
            let humidity = actual["main"]?["humidity"] as? Int,
            let wind = actual["wind"] as? [String: AnyObject],
            let windSpeed = wind["speed"] as? Double,
            let windDirectionDegrees = wind["deg"] as? Int,
            let probabilityOfPrecipitation = actual["pop"] as? Double,
            let iconID = weather[0]["icon"] as? String,
            let iconURL = createIconURL(iconID: iconID),
            let iconData = try? Data(contentsOf: iconURL),
            let iconImage = CIImage(data: iconData)
        else {
            return nil
        }
        
        return Weather(
            temperature: Int(temperature),
            weatherKind: kind,
            icon: iconImage,
            pressure: pressure,
            humidity: humidity,
            windSpeed: Int(windSpeed),
            windDirectionDegrees: windDirectionDegrees,
            probabilityOfPrecipitation: Int(probabilityOfPrecipitation * 100)
        )
    }
    
    private func createIconURL(iconID: String) -> URL? {
        return URL(string: "http://openweathermap.org/img/wn/\(iconID)@2x.png")
    }
}
