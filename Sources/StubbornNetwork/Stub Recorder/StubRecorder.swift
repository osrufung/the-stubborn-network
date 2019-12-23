//
//  StubRecorder.swift
//  
//
//  Created by Martin Kim Dung-Pham on 21.12.19.
//

import Foundation

struct StubRecorder: StubRecording {

    /// The _Stub Source_ dictates how the stub will be stored and where
    let stubSource: StubSourceProtocol

    /// This `URLSession` is used to get the actual data, response and error
    /// for the `URLSessionTask`s which are recorded.
    let urlSession: URLSession

    init(urlSession: URLSession, stubSource: StubSourceProtocol) {
        self.urlSession = urlSession
        self.stubSource = stubSource
    }

    func record(_ task: URLSessionTask?,
                processor: BodyDataProcessor?,
                completion: @escaping (Data?, URLResponse?, Error?) -> Void) {

        guard let task = task, let request = task.originalRequest else { return }

        if task.self.isKind(of: URLSessionDataTask.self) {
            urlSession.dataTask(with: request) { (data, response, error) in

                let body = request.httpBody
                let (prepRequestBodyData, prepResponseBodyData) = self.prepareBodyData(requestData: body,
                                                                                       responseData: data,
                                                                                       request: request,
                                                                                       processor: processor)

                var preparedRequest = request
                preparedRequest.httpBody = prepRequestBodyData

                let stub = RequestStub(request: preparedRequest,
                                       data: prepResponseBodyData,
                                       response: response,
                                       error: error)

                self.stubSource.store(stub)

                completion(data, response, error)
            }.resume()
        }
    }

    private func prepareBodyData(requestData: Data?,
                                 responseData: Data?,
                                 request: URLRequest,
                                 processor: BodyDataProcessor?) ->
                                 (preparedRequestBodyData: Data?, preparedResponseBodyData: Data?) {

            let prepRequestBodyData, prepResponseBodyData: Data?
            if let bodyDataProcessor = processor {
                prepRequestBodyData = bodyDataProcessor.dataForStoringRequestBody(data: requestData, of: request)
                prepResponseBodyData = bodyDataProcessor.dataForStoringResponseBody(data: responseData, of: request)
            } else {
                prepRequestBodyData = requestData
                prepResponseBodyData = responseData
            }
            return (prepRequestBodyData, prepResponseBodyData)
    }

}