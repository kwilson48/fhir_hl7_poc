import Foundation

@MainActor
struct FHIRAdapter {
    static func convert(fhirPatient: [String: Any]) -> LocalPatient {
        let namesArray = fhirPatient["name"] as? [[String: Any]] ?? []
        let names = namesArray.compactMap { nameDict -> LocalHumanName? in
            let use = nameDict["use"] as? String
            let family = nameDict["family"] as? String
            let given = nameDict["given"] as? [String]
            
            return LocalHumanName(
                use: use,
                family: family,
                given: given
            )
        }
        
        let telecomArray = fhirPatient["telecom"] as? [[String: Any]] ?? []
        let telecom = telecomArray.compactMap { contactDict -> LocalContactPoint? in
            let use = contactDict["use"] as? String
            if use == "old" { return nil }
            
            let system = contactDict["system"] as? String
            let value = contactDict["value"] as? String
            
            return LocalContactPoint(
                system: system,
                value: value,
                use: use
            )
        }
        
        return LocalPatient(
            name: names,
            gender: fhirPatient["gender"] as? String,
            birthDate: fhirPatient["birthDate"] as? String,
            telecom: telecom
        )
    }
    
    static func convert(fhirAppointment: [String: Any]) -> LocalAppointment {
        let logger = Logger()
        logger.log("Converting Appointment: \(fhirAppointment)", level: .debug)
        
        let id = fhirAppointment["id"] as? String ?? ""
        let status = fhirAppointment["status"] as? String ?? ""
        let description = fhirAppointment["description"] as? String
        let start = fhirAppointment["start"] as? String
        let end = fhirAppointment["end"] as? String
        
        var instructions: [String] = []
        
        if let instructionArray = fhirAppointment["patientInstruction"] as? [[String: Any]] {
            instructions = instructionArray.compactMap { instruction in
                if let concept = instruction["concept"] as? [String: Any],
                   let text = concept["text"] as? String {
                    return text
                }
                return nil
            }
        }
        else if let singleInstruction = fhirAppointment["patientInstruction"] as? String {
            instructions = [singleInstruction]
        } else if let instructionsArray = fhirAppointment["patientInstructions"] as? [String] {
            instructions = instructionsArray
        }
        
        logger.log("Final instructions: \(instructions)", level: .debug)
        
        let participantsArray = fhirAppointment["participant"] as? [[String: Any]] ?? []
        let participants = participantsArray.map { participantDict -> LocalAppointment.Participant in
            let actorDict = participantDict["actor"] as? [String: Any] ?? [:]
            let actor = LocalAppointment.Participant.Actor(
                reference: actorDict["reference"] as? String,
                display: actorDict["display"] as? String
            )
            
            let required = participantDict["required"] as? Bool ?? false
            let status = participantDict["status"] as? String ?? ""
            
            let typeArray = participantDict["type"] as? [[String: Any]] ?? []
            let types = typeArray.map { typeDict -> LocalAppointment.Participant.ParticipantType in
                let codingArray = typeDict["coding"] as? [[String: Any]] ?? []
                let codings = codingArray.map { codingDict -> LocalAppointment.Participant.ParticipantType.Coding in
                    LocalAppointment.Participant.ParticipantType.Coding(
                        system: codingDict["system"] as? String,
                        code: codingDict["code"] as? String
                    )
                }
                return LocalAppointment.Participant.ParticipantType(coding: codings)
            }
            
            return LocalAppointment.Participant(
                actor: actor,
                required: required,
                status: status,
                type: types
            )
        }
        
        return LocalAppointment(
            id: id,
            status: status,
            description: description,
            start: start,
            end: end,
            patientInstructions: instructions,
            participants: participants
        )
    }
    
    static func convert(fhirObservation: [String: Any]) -> LocalObservationData {
        let codeDict = fhirObservation["code"] as? [String: Any] ?? [:]
        let codeText = codeDict["text"] as? String ?? "Unknown"
        
        let effectiveDate = fhirObservation["effectiveDateTime"] as? String
        
        let valueQuantity = fhirObservation["valueQuantity"] as? [String: Any]
        let value = valueQuantity?["value"] as? Int
        
        return LocalObservationData(
            codeText: codeText,
            effectiveDate: effectiveDate,
            value: value
        )
    }
}
