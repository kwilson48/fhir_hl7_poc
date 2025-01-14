enum FHIRConversionError: Error {
    case invalidData(String)
    case missingRequiredField(String)
    case conversionFailed(String)
} 