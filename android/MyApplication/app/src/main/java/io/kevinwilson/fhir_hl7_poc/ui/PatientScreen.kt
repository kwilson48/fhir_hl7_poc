package io.kevinwilson.fhir_hl7_poc.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CircularProgressIndicator
import io.kevinwilson.fhir_hl7_poc.ui.theme.DarkBlue
import io.kevinwilson.fhir_hl7_poc.util.DateFormatter
import io.kevinwilson.fhir_hl7_poc.model.Appointment
import android.util.Log
import io.kevinwilson.fhir_hl7_poc.model.PatientData
import io.kevinwilson.fhir_hl7_poc.model.ObservationData
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import io.kevinwilson.fhir_hl7_poc.R

@Composable
fun PatientScreen(viewModel: PatientViewModel = hiltViewModel()) {
    val insets = WindowInsets.statusBars.asPaddingValues()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .padding(insets)
            .background(MaterialTheme.colorScheme.background)
    ) {
        val uiState = viewModel.uiState.collectAsState().value

        when (uiState) {
            is PatientViewModel.UiState.Loading -> {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator(color = MaterialTheme.colorScheme.secondary)
                }
            }
            is PatientViewModel.UiState.Success -> {
                PatientContent(data = uiState.data)
            }
            is PatientViewModel.UiState.Error -> {
                ErrorContent(
                    message = uiState.message,
                    onRetry = { viewModel.retry() }
                )
            }
        }
    }
}

@Composable
private fun PatientContent(data: PatientViewModel.PatientWithVitals) {
    Log.d("PatientScreen", """
        Rendering PatientContent:
        - Has Appointment: ${data.appointment != null}
        - Appointment Status: ${data.appointment?.status}
        - Appointment Description: ${data.appointment?.description}
    """.trimIndent())

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .verticalScroll(rememberScrollState())
            .padding(16.dp)
    ) {
        PatientInfoCard(patient = data.patient)
        Spacer(modifier = Modifier.height(16.dp))
        VitalsCard(observation = data.heartRate)
        Spacer(modifier = Modifier.height(16.dp))
        AppointmentCard(data.appointment)
        Spacer(modifier = Modifier.height(16.dp))
        ContactInfoCard(data.patient)
    }
}

@Composable
private fun CardTitle(text: String) {
    Text(
        text = text,
        style = MaterialTheme.typography.titleLarge,
        color = DarkBlue
    )
}

@Composable
private fun CardLabel(text: String) {
    Text(
        text = text,
        style = MaterialTheme.typography.bodyMedium,
        color = MaterialTheme.colorScheme.primary.copy(alpha = 0.7f)
    )
}

@Composable
private fun CardValue(text: String) {
    Text(
        text = text,
        style = MaterialTheme.typography.bodyLarge,
        color = MaterialTheme.colorScheme.onSurface
    )
}

@Composable
private fun PatientInfoCard(patient: PatientData) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            CardTitle(stringResource(R.string.title_patient_information))
            Spacer(modifier = Modifier.height(8.dp))
            
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                CardLabel(stringResource(R.string.label_name))
                CardValue(patient.fullName)
                
                Spacer(modifier = Modifier.height(4.dp))
                CardLabel(stringResource(R.string.label_gender))
                CardValue(patient.gender)
                
                Spacer(modifier = Modifier.height(4.dp))
                CardLabel(stringResource(R.string.label_birth_date))
                CardValue(DateFormatter.formatDate(patient.birthDate))
            }
        }
    }
}

@Composable
private fun ContactInfoCard(patient: PatientData) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            CardTitle(stringResource(R.string.title_contact_information))
            Spacer(modifier = Modifier.height(8.dp))
            
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                patient.telecoms
                    .filter { telecom ->
                        telecom.system == "phone" && telecom.use != "old"
                    }
                    .forEach { telecom ->
                        val useDisplay = when(telecom.use) {
                            "home" -> "Home"
                            "work" -> "Work"
                            "mobile" -> "Mobile"
                            "temp" -> "Temporary"
                            else -> stringResource(R.string.label_primary_phone)
                        }
                        CardLabel(useDisplay)
                        CardValue(telecom.value ?: "")
                    }
            }
        }
    }
}

@Composable
private fun VitalsCard(observation: ObservationData?) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            CardTitle(stringResource(R.string.title_vital_signs))
            Spacer(modifier = Modifier.height(8.dp))
            
            if (observation != null) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.Top
                ) {
                    Column {
                        Text(
                            text = observation.codeText,
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.secondary
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        CardLabel(stringResource(R.string.label_measured_on))
                        CardValue(DateFormatter.formatDateTime(observation.effectiveDate))
                    }
                    Text(
                        text = stringResource(
                            R.string.unit_heart_rate,
                            observation.value ?: 0
                        ),
                        style = MaterialTheme.typography.titleLarge,
                        color = MaterialTheme.colorScheme.tertiary
                    )
                }
            } else {
                Text(
                    text = stringResource(R.string.message_no_vitals),
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )
            }
        }
    }
}

@Composable
private fun AppointmentCard(appointment: Appointment?) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            CardTitle(stringResource(R.string.title_next_appointment))
            Spacer(modifier = Modifier.height(8.dp))
            
            if (appointment != null && appointment.status != "cancelled") {
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    // Description
                    if (!appointment.description.isNullOrEmpty()) {
                        CardLabel(stringResource(R.string.label_description))
                        CardValue(appointment.description)
                    }
                    
                    // Date and Time
                    if (!appointment.start.isNullOrEmpty()) {
                        Spacer(modifier = Modifier.height(4.dp))
                        CardLabel(stringResource(R.string.label_date))
                        CardValue(DateFormatter.formatDateTime(appointment.start))
                    }
                    
                    // Provider (ATND participant)
                    appointment.participant
                        .find { appointment.isProvider(it) }
                        ?.let { provider ->
                            Spacer(modifier = Modifier.height(4.dp))
                            CardLabel(stringResource(R.string.label_provider))
                            CardValue(provider.actor.display ?: "")
                        }
                    
                    // Location
                    appointment.participant
                        .find { appointment.isLocation(it) }
                        ?.let { location ->
                            Spacer(modifier = Modifier.height(4.dp))
                            CardLabel(stringResource(R.string.label_location))
                            CardValue(location.actor.display ?: "")
                        }
                    
                    // Patient Instructions
                    if (appointment.getInstructions().isNotEmpty()) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = stringResource(R.string.label_instructions),
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.primary
                        )
                        appointment.getInstructions().forEach { instruction ->
                            Text(
                                text = "• $instruction",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                            )
                        }
                    }

                    // Notes
                    if (!appointment.comment.isNullOrEmpty()) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = stringResource(R.string.label_notes),
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.primary
                        )
                        Text(
                            text = "• ${appointment.comment}",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                        )
                    }
                }
            } else {
                Text(
                    text = stringResource(R.string.message_no_appointments),
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )
            }
        }
    }
}

@Composable
private fun ErrorContent(message: String, onRetry: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = message,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onBackground
        )
        Spacer(modifier = Modifier.height(16.dp))
        Button(
            onClick = onRetry,
            colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.secondary,
                contentColor = MaterialTheme.colorScheme.onSecondary
            )
        ) {
            Text(stringResource(R.string.message_retry))
        }
    }
}

@Preview(showBackground = true)
@Composable
fun DefaultPreview() {
    PatientScreen()
} 