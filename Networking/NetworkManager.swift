//
//  NetworkManager.swift
//  Networking
//
//  Created by Дарья Бирюкова on 20.12.2022.
//

import UIKit

class NetworkManager {
    
    static func getRequest(url: String) {
        
        guard let url = URL(string: url) else { return }
                
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard
                let response = response,
                let data = data
                else { return }
            
            print(response)
            print(data)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                print(json)
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    static func postRequest(url: String) {
        
        guard let url = URL(string: url) else { return }
        
        let userData = ["Course":"Networking", "Lesson": "GET and POST requests"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") //добавление в запрос необходимых параметров
        
        // преобразование пользов.данных в JSON формат перед отправкой на сервер
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else { return }
        // поместим данные в тело запроса
        request.httpBody = httpBody
        
        // создаем сессию с задачей отправки данных на сервер
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard let response = response, let data = data else { return }
            
            print(response)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                print(json)
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    static func downloadImage(url: String, completion: @escaping (_ image: UIImage)->()) {
        
        // проверка URL адреса на валидность
        guard let url = URL(string: url) else { return }
        
        let session = URLSession.shared // создание общей сессии, тк позволяет извлечь содержимое URL адреса в память
        
        session.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                   completion(image)
                }
            }
        }.resume()
    }
    
    static func fetchData(url: String, completion: @escaping (_ courses: [Course])->()) {
        
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let courses = try decoder.decode([Course].self, from: data)
                completion(courses)
                
            } catch let error {
                print("Error serialization json", error)
            }
            
        }.resume()
    }
    
    static func uploadImage(url: String) {
        let image = UIImage(named: "Notification")!
        let httpHeaders = ["Authorization": "Client-ID 51c0bab2568b46e"] //imgur api
        guard let imageProperties = ImageProperties(withImage: image, forKey: "image") else { return }
        
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //передаем на сервер параметры авторизации
        request.allHTTPHeaderFields = httpHeaders
        //данные для отправки на сервер
        request.httpBody = imageProperties.data
        //создаем задачу,чтобы передать в нее наш запрос
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}
