/**
 * Created by alisa.borkowska on 06.12.2022.
 */

public with sharing class HDP_DoctorProperties {
    public Boolean doctorSelected { set; get; }
    public String doctorStatus { set; get; }
    public String doctorName { set; get; }
    public String doctorID { set; get; }
    public String doctorFirstName { set; get; }
    public String doctorLastName { set; get; }
    public String doctorEmail { set; get; }
    public String doctorCountry { set; get; }
    public String emptyField { set; get; }
    public Boolean isSuccess { set; get; }

    public HDP_DoctorProperties(String doctorName, String doctorFirstName, String doctorLastName, String doctorEmail, String doctorCountry) {
        this.doctorName = doctorName;
        this.doctorFirstName = doctorFirstName;
        this.doctorLastName = doctorLastName;
        this.doctorEmail = doctorEmail;
        this.doctorCountry = doctorCountry;

        doctorSelected = false;
        doctorStatus = '';
        doctorID = '0';
        isSuccess = false;

    }

    public Boolean isAnyFieldEmpty() {

        if (doctorName == null || doctorName == '') {
            emptyField = 'Name';
        } else if (doctorFirstName == null || doctorFirstName == '' || doctorFirstName == '\r') {
            emptyField = 'First Name';
        } else if (doctorLastName == null || doctorLastName == '' || doctorLastName == '\r') {
            emptyField = 'Last Name';
        } else if (doctorEmail == null || doctorEmail == '' || doctorEmail == '\r') {
            emptyField = 'Email';
        } else if (doctorCountry == null || doctorCountry == '' || doctorCountry == '\r') {

            emptyField = 'Country';
        } else {

            return false;
        }

        return true;
    }


}