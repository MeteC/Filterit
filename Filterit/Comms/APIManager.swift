//
//  APIManager.swift
//  Filterit
//
//  Created by Mete Cakman on 24/09/19.
//  Copyright © 2019 Mete Cakman. All rights reserved.
//

import RxSwift
import RxCocoa



/// Protocol for the basic API call that returns data, for dependency injection / mocking
/// The intention is this data is what will be parsed by APIManager into useful Observables,
/// So you can replace the APICaller and make sure you return some predictable Observable<Data> type
/// Note that this is overkill for this simple app example, but demonstrates the principles
/// of dependency injection and mocking unit tests.
protocol APICaller {
    func pullAPIData(from request: URLRequest) -> Observable<Data>
}


/// Simple manager class encapsulating our "API" endpoints, returning reactive sequences of data.
/// At present there's just one GET endpoint (which actually points to static json data, but we don't necessarily know that on the client side.)
class APIManager: NSObject {
    
    /// Dependency injected API caller
    public var apiCaller: APICaller
    
    /// Custom errors for our APIManager.. 
    enum APIManagerError: Error {
        case badEndpointError
        
        var localizedDescription: String {
            switch self {
            case .badEndpointError:
                return "Malformed url endpoint"
            }
        }
    }
    
    /// Our default API caller implementation that works correctly using URLSession.shared.rx...
    private class DefaultAPICaller: APICaller {
        func pullAPIData(from request: URLRequest) -> Observable<Data> {
                return URLSession.shared.rx
                    .data(request: request)
        }
    }
    
    
    // init with default apiCaller injected
    init(apiCaller: APICaller = DefaultAPICaller()) {
        self.apiCaller = apiCaller
    }
    
    
    /// Kill all cookies. Prevents certain unhelpful responses from server (i.e. random 401 errors when you know you should be authorised just fine). 
    /// Not sure this is the best way to go about the issue...
    /// Of interest: Note that "static func" in swift == "final class func". So the difference between static and class funcs (in a class) is you can't override static...
    public static func clearCookies() {
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
    }
    
    // MARK:- API Calls
    
    /// Hit our listImages endpoint, pulling the json data and returning an Observable sequence of Image arrays 
    /// - Returns: Observable wrapped [Image] from server (note it just returns the one image array before completion)
    public func listImages() -> Observable<[Image]> {
        
        let endPoint = "https://MeteC.github.io/Filterit/server/api/listImages.json"
        
        guard let url = URL(string: endPoint) else {
            print("Failed to create URL for end point \(endPoint)")
            return Single<[Image]>
                .error(APIManagerError.badEndpointError)
                .asObservable()
        }
        
        return self.apiCaller.pullAPIData(from: URLRequest(url: url))
            .map({ (jsonData) -> [Image] in
                // if this try throws an error it triggers an Rx error 
                return try JSONDecoder().decode(ImageResponse.self, from: jsonData).images
            })
    }
}
