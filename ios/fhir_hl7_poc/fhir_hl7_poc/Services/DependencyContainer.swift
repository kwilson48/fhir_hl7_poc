import Foundation
import SwiftUI

protocol DependencyContainerProtocol: Actor {
    var healthDataRepository: HealthDataRepositoryProtocol { get }
    var apiService: APIServiceProtocol { get }
    var fhirAdapter: FHIRAdapterProtocol { get }
    var logger: Logging { get }
}

actor DependencyContainer: DependencyContainerProtocol {
    nonisolated let healthDataRepository: HealthDataRepositoryProtocol
    nonisolated let apiService: APIServiceProtocol
    nonisolated let fhirAdapter: FHIRAdapterProtocol
    nonisolated let logger: Logging
    
    init() async {
        let concreteLogger = Logger()
        self.logger = concreteLogger
        
        self.apiService = await APIService(logger: concreteLogger)
        self.fhirAdapter = await FHIRAdapterService()
        self.healthDataRepository = await HealthDataRepository(
            adapter: fhirAdapter,
            apiService: apiService
        )
    }
    
    init(
        healthDataRepository: HealthDataRepositoryProtocol,
        apiService: APIServiceProtocol,
        fhirAdapter: FHIRAdapterProtocol,
        logger: Logging
    ) {
        self.healthDataRepository = healthDataRepository
        self.apiService = apiService
        self.fhirAdapter = fhirAdapter
        self.logger = logger
    }
}

struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: (any DependencyContainerProtocol)? = nil
}

extension EnvironmentValues {
    var container: (any DependencyContainerProtocol)? {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
} 
