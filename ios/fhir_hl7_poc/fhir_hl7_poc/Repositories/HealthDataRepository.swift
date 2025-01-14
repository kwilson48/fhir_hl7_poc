import Foundation

@globalActor actor HealthDataRepositoryActor {
    static let shared = HealthDataRepositoryActor()
}

protocol HealthDataRepositoryProtocol {
    func getPatient() async throws -> LocalPatient
    func getAppointment() async throws -> LocalAppointment
    func getHeartRate() async throws -> LocalObservationData
}

@HealthDataRepositoryActor
class HealthDataRepository: HealthDataRepositoryProtocol {
    private let adapter: FHIRAdapterProtocol
    private let apiService: APIServiceProtocol

    init(adapter: FHIRAdapterProtocol, apiService: APIServiceProtocol) {
        self.adapter = adapter
        self.apiService = apiService
    }

    func getPatient() async throws -> LocalPatient {
        let fhirPatient = try await apiService.fetchPatient()
        return await adapter.adaptPatient(fhirPatient)
    }

    func getAppointment() async throws -> LocalAppointment {
        let fhirAppointment = try await apiService.fetchAppointment()
        return await adapter.adaptAppointment(fhirAppointment)
    }

    func getHeartRate() async throws -> LocalObservationData {
        let fhirObservation = try await apiService.fetchHeartRate()
        return await adapter.adaptObservation(fhirObservation)
    }
} 