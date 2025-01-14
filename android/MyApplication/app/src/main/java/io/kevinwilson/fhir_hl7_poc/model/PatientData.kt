package io.kevinwilson.fhir_hl7_poc.model

data class Telecom(
    val system: String?,
    val value: String?,
    val use: String?
)

data class PatientData(
    val fullName: String,
    val gender: String,
    val birthDate: java.time.LocalDate?,
    val telecoms: List<Telecom> = emptyList()
)

data class ObservationData(
    val codeText: String,
    val effectiveDate: java.time.LocalDateTime?,
    val value: Int?
) 