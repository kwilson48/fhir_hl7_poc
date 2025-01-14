import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
}

protocol APIServiceProtocol: Actor {
    func fetchPatient() async throws -> [String: Any]
    func fetchAppointment() async throws -> [String: Any]
    func fetchHeartRate() async throws -> [String: Any]
}

actor APIService: APIServiceProtocol {
    private let baseURL = "https://hl7.org/fhir"
    private let logger: Logger
    
    init(logger: Logger) async {
        self.logger = logger
    }
    
    func fetchPatient() async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/patient-example.json") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw APIError.decodingError(NSError(domain: "", code: -1))
            }
            return json
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchAppointment() async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/appointment-example.json") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw APIError.decodingError(NSError(domain: "", code: -1))
            }
            logger.log("Fetched Appointment Data: \(json)", level: LogLevel.debug)
            return json
        } catch {
            logger.log("Failed to fetch appointment: \(error)", level: LogLevel.error)
            throw APIError.networkError(error)
        }
    }
    
    func fetchHeartRate() async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/observation-example-heart-rate.json") else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw APIError.decodingError(NSError(domain: "", code: -1))
            }
            return json
        } catch {
            throw APIError.networkError(error)
        }
    }
} 
