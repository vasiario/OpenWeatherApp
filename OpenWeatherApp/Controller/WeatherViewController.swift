//
//  WeatherViewController.swift
//  OpenWeatherApp
//
//  Created by Vasilii Riaskin on 21.03.2024.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    var backgroundImage: UIImageView!
    var cityNameLabel: UILabel!
    var tempLabel: UILabel!
    var weatherDescLabel: UILabel!
    var feelsLikeLabel: UILabel!
    var pressureLabel: UILabel!
    var humidityLabel: UILabel!
    var visibilityLabel: UILabel!
    var windSpeedLabel: UILabel!
    var windDirectionLabel: UILabel!
    var searchTextField: UITextField!
    var infoStackView: UIStackView!
    var temperatureStackView: UIStackView!
    var detailsStackView: UIStackView!
    var activityIndicator: UIActivityIndicatorView!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.delegate = self
        locationManager.delegate = self
        setupUI()
        configureLocationManager()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        
        backgroundImage = UIImageView(frame: view.bounds)
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.image = UIImage(named: "clear")
        view.addSubview(backgroundImage)
        
        searchTextField = UITextField()
        searchTextField.placeholder = "Pleace, enter the city"
        searchTextField.borderStyle = .roundedRect
        searchTextField.textColor = .white
        searchTextField.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.delegate = self
        view.addSubview(searchTextField)
        
        infoStackView = UIStackView()
        infoStackView.axis = .vertical
        infoStackView.spacing = 8
        infoStackView.distribution = .fillEqually
        infoStackView.translatesAutoresizingMaskIntoConstraints = false
        infoStackView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        infoStackView.layer.cornerRadius = 12
        view.addSubview(infoStackView)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        cityNameLabel = createLabel()
        tempLabel = createLabel()
        weatherDescLabel = createLabel()
        feelsLikeLabel = createLabel()
        pressureLabel = createLabel()
        humidityLabel = createLabel()
        visibilityLabel = createLabel()
        windSpeedLabel = createLabel()
        windDirectionLabel = createLabel()
        
        [cityNameLabel, tempLabel, weatherDescLabel, feelsLikeLabel, pressureLabel, humidityLabel, visibilityLabel, windSpeedLabel, windDirectionLabel].forEach {
            infoStackView.addArrangedSubview($0)
        }
        
        setupConstraints()
    }
    
    func createLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        return label
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            infoStackView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            infoStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func configureLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

//MARK: - TextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    func searchBtnPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Enter city name..."
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            Task {
                await weatherManager.fetchWeatherData(cityName: city)
            }
        }
        
        searchTextField.text = ""
        activityIndicator.startAnimating()
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.tempLabel.text = "Temperature: \(weather.temperatureString)"
            self.cityNameLabel.text = "City: \(weather.name)"
            self.weatherDescLabel.text = "Description: \(weather.descriptionString)"
            self.feelsLikeLabel.text = "Feels Like: \(weather.feelsLikeString)"
            self.pressureLabel.text = "Pressure: \(weather.pressureString)"
            self.humidityLabel.text = "Humidity: \(weather.humidityString)"
            self.visibilityLabel.text = "Visibility: \(weather.visibilityString)"
            self.windSpeedLabel.text = "Wind Speed: \(weather.windSpeedString)"
            self.windDirectionLabel.text = "Wind Direction: \(weather.windDirectionString)"
            
            self.backgroundImage.image = weather.backgroundImage
            self.activityIndicator.stopAnimating()
        }
    }
    
    func didFailWithError(error: NetworkingError) {
        switch error {
        case .badUrl:
            displaySimpleAlert(title: "Error", message: "We can't find this city")
        case .badParsing:
            displaySimpleAlert(title: "Error", message: "Try again, pleace")
        }
    }
}

//MARK: - LocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            fetchWeatherForCurrentLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("could not get location: \(error.localizedDescription)")
    }
    
    private func checkLocationAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else {  }
    }
    
    private func fetchWeatherForCurrentLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        Task {
            await weatherManager.fetchWeatherData(latitude: latitude, longitude: longitude)
        }
    }
}


//MARK: - Additional methods

extension WeatherViewController {
    func displaySimpleAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            self.activityIndicator.stopAnimating()
        }
    }
    
    func checkLocationAvailablility() {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            @unknown default:
                break
            }
        } else {
            displaySimpleAlert(title: "Error", message: "It looks like your location service is disabled. Enable in settings.")
        }
    }
}
