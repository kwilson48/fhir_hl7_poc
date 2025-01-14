package io.kevinwilson.fhir_hl7_poc

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import io.kevinwilson.fhir_hl7_poc.ui.PatientScreen
import io.kevinwilson.fhir_hl7_poc.ui.theme.MyApplicationTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MyApplicationTheme(darkTheme = false, dynamicColor = false) {
                PatientScreen()
            }
        }
    }
}