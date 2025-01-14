package io.kevinwilson.fhir_hl7_poc.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class Appointment(
    val id: String,
    val status: String,
    val description: String? = null,
    val start: String? = null,
    val end: String? = null,
    val comment: String? = null,
    @SerialName("patientInstruction")
    val patientInstructions: List<PatientInstruction> = emptyList(),
    val participant: List<Participant> = emptyList()
) {
    @Serializable
    data class PatientInstruction(
        val concept: Concept? = null
    ) {
        @Serializable
        data class Concept(
            val text: String? = null
        )
    }

    @Serializable
    data class Participant(
        val actor: Actor,
        val required: Boolean,
        val status: String,
        val type: List<Type> = emptyList()
    )

    @Serializable
    data class Actor(
        val reference: String? = null,
        val display: String? = null
    )

    @Serializable
    data class Type(
        val coding: List<Coding> = emptyList()
    )

    @Serializable
    data class Coding(
        val system: String? = null,
        val code: String? = null,
        val display: String? = null
    )

    fun isProvider(participant: Participant): Boolean {
        return participant.type.any { type ->
            type.coding.any { it.code == "ATND" }
        }
    }

    fun isLocation(participant: Participant): Boolean {
        return participant.type.isEmpty() && 
               participant.actor.reference?.startsWith("Location/") == true
    }

    fun getInstructions(): List<String> {
        return patientInstructions.mapNotNull { it.concept?.text }
    }
} 