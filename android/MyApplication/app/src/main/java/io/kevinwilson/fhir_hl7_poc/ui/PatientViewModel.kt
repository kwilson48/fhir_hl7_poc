package io.kevinwilson.fhir_hl7_poc.ui

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import io.kevinwilson.fhir_hl7_poc.repository.PatientRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import io.kevinwilson.fhir_hl7_poc.model.PatientData
import io.kevinwilson.fhir_hl7_poc.model.ObservationData
import io.kevinwilson.fhir_hl7_poc.model.Appointment
import javax.inject.Inject
import kotlinx.coroutines.async

@HiltViewModel
class PatientViewModel @Inject constructor(
    private val repository: PatientRepository
) : ViewModel() {

    data class PatientWithVitals(
        val patient: PatientData,
        val heartRate: ObservationData? = null,
        val appointment: Appointment? = null
    )

    sealed class UiState {
        object Loading : UiState()
        data class Success(val data: PatientWithVitals) : UiState()
        data class Error(val message: String) : UiState()
    }

    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState

    init {
        fetchPatientData()
    }

    private fun fetchPatientData() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            try {
                val patientDomain = repository.getPatient()

                val heartRateDeferred = async { repository.getHeartRate() }
                val appointmentDeferred = async { repository.getAppointment() }

                val heartRateDomain = try {
                    heartRateDeferred.await()
                } catch (e: Exception) {
                    Log.e("PatientViewModel", "Failed to fetch heart rate", e)
                    null
                }

                val appointment = try {
                    appointmentDeferred.await()
                } catch (e: Exception) {
                    Log.e("PatientViewModel", "Failed to fetch appointment", e)
                    null
                }

                _uiState.value = UiState.Success(
                    PatientWithVitals(
                        patient = patientDomain,
                        heartRate = heartRateDomain,
                        appointment = appointment
                    )
                )
            } catch (e: Exception) {
                Log.e("PatientViewModel", "Failed to fetch patient data", e)
                _uiState.value = UiState.Error(e.message ?: "Unknown error occurred")
            }
        }
    }

    fun retry() {
        fetchPatientData()
    }
} 