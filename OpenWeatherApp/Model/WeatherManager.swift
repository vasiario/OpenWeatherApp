//
//  WeatherManager.swift
//  OpenWeatherApp
//
//  Created by Vasilii Riaskin on 21.03.2024.
//

import Foundation
import CoreLocation

enum NetworkingError: Error {
    case badUrl, badParsing
}

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: NetworkingError)
}

struct WeatherManager {
    var delegate: WeatherManagerDelegate?
    
    let openWeatherURL = "https://api.openweathermap.org/data/2.5/weather?&units=metric&appid=\(APISecret.key)"
    
    func fetchWeatherData(cityName: String) async {
        let urlString = "\(openWeatherURL)&q=\(cityName)"
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        await performRequest(with: encodedUrlString ?? urlString)
    }
    
    func fetchWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) async {
        let urlString = "\(openWeatherURL)&lat=\(latitude)&lon=\(longitude)"
        await performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) async {
        if let url = URL(string: urlString) {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let decodedResponse = try? JSONDecoder().decode(WeatherModel.self, from: data) {
                    delegate?.didUpdateWeather(self, weather: decodedResponse)
                } else {
                    delegate?.didFailWithError(error: NetworkingError.badUrl)
                }
            } catch {
                delegate?.didFailWithError(error: NetworkingError.badParsing)
            }
        }
    }
}
