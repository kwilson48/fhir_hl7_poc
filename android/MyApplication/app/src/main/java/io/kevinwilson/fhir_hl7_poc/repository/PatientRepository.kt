package io.kevinwilson.fhir_hl7_poc.repository

import ca.uhn.fhir.parser.IParser
import io.kevinwilson.fhir_hl7_poc.service.ApiService
import org.hl7.fhir.r4.model.Patient
import org.hl7.fhir.r4.model.Observation
import io.kevinwilson.fhir_hl7_poc.model.Appointment
import javax.inject.Inject
import javax.inject.Singleton
import ca.uhn.fhir.context.FhirContext
import kotlinx.serialization.json.Json
import io.kevinwilson.fhir_hl7_poc.model.PatientData
import io.kevinwilson.fhir_hl7_poc.model.ObservationData
import io.kevinwilson.fhir_hl7_poc.model.Telecom
import java.time.ZoneId

@Singleton
class PatientRepository @Inject constructor(
    private val apiService: ApiService
) {
    private val json = Json { 
        ignoreUnknownKeys = true 
        coerceInputValues = true
    }
    private val fhirContext: FhirContext = FhirContext.forR4()
    private val parser: IParser = fhirContext.newJsonParser()

    suspend fun getPatient(): PatientData {
        val response = apiService.getPatientData()
        val patientHapi = parser.parseResource(Patient::class.java, response)

        val fullName = "${patientHapi.nameFirstRep?.given?.firstOrNull()?.value} ${patientHapi.nameFirstRep?.family}"
        val gender = patientHapi.gender?.display ?: "Unknown"
        
        val birthDate = patientHapi.birthDate
            ?.toInstant()
            ?.atZone(ZoneId.systemDefault())
            ?.toLocalDate()

        val domainTelecoms = patientHapi.telecom.map { telecom ->
            Telecom(
                system = telecom.system?.toCode(),
                value = telecom.value,
                use = telecom.use?.toCode()
            )
        }

        return PatientData(
            fullName = fullName.trim(),
            gender = gender,
            birthDate = birthDate,
            telecoms = domainTelecoms
        )
    }

    suspend fun getHeartRate(): ObservationData? {
        val response = apiService.getHeartRate()
        val observationHapi = parser.parseResource(Observation::class.java, response)

        val effectiveDate = (observationHapi.effective as? org.hl7.fhir.r4.model.DateTimeType)
            ?.value
            ?.toInstant()
            ?.atZone(ZoneId.systemDefault())
            ?.toLocalDateTime()

        return ObservationData(
            codeText = observationHapi.code?.text ?: "Unknown",
            effectiveDate = effectiveDate,
            value = observationHapi.valueQuantity?.value?.toInt()
        )
    }

    suspend fun getAppointment(): Appointment? {
        val response = apiService.getNextAppointment()
        return json.decodeFromString<Appointment>(response)
    }
} 