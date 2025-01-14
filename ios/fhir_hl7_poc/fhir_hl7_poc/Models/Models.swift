import Foundation

@MainActor
final class LocalPatient: ObservableObject {
    @Published private(set) var name: [LocalHumanName]?
    @Published private(set) var gender: String?
    @Published private(set) var birthDate: String?
    @Published private(set) var telecom: [LocalContactPoint]?
    
    init(name: [LocalHumanName]? = nil, 
         gender: String? = nil, 
         birthDate: String? = nil, 
         telecom: [LocalContactPoint]? = nil) {
        self.name = name
        self.gender = gender
        self.birthDate = birthDate
        self.telecom = telecom
    }
}

struct LocalHumanName: Sendable {
    let use: String?
    let family: String?
    let given: [String]?
}

struct LocalContactPoint: Sendable {
    let system: String?
    let value: String?
    let use: String?
}

struct LocalAppointment: Sendable {
    let id: String
    let status: String
    let description: String?
    let start: String?
    let end: String?
    let patientInstructions: [String]
    let participants: [Participant]
    
    struct Participant: Sendable {
        let actor: Actor
        let required: Bool
        let status: String
        let type: [ParticipantType]
        
        struct Actor: Sendable {
            let reference: String?
            let display: String?
        }
        
        struct ParticipantType: Sendable {
            let coding: [Coding]
            
            struct Coding: Sendable {
                let system: String?
                let code: String?
            }
        }
    }
}

struct LocalObservationData: Sendable {
    let codeText: String
    let effectiveDate: String?
    let value: Int?
} 
