
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension BLog.Network {
    class Sniffer: URLProtocol {
        enum Keys {
            static let request = "Sniffer.request"
            static let duration = "Sniffer.duration"
        }
        
        static var showBody = false
        static var showHeaders = false
        static var showPrivateHeaders = false
        
        static var onLogger: ((URL, String) -> Void)? // If the handler is registered, the log inside the Sniffer will not be output.
        static private var ignoreDomains: [String]?
        
        private lazy var session: URLSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        private var urlTask: URLSessionDataTask?
        private var urlRequest: NSMutableURLRequest?
        private var urlResponse: HTTPURLResponse?
        private var data: Data?
        private let serialQueue = DispatchQueue(label: "com.sniffer.serialQueue")
        
        static var bodyDeserializers: [String: BLogBodyDeserializerProtocol] = [
            "application/x-www-form-urlencoded": PlainTextBodyDeserializer(),
            "*/json": JSONBodyDeserializer(),
            "image/*": UIImageBodyDeserializer(),
            "text/plain": PlainTextBodyDeserializer(),
            "*/html": HTMLBodyDeserializer()
        ]
        
        class func register() {
            URLProtocol.registerClass(self)
        }
        
        class func unregister() {
            URLProtocol.unregisterClass(self)
        }
        
        class func enable(in configuration: URLSessionConfiguration) {
            configuration.protocolClasses?.insert(Sniffer.self, at: 0)
        }
        
        class func register(deserializer: BLogBodyDeserializerProtocol, `for` contentTypes: [String]) {
            for contentType in contentTypes {
                guard contentType.components(separatedBy: "/").count == 2 else { continue }
                bodyDeserializers[contentType] = deserializer
            }
        }
        
        class func ignore(domains: [String]) {
            ignoreDomains = domains
        }
        
        // MARK: - URLProtocol
        open override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url, let scheme = url.scheme else { return false }
            guard !isIgnore(with: url) else { return false }
            return ["http", "https"].contains(scheme) && self.property(forKey: Keys.request, in: request)  == nil
        }
        
        open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        private class func isIgnore(with url: URL) -> Bool {
            guard let ignoreDomains = ignoreDomains, !ignoreDomains.isEmpty,
                  let host = url.host else {
                      return false
                  }
            return ignoreDomains.first { $0.range(of: host) != nil } != nil
        }
        
        open override func startLoading() {
            if let _ = urlTask { return }
            guard let urlRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest , self.urlRequest == nil else { return }
            
            self.urlRequest = urlRequest
            
            Sniffer.setProperty(true, forKey: Keys.request, in: urlRequest)
            Sniffer.setProperty(Date(), forKey: Keys.duration, in: urlRequest)
            
            BLog.Network.networkRequest(urlRequest as URLRequest,
                                        file: nil,
                                        function: nil,
                                        line: nil)
            
            urlTask = session.dataTask(with: request)
            urlTask?.resume()
        }
        
        open override func stopLoading() {
            serialQueue.sync { [weak self] in
                self?.urlTask?.cancel()
                self?.urlTask = nil
                self?.session.invalidateAndCancel()
            }
        }
        
        // MARK: - Private
        fileprivate func clear() {
            defer {
                urlTask = nil
                urlRequest = nil
                urlResponse = nil
                data = nil
            }
            
            guard let urlRequest = urlRequest else { return }
            
            Sniffer.removeProperty(forKey: Keys.request, in: urlRequest)
            Sniffer.removeProperty(forKey: Keys.duration, in: urlRequest)
        }
    }
}

extension BLog.Network.Sniffer: URLSessionTaskDelegate, URLSessionDataDelegate {
    // MARK: - NSURLSessionDataDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        urlResponse = response as? HTTPURLResponse
        data = Data()
        
        completionHandler(.allow)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data?.append(data)
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            let logError = BLog.LogError(key: "Error", value: error.localizedDescription)
            BLog.Network.error(urlResponse,
                               request: urlRequest as URLRequest?,
                               error: [logError],
                               file: nil,
                               function: nil,
                               line: nil)
            
            client?.urlProtocol(self, didFailWithError: error)
        } else if let urlResponse = urlResponse {
            if let urlRequest = urlRequest as URLRequest? {
                BLog.Network.networkResponse(urlResponse,
                                             request: urlRequest,
                                             data: data,
                                             file: nil,
                                             function: nil,
                                             line: nil)
            } else {
                BLog.Network.networkResponse(urlResponse,
                                             data: data,
                                             file: nil,
                                             function: nil,
                                             line: nil)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        serialQueue.sync { [weak self] in
            self?.clear()
        }
        session.finishTasksAndInvalidate()
    }
}
