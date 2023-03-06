/**
 * Created by alisa.borkowska on 05.12.2022.
 */

public with sharing class HDP_ImportDoctorsController {
    public String filename { get; set; }
    public Blob fileContent { get; set; }
    public String[] fileLines = new String[]{
    };
    public List<HDP_DoctorProperties> uploadedDoctors { get; set; } {
        uploadedDoctors = new List<HDP_DoctorProperties>();
    }
    public Boolean doctorExist { get; set; }
    public String errorString { get; set; }

    public pageReference ReadFile() {
        filename = fileContent.toString();
        fileLines = filename.split('\n');
        if (!isCSVValid(fileLines)) {
            return null;
        }

        for (Integer i = 1; i < fileLines.size(); i++) {
            String[] inputValues = new String[]{
            };
            inputValues = fileLines[i].split(',');

            HDP_DoctorProperties a = new HDP_DoctorProperties(inputValues[0] + ' ' + inputValues[1], inputValues[0], inputValues[1], inputValues[2], inputValues[3]);

            uploadedDoctors.add(a);

        }
        return null;
    }

    public Boolean isCSVValid(String[] lines) {
        String[] headers = lines.remove(0).split(',');
        Integer colSpan = headers.size();
        if (colSpan != 4) {
            errorString = 'Error zła ilość headerów';
            return false;
        }
        if (!(headers[0].deleteWhitespace() == 'FirstName' &&
                headers[1].deleteWhitespace() == 'LastName' &&
                headers[2].deleteWhitespace() == 'Email' &&
                headers[3].deleteWhitespace() == 'Country')) {
            errorString = 'Error złe headery';
            return false;
        }
        for (String line : lines) {
            if (line.split(',').size() != colSpan) {
                errorString = 'Error zła ilość wartości w doktorze: ' + line.split(',')[0] + ' ' + line.split(',')[1];
                return false;
            }
        }
        errorString = 'Success';
        return true;
    }

    public void uploadDoctors() {
        for (HDP_DoctorProperties importedDoctor : uploadedDoctors) {
            if (importedDoctor.doctorSelected) {
                if (importedDoctor.isAnyFieldEmpty()) {
                    importedDoctor.doctorStatus = System.Label.Required_Field_Missing + ' ' + importedDoctor.emptyField;

                } else {
                    try {

                        Doctor__c doctor = new Doctor__c();
                        doctor.Name = importedDoctor.doctorName;
                        doctor.First_Name__c = importedDoctor.doctorFirstName;
                        doctor.Last_Name__c = importedDoctor.doctorLastName;
                        doctor.Email__c = importedDoctor.doctorEmail;
                        doctor.Country__c = importedDoctor.doctorCountry;

                        insert doctor;
                        doctorExist = true;

                        importedDoctor.doctorID = doctor.ID;
                        importedDoctor.doctorStatus = System.Label.Success + ' ';
                        importedDoctor.isSuccess = true;

                    } catch (Exception e) {
                        ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Unknown_Error);
                        ApexPages.addMessage(errorMessage);
                    }
                }
            }
        }
    }

    public void clearDoctorRecords() {
        uploadedDoctors = new List<HDP_DoctorProperties>();
    }

    public Boolean getIsCleared() {
        if (uploadedDoctors.isEmpty())
            return true; else {
            return false;
        }
    }

    public void selectAll() {
        for (HDP_DoctorProperties doc : uploadedDoctors) {
            doc.doctorSelected = true;
        }
    }

    public void selectNone() {
        for (HDP_DoctorProperties doc : uploadedDoctors) {
            doc.doctorSelected = false;
        }
    }

    public void reverseSelected() {
        for (HDP_DoctorProperties doc : uploadedDoctors) {
            doc.doctorSelected = !doc.doctorSelected;
        }
    }
}