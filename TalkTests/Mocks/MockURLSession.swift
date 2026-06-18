import Foundation
@testable import Talk

actor MockURLSession: URLSessionProtocol {
    private var result: Result<Data, Error>
    private(set) var requestCount = 0

    init(data: Data) {
        result = .success(data)
    }

    init(error: Error) {
        result = .failure(error)
    }

    func setResult(_ newResult: Result<Data, Error>) {
        result = newResult
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestCount += 1
        let data = try result.get()
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}
