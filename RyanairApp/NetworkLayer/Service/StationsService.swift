//
//  StationsService.swift
//  RyanairApp
//
//  Created by Cathal Farrell on 28/02/2020.
//  Copyright © 2020 Cathal Farrell. All rights reserved.
//

import Foundation

struct StationsService {

    static let shared = StationsService()
    let session = URLSession(configuration: .default)

    func getStations(_ completion: @escaping (Result<APIResponseAllStations>) -> Void) {

        let baseURL = "https://tripstest.ryanair.com" //Usually set in an Environment Object

        let headers = HTTPHeaders([
            "Accept": "application/json",
            "Content-Type": "application/json"])

        //let parameters = [ "key": "value"]

        do {
            let request = try HTTPNetworkRequest.configureHTTPRequest(baseURL,
                                                                      from: .stations,
                                                                      with: nil,
                                                                      includes: headers,
                                                                      contains: nil,
                                                                      and: .get)

            Log.v("😀 Making this request: \(request) METHOD:\(request.httpMethod ?? "")")
            Log.v("😀 HEADERS: \(String(describing: headers))")

            session.dataTask(with: request) { (data, res, err) in

                if let response = res as? HTTPURLResponse, let unwrappedData = data {

                    let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                    switch result {

                    case .success:

                        do {
                            let jsonResult = try JSONDecoder().decode(APIResponseAllStations.self, from: unwrappedData)
                            //Log.v("✅ RESULT: \(String(describing: jsonResult))")
                            completion(Result.success(jsonResult))
                        } catch let err {
                            Log.e("🛑 Unable to parse JSON response: \(err.localizedDescription)")
                            completion(Result.failure(err))
                        }

                        //self.printAPIResponse(data: unwrappedData)

                    case .failure(let err):
                        Log.e("🛑 FAILED: \(result) error:\(err)")
                        completion(Result.failure(err))
                    }
                }

                if let err = err {
                    Log.e("🛑  ERROR: \(err.localizedDescription)")
                    completion(Result.failure(err))
                }

                }.resume()
        } catch let err {

            completion(Result.failure(err))
        }
    }

    func getSearch(_ parameters: [String: Any], completion: @escaping (Result<APIResponseSearchFlights>) -> Void) {

        //Usually set in an Environment Class
        let baseURL = "https://sit-nativeapps.ryanair.com/api/v4"

        let headers = HTTPHeaders([
            "Accept": "application/json",
            "Content-Type": "application/json"])

        do {
            let request = try HTTPNetworkRequest.configureHTTPRequest(baseURL,
                                                                      from: .availability,
                                                                      with: parameters,
                                                                      includes: headers,
                                                                      contains: nil,
                                                                      and: .get)

            Log.v("😀 Making this request: \(request) METHOD:\(request.httpMethod ?? "")")
            Log.v("😀 HEADERS: \(String(describing: headers))")

            session.dataTask(with: request) { (data, res, err) in

                if let response = res as? HTTPURLResponse, let unwrappedData = data {

                    let result = HTTPNetworkResponse.handleNetworkResponse(for: response)
                    switch result {

                    case .success:

                        do {
                            let jsonResult = try JSONDecoder().decode(APIResponseSearchFlights.self,
                                                                      from: unwrappedData)
                            Log.v("✅ RESULT: \(String(describing: jsonResult))")
                            completion(Result.success(jsonResult))
                        } catch let err {
                            Log.e("🛑 Unable to parse JSON response: \(err.localizedDescription)")
                            completion(Result.failure(err))
                        }

                        self.printAPIResponse(data: unwrappedData)

                    case .failure(let err):
                        Log.e("🛑 FAILED: \(result) error:\(err)")
                        completion(Result.failure(err))
                    }
                }

                if let err = err {
                    Log.e("🛑  ERROR: \(err.localizedDescription)")
                    completion(Result.failure(err))
                }

                }.resume()
        } catch let err {

            completion(Result.failure(err))
        }
    }

    func printAPIResponse(data: Data) {
        //Just for test print purposes
        do {
            let resultObject = try JSONSerialization.jsonObject(with: data, options: [])
            Log.v("✅ Results from request:\n\(resultObject)")
        } catch let err {
            Log.e("🛑 Unable to parse JSON response: \(err.localizedDescription)")
        }

    }
}
