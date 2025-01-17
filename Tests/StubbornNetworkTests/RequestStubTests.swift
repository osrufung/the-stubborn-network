//
//  RequestStubTests.swift
//  
//
//  Created by Martin Kim Dung-Pham on 07.08.19.
//

import XCTest
@testable import StubbornNetwork

final class RequestStubTests: XCTestCase {

    func test_httpHeadersFromStrings() {
        let headersAsStrings = ["a[:::]A", "b[:::]B"]
        let expectedHeaders = ["a": "A", "b": "B"]

        let headers = RequestStub.httpHeaders(from: headersAsStrings)
        XCTAssertEqual(expectedHeaders, headers)
    }

    func test_requestStub_properlyEncodesRequests() throws {
        let url = try XCTUnwrap(URL(string: "123.4.5.6"))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "some data".data(using: .utf8)

        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "1.1", headerFields: ["A": "aaa"])

        let requestStub = RequestStub(request: request, response: response)

        let encoder = JSONEncoder()
        let result = try encoder.encode(requestStub)
        let json = String(data: result, encoding: .utf8)

        XCTAssertEqual(json,
        """
        {\"request\":{\"headerFields\":[],\"method\":\"POST\",\"requestData\":\"c29tZSBkYXRh\",\"url\":\"123.4.5.6\"}\
        ,\"response\":{\"statusCode\":200,\"headerFields\":[\"A[:::]aaa\"],\"responseData\":null,\
        \"url\":\"123.4.5.6\"}}
        """)
    }

    func testDecodesData() throws {
        let decoder = JSONDecoder()
        let stub = try decoder.decode(RequestStub.self, from: jsonMockData)
        XCTAssertEqual(stub.responseData, "abc".data(using: .utf8)!)
    }

    func testDecodesRequestBodyData() throws {
        let decoder = JSONDecoder()
        let stub = try decoder.decode(RequestStub.self, from: jsonMockData)
        XCTAssertEqual(stub.request.httpBody, "some data".data(using: .utf8)!)
    }

    func testDecodesHTTPMethod() throws {
        let decoder = JSONDecoder()
        let stub = try decoder.decode(RequestStub.self, from: jsonMockData)
        XCTAssertEqual(stub.request.httpMethod, "POST")
    }

    var jsonMockData: Data {
        """
        {
            "request": {
                "url": "https://api.elbedev.com",
                "requestData": "c29tZSBkYXRh",
                "headerFields": [
                    "A[:::]AAA",
                    "Content-Type[:::]text/xml; charset=utf-8",
                    "Accept-Language[:::]en-us",
                    "Accept[:::]*/*",
                    "Accept-Encoding[:::]br, gzip, deflate"
                ],
                "method": "POST"
            },
            "response": {
                "responseData": "YWJj",
                "url": "https://api.q231950.com",
                "statusCode": 200,
                "headerFields": []
            }
        }
        """.data(using: .utf8)!
    }

    static var allTests = [
        ("test_httpHeadersFromStrings",
        test_httpHeadersFromStrings),
        ("test_requestStub_properlyEncodesRequests",
        test_requestStub_properlyEncodesRequests),
        ("testDecodesData",
        testDecodesData),
        ("testDecodesHTTPMethod",
        testDecodesHTTPMethod),
    ]
}
