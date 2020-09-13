//
//  ViewController.swift
//  RonasWeather
//
//  Created by Анна on 10.09.2020.
//  Copyright © 2020 ar2041@bk.ru. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, DefaultControllerProtocol {
    
    struct Const {
        static let citySearchAnimationDuration = 1.0
        static let segmentedUnitInputSelectedColor = UIColor.white
        static let segmentedUnitInputNormalColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        static let swichAnimationDuration = 0.15
    }
    
    private var currentWeather: WeatherViewModel?
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        return manager
    }()
    private lazy var weatherProvider: WeatherProviderProtocol = {
        return DependenciesFactory.shared.getWeatherProviderViewModel()
    }()
    private lazy var locationProvider: LocationProviderProtocol = {
        return DependenciesFactory.shared.getLocationProviderViewModel()
    }()
    
    @IBOutlet weak var temperatureUnitInput: UISegmentedControl!
    @IBOutlet weak var citySearchView: UIView!
    @IBOutlet weak var selectedCityView: UIView!
    @IBOutlet weak var preloadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var citySearchInput: UITextField!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherKindImageView: UIImageView!
    @IBOutlet weak var weatherKindLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windValueView: UILabel!
    @IBOutlet weak var pressureValueView: UILabel!
    @IBOutlet weak var humidityValueView: UILabel!
    @IBOutlet weak var probabilityOfPrecipitationValueView: UILabel!
    @IBAction func searchInputEnter(_ sender: Any) {
        searchCityWeather()
    }
    @IBAction func setCurrentLocationButtonPressed(_ sender: Any) {
        callWeatherForCurrentLocation()
    }
    @IBAction func changeCityButtonPressed(_ sender: Any) {
        showCitySearchView()
    }
    @IBAction func temperatureUnitChanged(_ sender: Any) {
        updateTemperature()
    }
    @IBAction func searchButtonPressed(_ sender: Any) {
        searchCityWeather()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        callWeatherForCurrentLocation()
    }
    
    private func searchCityWeather() {
        showSelectedCityView()
        guard let cityName = citySearchInput.text, cityName.count > 0 else {
            return
        }
        callWeather(city: cityName)
    }
    
    private func configureViews() {
        temperatureUnitInput.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Const.segmentedUnitInputNormalColor], for: .normal)
        temperatureUnitInput.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Const.segmentedUnitInputSelectedColor], for: .selected)
    }
    
    private func callWeatherForCurrentLocation() {
        startPreloading()
        locationManager.requestLocation()
    }
    
    private func callWeather(city: String) {
        startPreloading()
        let completion: (WeatherProviderViewModel.WeatherResult) -> Void = { [unowned self] (result) in
            DispatchQueue.main.async {
                self.stopPreloading()
                switch result {
                case .success(let value):
                    self.updateCityName(name: city)
                    self.updateWeather(value)
                case .error(let error):
                    self.showError(with: error)
                }
            }
        }
        DispatchQueue.global().async {
            self.weatherProvider.callWeather(forCity: city, completion: completion)
        }
    }
    
    private func updateCityName(name: String) {
        cityNameLabel.text = name
    }
    
    private func updateWeather(_ weather: WeatherViewModel) {
        currentWeather = weather
        windValueView.text = weather.wind
        pressureValueView.text = weather.pressure
        humidityValueView.text = weather.humidity
        weatherKindLabel.text = weather.weatherKind
        probabilityOfPrecipitationValueView.text = weather.probabilityOfPrecipitation
        weatherKindImageView.image = weather.weatherKindImage
        updateTemperature()
    }
    
    private func updateTemperature() {
        guard let weather = currentWeather else {
            temperatureLabel.text = nil
            return
        }
        
        guard let unit = getCurrentTemperatureUnit() else {
            showError(with: createError(text: "Wrong temperature unit slected"))
            return
        }
        
        temperatureLabel.text = weather.getTemperature(unit: unit)
    }
    
    private func getCurrentTemperatureUnit() -> WeatherViewModel.Unit? {
        return WeatherViewModel.Unit(rawValue: temperatureUnitInput.titleForSegment(at: temperatureUnitInput.selectedSegmentIndex)!)
    }
    
    private func stopPreloading() {
        preloadingActivityIndicator.stopAnimating()
    }
    
    private func startPreloading() {
        preloadingActivityIndicator.startAnimating()
    }
    
    private func showSelectedCityView(completion: (() -> Void)? = nil) {
        citySearchInput.endEditing(false)
        UIView.animate(withDuration: Const.swichAnimationDuration, animations: {
            self.citySearchView.alpha = 0
        }, completion: {
            if $0 {
                self.selectedCityView.alpha = 1
            }
        })
    }
    
    private func showCitySearchView(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: Const.swichAnimationDuration, animations: {
            self.selectedCityView.alpha = 0
        }, completion: {
            if $0 {
                self.citySearchView.alpha = 1
            }
        })
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationProvider.callCityNameFromLocation(location: location) { [unowned self] (cityName) in
                guard let cityName = cityName else {
                    self.showError(with: self.createError(text: "City not recieved"))
                    return
                }
                self.callWeather(city: cityName)
            }
        } else {
            showError(with: createError(text: "Location not recieved"))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(with: createError(text: "Location recieving error"))
    }
}
