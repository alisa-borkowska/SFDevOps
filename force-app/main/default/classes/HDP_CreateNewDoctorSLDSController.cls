public class HDP_CreateNewDoctorSLDSController {
    public String name {set;get;}
    public String firstName {set;get;}
    public String lastName {set;get;}
    public String email {set;get;}
    public String country {set;get;}
    public String phone { set; get; }
    public String nationality { set; get; }
    public String startOfCareer { set; get; }
    public String speciality { set; get; }
    public String postalCode { set; get; }
    public String licenceNumber { set; get; }
    public String street { set; get; }
    public String dateOfBirth { set; get; }
    public String city { set; get; }
    public Boolean success {set;get;}

    public void createDoctorRecords() {
        success = False;
        HttpRequest req = new HttpRequest();
        String endpointString = 'callout:My_Named_Credential/services/apexrest/v1/Doctor/';
        req.setEndpoint(endpointString);
        req.setMethod('POST');
        name = firstName + ' ' + lastName;
        String JSONthis = '[' + JSON.serialize(this) + ']';
        req.setBody(JSONthis);
        req.setHeader('Content-Type', 'aplication/json');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        success = True;
    }
    public void showPopup() {
        success = true;
    }
    public void hidePopup() {
        success = false;
    }

}