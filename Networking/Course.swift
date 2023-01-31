//
//  Course.swift
//  Networking
//
//  Created by Дарья Бирюкова on 10.11.2022.
//

import Foundation

//структура для работы с URLSession
//struct Course: Decodable {
//
//    let id: Int?
//    let name: String?
//    let link: String?
//    let imageUrl: String?
//    let numberOfLessons: Int?
//    let numberOfTests: Int?
//}

//структура для работы с Alamofire
struct Course: Decodable {
    
    let id: Int?
    let name: String?
    let link: String?
    let imageUrl: String?
    let numberOfLessons: String?
    let numberOfTests: String?
    
    init?(json: [String: Any]) {
        let id = json["id"] as? Int
        let name = json["name"] as? String
        let link = json["link"] as? String
        let imageUrl = json["imageUrl"] as? String
        let numberOfLessons = json["numberOfLessons"] as? String
        let numberOfTests = json["numberOfTests"] as? String
        
        self.id = id
        self.name = name
        self.link = link
        self.imageUrl = imageUrl
        self.numberOfLessons = numberOfLessons
        self.numberOfTests = numberOfTests
    }
    
    //метод для получения и обработки массива
    static func getArray(from jsonArray: Any) -> [Course]? {
        
        //создаем массив, который будет содержать в себе словари типа String
        guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil}
        //возвращаем массив не nil результатов
        return jsonArray.compactMap { Course(json: $0) }
    }
}
