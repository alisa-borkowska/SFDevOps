public with sharing class HDP_Doctor {
    public String street { get; set; } {
        street = '';
    }
    public String startOfCareer { get; set; } {
        startOfCareer = '';
    }
    public String speciality { get; set; } {
        speciality = '';
    }
    public String postalCode { get; set; } {
        postalCode = '';
    }
    public String phone { get; set; } {
        phone = '';
    }
    public String nationality { get; set; } {
        nationality = '';
    }
    public String name {
        set;
        get {
            return firstName + ' ' + lastName;
        }
    }
    public String licenseNumber { get; set; } {
        licenseNumber = '';
    }
    public String lastName { get; set; } {
        lastName = '';
    }
    public String firstName { get; set; } {
        firstName = '';
    }
    public String email { get; set; } {
        email = '';
    }
    public String doctorId { get; set; } {
        doctorId = '';
    }
    public String dateOfBirth { get; set; } {
        dateOfBirth = '';
    }
    public String country { get; set; } {
        country = '';
    }
    public String city { get; set; } {
        city = '';
    }

    private Id internalId;
    private Doctor__c internalDoctor;

    public HDP_Doctor() {
    }

    public HDP_Doctor(Doctor__c doctor) {
        loadDoctor(doctor);
    }

    public HDP_Doctor(Id id) {
        getDoctor(id);
    }


    public Doctor__c getDoctor_c() {
        if (internalId == null && internalDoctor == null) {
            Doctor__c doc = new Doctor__c(Id = doctorId, Name = name, First_Name__c = firstName, Last_Name__c = lastName, Email__c = email, Country__c = country, City__c = city, Street__c = street, Phone__c = phone, Nationality__c = nationality, Speciality__c = speciality, Postal_Code__c = postalCode, License_Number__c = Decimal.valueOf(licenseNumber));
            if (dateOfBirth != null) {
                doc.Date_of_Birth__c = Date.valueOf(dateOfBirth);
            }
            if (startOfCareer != null) {
                doc.Start_of_Career__c = Date.valueOf(startOfCareer);
            }
            return doc;
        } else {
            if (internalDoctor == null) {
                return [SELECT Name, First_Name__c, Last_Name__c FROM Doctor__c WHERE Id = :internalId][0];
            }
            return internalDoctor;
        }
    }
    public void getDoctor(Id doctorId) {
        loadDoctor([
                SELECT Name, First_Name__c, Last_Name__c, Id, License_Number__c, Date_of_Birth__c, Start_of_Career__c, Nationality__c, Speciality__c, Phone__c, Email__c, Street__c, Postal_Code__c, City__c, Country__c
                FROM Doctor__c
                WHERE Id = :doctorId
        ][0]);
    }

    public void loadDoctor(Doctor__c Doctor) {
        this.name = Doctor.Name;
        this.firstName = Doctor.First_Name__c;
        this.lastName = Doctor.Last_Name__c;
        this.doctorId = Doctor.Id;
        this.licenseNumber = String.valueOf(Doctor.License_Number__c);
        this.dateOfBirth = String.valueOf(Doctor.Date_of_Birth__c);
        this.startOfCareer = String.valueOf(Doctor.Start_of_Career__c);
        this.nationality = Doctor.Nationality__c;
        this.speciality = Doctor.Speciality__c;
        this.phone = Doctor.Phone__c;
        this.email = Doctor.Email__c;
        this.street = Doctor.Street__c;
        this.postalCode = Doctor.Postal_Code__c;
        this.city = Doctor.City__c;
        this.country = Doctor.Country__c;
    }

    public Doctor__c createDoctor() {
        return new Doctor__c(Name = name, First_Name__c = firstName, Last_Name__c = lastName, Id = doctorId, License_Number__c = (String.isEmpty(licenseNumber)?null:Decimal.valueOf(licenseNumber)), Date_of_Birth__c = (String.isEmpty(dateOfBirth)?null:Date.valueOf(dateOfBirth)), Start_of_Career__c = (String.isEmpty(startOfCareer)?null:Date.valueOf(startOfCareer)), Nationality__c = nationality, Speciality__c = speciality, Phone__c = phone, Email__c = email, Street__c = street, Postal_Code__c = postalCode, City__c = city, Country__c = country);
    }

    public HDP_Doctor updateDoctor(HDP_Doctor other) {
        Map<String, Object> docFields = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(this));
        Map<String, Object> newFields = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(other));

        for (String key : docFields.keySet()) {
            if (newFields.get(key) != null) {
                docFields.put(key, newFields.get(key));
            }
        }

        HDP_Doctor result = (HDP_Doctor)JSON.deserialize(JSON.serialize(docFields), HDP_Doctor.class);
        return result;
    }
}