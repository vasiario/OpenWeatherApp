//
//  WeatherService.swift
//  OpenWeatherApp
//
//  Created by Vasilii Riaskin on 21.03.2024.
//

import Foundation
import CoreLocation

class WeatherService {
    static let shared = WeatherService()
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather?&units=metric&appid=YourAPIKey"

    func fetchWeatherData(cityName: String, completion: @escaping (Result<WeatherModel, NetworkingError>) -> Void) {
        let urlString = "\(baseURL)&q=\(cityName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let urlString = urlString, let url = URL(string: urlString) else {
            completion(.failure(.badUrl))
            return
        }
        fetchData(from: url, completion: completion)
    }
    
    func fetchWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Result<WeatherModel, NetworkingError>) -> Void) {
        let urlString = "\(baseURL)&lat=\(latitude)&lon=\(longitude)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.badUrl))
            return
        }
        fetchData(from: url, completion: completion)
    }
    
    private func fetchData(from url: URL, completion: @escaping (Result<WeatherModel, NetworkingError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.badParsing))
                return
            }
            do {
                let weather = try JSONDecoder().decode(WeatherModel.self, from: data)
                completion(.success(weather))
            } catch {
                completion(.failure(.badParsing))
            }
        }.resume()
    }
}
