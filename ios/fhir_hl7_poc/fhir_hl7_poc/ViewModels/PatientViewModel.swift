import Foundation
import SwiftUI

@MainActor
class PatientViewModel: ObservableObject {
    private var repository: HealthDataRepositoryProtocol?
    private var logger: Logging?
    
    @Published private(set) var patient: LocalPatient?
    @Published private(set) var appointment: LocalAppointment?
    @Published private(set) var heartRate: LocalObservationData?
    @Published private(set) var error: Error?
    @Published private(set) var isLoading = false
    
    init() {}
    
    func configure(repository: HealthDataRepositoryProtocol, logger: Logging) async {
        self.repository = repository
        self.logger = logger
    }
    
    func fetchHealthData() async {
        guard let repository = repository, let logger = logger else {
            self.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewModel not properly configured"])
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let patientData = repository.getPatient()
            async let appointmentData = repository.getAppointment()
            async let heartRateData = repository.getHeartRate()
            
            let (fetchedPatient, fetchedAppointment, fetchedHeartRate) = try await (
                patientData,
                appointmentData,
                heartRateData
            )
            
            patient = fetchedPatient
            appointment = fetchedAppointment
            heartRate = fetchedHeartRate
            
            logger.log("Health data fetched successfully", level: LogLevel.info)
        } catch {
            self.error = error
            logger.log("Failed to fetch health data: \(error.localizedDescription)", level: LogLevel.error)
        }
    }
    
    func getFormattedName() -> String {
        guard let names = patient?.name?.first,
              let given = names.given?.first,
              let family = names.family else {
            return "Unknown"
        }
        return "\(given) \(family)"
    }
    
    func getPhoneNumbers() -> [String] {
        patient?.telecom?
            .filter { $0.system == "phone" }
            .compactMap { $0.value } ?? []
    }
} 
