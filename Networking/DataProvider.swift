//
//  DataProvider.swift
//  Networking
//
//  Created by Дарья Бирюкова on 21.12.2022.
//

import UIKit

class DataProvider: NSObject {
    
    private var downloadTask: URLSessionDownloadTask! //будем передавать в это св-во параметры конфигурации и исп-ть этот объеект для настройки сессии
    var fileLocation: ((URL) -> ())?
    var onProgress: ((Double) -> ())?
    
    //настроим параметры конфигурации для фоновой загрузки данных, создадим для этого свойство
    private lazy var bgSession: URLSession = {
        //создаем свойство, которое будет определять поведение сессии при загрузке и выгрузке данных, вызываем у класса метод для создания параметров конфигурации с возможностью фоновой загрузки данных
        let config = URLSessionConfiguration.background(withIdentifier: "ru.swiftbook.Networking")
        //определяем могут ли фоновые задачи быть запланированы по усмотрению системы для обеспечения оптимальной производительности
        config.isDiscretionary = true
        //время ожидания сети в секундах
        config.timeoutIntervalForResource = 300
        //позволяет системе дождаться подключения к сети
        config.waitsForConnectivity = true
        //по завершению загрузки данных приложение запустится в фоновом режиме
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func startDownload() {
    
        if let url = URL(string: "https://speed.hetzner.de/100MB.bin") { //ссылка по кот.будет загружаться файл
            downloadTask = bgSession.downloadTask(with: url) //объект копирует предоставленные параметры конфигурации и использует их для настройки сеанса
            downloadTask.earliestBeginDate = Date().addingTimeInterval(3) //загрузка начнется не ранее заданного времени (не ранее, чем через 3 сек после создания задачи)
            downloadTask.countOfBytesClientExpectsToSend = 512 //определяет наиболее вероятную верхнюю границу числа байтов, кот. клиент ожидает отправить
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024 //определяет наиболее вероятную верхнюю границу числа байтов, кот. клиент ожидает получить
            downloadTask.resume()
        }
    }
    
    func stopDownload() {
        downloadTask.cancel()
    }

}


extension DataProvider:URLSessionDelegate {
    //метод будет вызываться по завершению всех фоновых задач, помещенных в очередь с идентификатором приложения
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let completionHandler = appDelegate.bgSessionCompletionHandler else { return }
            appDelegate.bgSessionCompletionHandler = nil
            completionHandler()
        }
    }
}

extension DataProvider: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Did finish downloading \(location.absoluteString)")
        
        DispatchQueue.main.async {
            self.fileLocation?(location)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print("Download progress: \(progress)")
        
        DispatchQueue.main.async {
            self.onProgress?(progress)
        }
    }
}

extension DataProvider: URLSessionTaskDelegate {
    
    //восстановление соединения
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        //ожидание соединения, обновление интерфейса и прочее
    }
}
