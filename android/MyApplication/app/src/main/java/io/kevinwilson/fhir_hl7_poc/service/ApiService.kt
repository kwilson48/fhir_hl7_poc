package io.kevinwilson.fhir_hl7_poc.service

import retrofit2.http.GET

/**
 * Rest API service interface used to fetch data from the server
 */
interface ApiService {
    @GET("patient-example.json")
    suspend fun getPatientData(): String
    
    @GET("observation-example-heart-rate.json")
    suspend fun getHeartRate(): String
    
    @GET("appointment-example.json")
    suspend fun getNextAppointment(): String
} 