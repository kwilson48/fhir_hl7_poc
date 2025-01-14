import Foundation

protocol FHIRAdapterProtocol {
    func adaptPatient(_ patient: [String: Any]) async -> LocalPatient
    func adaptAppointment(_ appointment: [String: Any]) async -> LocalAppointment
    func adaptObservation(_ observation: [String: Any]) async -> LocalObservationData
}

@globalActor actor FHIRAdapterActor {
    static let shared = FHIRAdapterActor()
}

@FHIRAdapterActor
final class FHIRAdapterService: FHIRAdapterProtocol {
    init() {}
    
    func adaptPatient(_ patient: [String: Any]) async -> LocalPatient {
        await FHIRAdapter.convert(fhirPatient: patient)
    }
    
    func adaptAppointment(_ appointment: [String: Any]) async -> LocalAppointment {
        await FHIRAdapter.convert(fhirAppointment: appointment)
    }
    
    func adaptObservation(_ observation: [String: Any]) async -> LocalObservationData {
        await FHIRAdapter.convert(fhirObservation: observation)
    }
} 
