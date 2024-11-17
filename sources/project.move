module MedicalRecordManagement::MedicalRecords {
    use aptos_framework::signer;
    use std::string::String;
    use std::vector;

    /// Struct representing a medical record
    struct MedicalRecord has key, store {
        patient_address: address,
        record_data: String,
        authorized_doctors: vector<address>,
        is_active: bool
    }

    /// Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_RECORD_NOT_FOUND: u64 = 2;
    const E_ALREADY_HAS_RECORD: u64 = 3;

    /// Function to create a new medical record
    /// Only the patient can create their own record
    public fun create_medical_record(
        patient: &signer,
        initial_data: String,
    ) {
        let patient_addr = signer::address_of(patient);
        
        // Create new record
        let record = MedicalRecord {
            patient_address: patient_addr,
            record_data: initial_data,
            authorized_doctors: vector::empty<address>(),
            is_active: true
        };

        // Move the record to patient's account
        move_to(patient, record);
    }

    /// Function to update record access control
    /// Only the patient can authorize/unauthorize doctors
    public fun manage_doctor_access(
        patient: &signer,
        doctor_address: address,
        grant_access: bool
    ) acquires MedicalRecord {
        let patient_addr = signer::address_of(patient);
        let record = borrow_global_mut<MedicalRecord>(patient_addr);

        if (grant_access) {
            if (!vector::contains(&record.authorized_doctors, &doctor_address)) {
                vector::push_back(&mut record.authorized_doctors, doctor_address);
            }
        } else {
            let (is_present, index) = vector::index_of(&record.authorized_doctors, &doctor_address);
            if (is_present) {
                vector::remove(&mut record.authorized_doctors, index);
            }
        };
    }
}