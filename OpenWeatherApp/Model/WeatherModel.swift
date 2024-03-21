//
//  WeatherModel.swift
//  OpenWeatherApp
//
//  Created by Vasilii Riaskin on 21.03.2024.
//

import Foundation
import UIKit

struct WeatherModel: Codable {
    let weather: [Weather]
    let main: Main
    let visibility: Int
    let name: String
    let wind: Wind
    
    var temperatureString: String {
        return String(format: "%.0f", main.temp) + "ºC"
    }
    
    var descriptionString: String {
        return weather[0].main
    }
    
    var feelsLikeString: String {
        return String(format: "%.0f", main.feels_like) + "ºC"
    }
    
    var pressureString: String {
        return "\(main.pressure) hPa"
    }
    
    var humidityString: String {
        return "\(main.humidity)%"
    }
    
    var visibilityString: String {
        return "\(visibility)m"
    }
    
    var windSpeedString: String {
        return String(format: "%.0f", wind.speed) + "m/s"
    }
    
    var windDirectionString: String {
        return "\(wind.deg)deg"
    }
   
    var backgroundImage: UIImage? {
        switch weather[0].id {
        case 200...232:
            return UIImage(named: "thunderstorm")
        case 300...321:
            return UIImage(named: "rain")
        case 500...531:
            return UIImage(named: "rain")
        case 600...622:
            return UIImage(named: "snow")
        case 701...781:
            return UIImage(named: "fog")
        case 801...804:
            return UIImage(named: "clouds")
        default:
            return UIImage(named: "clear")
        }
    }
}

struct Wind: Codable {
    let speed: Double
    let deg: Int
}

struct Weather: Codable {
    let id: Int
    let main: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
}
