//
//  NetworkManager.swift
//  Inspirational Bytes
//
//  Created by Joel Gans on 9/16/22.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    enum Endpoints {
        static let base = "https://zenquotes.io/api/"

        case randomQuotesRequest
        case QOTD
        
        var stringValue: String {
            switch self {
            case .randomQuotesRequest:
                return Endpoints.base + "quotes"
            case .QOTD:
                return Endpoints.base + "today"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
          let task = URLSession.shared.dataTask(with: url) { data, response, error in
              guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                  return
              }
              guard let data = data else {
                  DispatchQueue.main.async {
                      completion(nil, error)
                  }
                  return
              }
              let decoder = JSONDecoder()
              do {
                  let responseObject = try decoder.decode(responseType, from: data)
                  DispatchQueue.main.async {
                      completion(responseObject, nil)
                  }
              } catch {
                  do {
                      let errorResponse = try decoder.decode([QuoteResponse].self, from: data) as! Error
                      DispatchQueue.main.async {
                          completion(nil, errorResponse)
                      }
                  } catch {
                      DispatchQueue.main.async {
                          completion(nil, error)
                      }
                  }
              }
          }
          task.resume()
          
          return task
      }
    
   class func getQuotes(completion: @escaping ([QuoteResponse]?, Error?) -> Void) {
        NetworkManager.taskForGETRequest(url: Endpoints.randomQuotesRequest.url, responseType: [QuoteResponse].self) { response, error in
            if error == nil {
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } else {
                completion(nil, error)
            }
        }
    }
    
    class func getQOTD(completion: @escaping ([QOTDResponse]?, Error?) -> Void) {
        NetworkManager.taskForGETRequest(url: Endpoints.QOTD.url, responseType: [QOTDResponse].self) { response, error in            if error == nil {
                DispatchQueue.main.async {
                    completion(response, nil)
                }
            } else {
                completion(nil ,error)
            }
        }
    }
        
        
}
