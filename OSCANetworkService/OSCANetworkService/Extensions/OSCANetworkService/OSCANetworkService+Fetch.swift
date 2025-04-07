//
//  OSCANetworkService+Fetch.swift
//  OSCANetworkService
//
//  Created by Stephan Breidenbach on 30.01.23.
//

import Foundation
import OSCAEssentials
import Combine

// MARK: - Fetch
extension OSCANetworkService {
  // - MARK: fetch class schema
  /// Generic fetch method with generic `T` conforming to `OSCAParseClassObject`-protocol.
  ///
  /// It fetches Parse-class schemas from Parse mBaaS
  /// - Parameter resource : generic class schema request resource
  /// - Returns : publisher with an array of Parse class schema elements on the `Output`, and possible `OSCANetworkError`s on the `Fail` channel
  @discardableResult
  public func fetch<Request>(_ resource: Request) -> AnyPublisher<[Request.Response], OSCANetworkError> where Request: OSCAClassSchemaRequestResourceProtocol {
    
    // there is a well formed request!
    guard let request = resource.requestClassSchema else {
      // return NetworkError: invalid request
      return Fail.init(outputType: [Request.Response].self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }// end request
    
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<[Request.Response], OSCANetworkError> in
        // decode query resoponse from json
        var queryResponse: QueryResponse<Request.Response>?
        do {
          let singleResponse = try? OSCACoding.jsonDecoder().decode(Request.Response.self, from: data)
          if let singleResponse = singleResponse {
            queryResponse = QueryResponse<Request.Response>(results: [singleResponse], count: 1)
          } else {
            queryResponse = try OSCACoding.jsonDecoder().decode(QueryResponse<Request.Response>.self, from: data)
          }// end if
        } catch {
          // json decoding failure
          return Fail.init(outputType: [Request.Response].self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end do catch
        // there is a valid decoded query response!
        guard let queryResponse = queryResponse else {
          // json decoding failure
          return Fail.init(outputType: [Request.Response].self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        
        return Just(queryResponse.results)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
        
      }// end flat map
      .eraseToAnyPublisher()
  }// end public func fetch
  
  // - MARK: fetch class
  /// Generic fetch method with generic `Request.Response` conforming to `OSCAParseClassObject` and `Hashable` - protocol.
  ///
  /// It fetches Parse-classes from Parse mBaaS
  /// - Returns : publisher with an array of Parse class elements on the `Output`, and possible `OSCANetworkError`s on the `Fail` channel
  @discardableResult
  public func fetch<Request>(_ resource: Request) -> AnyPublisher<[Request.Response], OSCANetworkError> where Request: OSCAClassRequestResourceProtocol {
    // there is a well formed request!
    guard let request = resource.requestClass else {
      // return NetworkError: invalid request
      return Fail.init(outputType: [Request.Response].self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }// end guard
    // initialize data task publisher for well formed request
    
    // <(data, response) , URLError> ->
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<[Request.Response], OSCANetworkError> in
        // decode query resoponse from json
        var queryResponse: QueryResponse<Request.Response>?
        do {
          queryResponse = try OSCACoding.jsonDecoder().decode(QueryResponse<Request.Response>.self, from: data)
        } catch {
          // json decoding failure
          return Fail.init(outputType: [Request.Response].self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end do catch
        // there is a valid decoded query response!
        guard let queryResponse = queryResponse else {
          // json decoding failure
          return Fail.init(outputType: [Request.Response].self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        
        return Just(queryResponse.results)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
        
      }// end flat map
      .eraseToAnyPublisher()
  }// end func fetch class resource
  
  // - MARK: fetch bundle
  /**
   mockup generic fetch method with generic `Request.Response` conforming to `OSCAParseClassObject` and `Hashable`-protocol.
   
   It fetches Parse-classes from `JSON`-file
   - Returns: publisher with an array of Parse class elements on the `Output`, and possible `OSCANetworkErrors`s on the `Fail` channel
   */
  @discardableResult
  public func fetch<Request>(_ resource: Request) -> AnyPublisher<[Request.Response], OSCANetworkError> where Request: OSCABundleRequestResourceProtocol {
    guard let request: (bundle: Bundle, fileURL: URL) = resource.requestJSON else {
      // return networkError: invalid request
      return Fail.init(outputType: [Request.Response].self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }// end guard
    var data: Data
    do {
      data = try Data(contentsOf: request.fileURL)
    } catch {
      return Fail.init(outputType: [Request.Response].self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }// end do try catch
    return Just((data))
      .setFailureType(to: OSCANetworkError.self)
      .flatMap { data -> AnyPublisher<[Request.Response], OSCANetworkError> in
        // decode query resoponse from json
        var queryResponse: QueryResponse<Request.Response>?
        do {
          queryResponse = try OSCACoding.jsonDecoder().decode(QueryResponse<Request.Response>.self, from: data)
        } catch {
          // json decoding failure
          return Fail.init(outputType: [Request.Response].self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end do catch
        // there is a valid decoded query response!
        guard let queryResponse = queryResponse else {
          // json decoding failure
          return Fail.init(outputType: [Request.Response].self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        
        return Just(queryResponse.results)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
        
      }// end flat map
      .eraseToAnyPublisher()
  }// end public func fetch bundle resource
  
  // - MARK: fetch OSCAImageData
  /// fetch method for image files from any base URL
  ///
  ///  it fetches `Data` from any base URL
  ///  - Returns: publisher with an `Data` object on the `Output`, and possible `OSCANetworkError`s on the `Fail` channel
  @discardableResult
  public func fetch<Request>(_ resource: Request) -> AnyPublisher<Request.Response, OSCANetworkError> where Request: OSCAImageDataRequestResourceProtocol {
    guard let request = resource.requestImageData else {
      return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidRequest)
        .eraseToAnyPublisher()
    }// end guard
    
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<Request.Response, OSCANetworkError> in
        // return data
        guard let objectId = resource.objectId
        else {
          return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidRequest)
            .eraseToAnyPublisher()
        }// end guard
        let returnData = Request.Response.init(objectId: objectId, imageData: data)
        return Just(returnData)
        // with failure type OSCANetworkError
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
      }// end flat map
      .eraseToAnyPublisher()
  }// end fetch data request resource
  
  // - MARK: fetch OSCAUrlData
  /// fetch method for image files from URL
  /// it fetches `OSCAUrlData`from any URL
  /// - Returns: publisher with an `OSCAUrlData` object on the `Output`, and possible `OSCANetworkError` on the `Fail`channel
  @discardableResult
  public func fetch<Request>(_ resource: Request) -> AnyPublisher<Request.Response, OSCANetworkError> where Request: OSCAUrlDataRequestResourceProtocol {
    guard let request = resource.requestUrlData else {
      return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }// end guard
    
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<Request.Response, OSCANetworkError> in
        // return data
        guard let url = resource.url
        else {
          return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidRequest)
            .eraseToAnyPublisher()
        }// end guard
        let returnUrlData: Request.Response = Request.Response.init(url: url, data: data)
        return Just(returnUrlData)
        // with failure type OSCANetworkError
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
      }// end flat map
      .eraseToAnyPublisher()
  }// end fetch data request resource
  
  // - MARK: fetch Data from url
  /// fetch method for image for data from URL
  /// - Parameter url: endpoint from where to fetch
  /// - Returns: publisher with an `Data`obect on the `Output`, and possible `OSCANetworkError`on the `Fail` channel
  @discardableResult
  public func fetch(_ url: URL) -> AnyPublisher<Foundation.Data, OSCANetworkError> {
    // synthesizing request with url
    var urlRequest = URLRequest(url: url)
    // http method GET
    urlRequest.httpMethod = HTTPMethodType.get.rawValue
    return self.getDataTaskPublisher(urlRequest)
      .flatMap { data -> AnyPublisher<Foundation.Data, OSCANetworkError> in
        // return data
        return Just(data)
        // with failure type OSCANetworkError
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
      }// end flat map
      .eraseToAnyPublisher()
  }// end public func fetch Data from url
  
  // - MARK: fetch network config
  /// Generic fetch method with generic `T` conforming to `Decodable`-protocol.
  ///
  /// It fetches Parse-classes from Parse mBaaS
  /// - Returns : publisher with an array of Parse class elements on the `Output`, and possible `OSCANetworkError`s on the `Fail` channel
  @discardableResult
  public func fetch<Request>(_ resource: Request) -> AnyPublisher<Request.Response, OSCANetworkError> where Request: OSCANetworkConfigRequestResourceProtocol {
    // there is a well formed request!
    guard let request = resource.requestConfig else {
      // return NetworkError: invalid request
      return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }// end let request
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<Request.Response, OSCANetworkError> in
        // decode resoponse from json
        var resoponse: Request.Response?
        do {
          resoponse = try OSCACoding.jsonDecoder().decode(Request.Response.self, from: data)
        } catch {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end do catch
        // there is a valid decoded response!
        guard let resoponse = resoponse else {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        
        return Just(resoponse)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
        
      }// end flat map
      .eraseToAnyPublisher()
  }// end func fetch config
  
  // - MARK: fetch function
  /// Generic fetch method with generic `Result` conforming to `Decodable`-protocol and `CloudFunctionParameter` conforming to `Encodable` - protocol.
  ///
  /// It fetches decodable objects from Parse mBaaS
  /// - Returns : publisher with an array of decodable elements on the `Output`, and possible `OSCANetworkError`s on the `Fail` channel
  @discardableResult
  public func fetch<Response, Request>(_ resource: Request) -> AnyPublisher<Response, OSCANetworkError> where Response : Decodable, Request: OSCAFunctionRequestResourceProtocol {
    // there is a well formed request!
    guard let request = resource.requestFunction else {
      // return NetworkError: invalid request
      return Fail.init(outputType: Response.self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }//end let request
    
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<Response, OSCANetworkError> in
        // decode query resoponse from json
        var functionResponse: FunctionResponse<Response>?
        do {
          functionResponse = try OSCACoding.jsonDecoder().decode(FunctionResponse<Response>.self, from: data)
          #if DEBUG
                    print(functionResponse as Any)
          #endif
        } catch DecodingError.dataCorrupted(let context) {
#if DEBUG
          print(context)
#endif
        } catch DecodingError.keyNotFound(let key, let context) {
#if DEBUG
          print("Key '\(key)' not found:", context.debugDescription)
          print("codingPath:", context.codingPath)
#endif
        } catch DecodingError.valueNotFound(let value, let context) {
#if DEBUG
          print("Value '\(value)' not found:", context.debugDescription)
          print("codingPath:", context.codingPath)
#endif
        } catch DecodingError.typeMismatch(let type, let context) {
#if DEBUG
          print("Type '\(type)' mismatch:", context.debugDescription)
          print("codingPath:", context.codingPath)
#endif
        } catch {
#if DEBUG
          print("error: ", error)
#endif
          // json decoding failure
          return Fail.init(outputType: Response.self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end try catch
        
        // there is a valid decoded query response!
        guard let functionResponse = functionResponse else {
          // json decoding failure
          return Fail.init(outputType: Response.self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        
        return Just(functionResponse.result)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
        
      }// end flat map
      .eraseToAnyPublisher()
  }// end func fetch
  
  // - MARK: fetch installation
  /// fetch method for `ParseInstallation` object
  ///
  /// it fetches a decodable `ParseInstallation` object from Parse mBaaS
  /// - Returns: publisher with an `ParseInstallation` object on the `Output`, and possible `OSCANetworkErro` on the `Fail`channel
  @discardableResult
  public func fetch<Request>(_ resource: Request) -> AnyPublisher<Request.Response, OSCANetworkError> where Request: OSCAInstallationRequestResourceProtocol {
    // there is a well formed request!
    guard let request = resource.requestInstallation else {
      // return NetworkError: invalid request
      return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }// end let request
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<Request.Response, OSCANetworkError> in
        // decode query resoponse from json
        var queryResponse: Request.Response?
        do {
          queryResponse = try OSCACoding.jsonDecoder().decode(Request.Response.self, from: data)
        } catch {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end do catch
        // there is a valid decoded query response!
        guard let parseInstallationResponse = queryResponse else {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        return Just(parseInstallationResponse)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
      }// end flat map
      .eraseToAnyPublisher()
  }// end public func fetch with installation request
  
  // - MARK: fetch session
  @discardableResult
  public func fetch<Request>(_ resource: Request) -> AnyPublisher<Request.Response, OSCANetworkError> where Request: OSCASessionRequestResourceProtocol {
    // there is a well formed request!
    guard let request: URLRequest = resource.requestSession else {
      // return NetworkError: invalid request
      return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }
    // <(data, response) , URLError> ->
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<Request.Response, OSCANetworkError> in
        // decode query resoponse from json
        var queryResponse: Request.Response?
        do {
          queryResponse = try OSCACoding.jsonDecoder().decode(Request.Response.self, from: data)
#if DEBUG
          if let parseSession: Request.Response = queryResponse {
            print("QueryResponse: \(parseSession)")
          } else {
            print("No QueryResponse")
          }// end if
#endif
        } catch {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end do catch
        // there is a valid decoded query response!
        guard let parseSession = queryResponse else {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        
        return Just(parseSession)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
        
      }// end flat map
      .eraseToAnyPublisher()
  }// end public func fetch with session request
  
  
  // - MARK: fetch user
  /// fetch method for `ParseUser`object as Session Token validation
  /// - Returns: publisher with an `ParseUser`object on the `Output`, and possible `OSCANetworkError`on the `Fail`channel
  @discardableResult
  public func fetch<Request>(_ resource: Request) -> AnyPublisher<Request.Response, OSCANetworkError> where Request: OSCAUserRequestResourceProtocol {
    // there is a well formed request!
    guard let request: URLRequest = resource.sessionTokenValidation else {
      // return NetworkError: invalid request
      return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidRequest).eraseToAnyPublisher()
    }//e dn let request
    return self.getDataTaskPublisher(request)
      .flatMap { data -> AnyPublisher<Request.Response, OSCANetworkError> in
        // decode query resoponse from json
        var queryResponse: Request.Response?
        do {
          queryResponse = try OSCACoding.jsonDecoder().decode(Request.Response.self, from: data)
#if DEBUG
          if let parseUser: Request.Response = queryResponse {
            print("QueryResponse: \(parseUser)")
          } else {
            print("No QueryResponse")
          }// end if
#endif
        } catch {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure:
                            OSCANetworkError.jsonDecodingError(error: error))
          .eraseToAnyPublisher()
        }// end do catch
        // there is a valid decoded query response!
        guard let parseUser = queryResponse else {
          // json decoding failure
          return Fail.init(outputType: Request.Response.self, failure: OSCANetworkError.invalidResponse)
            .eraseToAnyPublisher()
        }// end guard
        
        return Just(parseUser)
          .setFailureType(to: OSCANetworkError.self)
          .eraseToAnyPublisher()
        
      }// end flat map
      .eraseToAnyPublisher()
  }// end public fetch with OSCAUserRequestResource
}// end extension final class OSCANetworkService
