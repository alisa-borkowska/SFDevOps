public with sharing class HDP_HospitalSearchController {

    public HDP_Hospital searchFields { get; set; } {
        searchFields = new HDP_Hospital();
    }
    public HDP_Hospital ext { get; set; } {
    }
    public List<HDP_Hospital> hospitalsList { get; set; }
    public Boolean isEmpty { get; set; }
    public Boolean isCleared { get; set; } {
        isCleared = true;
    }

    public List<HDP_Hospital> pagedHospitalsList { get; set; }
    public Integer pageNumber { get; set; }
    public Integer resultSize { get; set; }
    public integer pageSize { get; set; } {
        pageSize = 20;
    }
    public Boolean hasPrevious { get; set; }
    public Boolean hasNext { get; set; }

    public String idToDelete { get; set; }
    public String idToEdit { get; set; }
    public Boolean promptBeforeDelete { get; set; }
    public Boolean promptBeforeEdit { get; set; }
    public Boolean promptBeforeCreate { get; set; }
    public Boolean promptErrorHandling { get; set; }
    public String respond { get; set; }


    public HDP_ExternalSoapWSDL.HA_HospitalSoapController initSOAPRequest() {
        HDP_WSDL.Soap obj = new HDP_WSDL.Soap();
        Map<String, CredentialsAlisa__c> log = CredentialsAlisa__c.getAll();
        CredentialsAlisa__c data = CredentialsAlisa__c.getValues('Alisa');
        String login = data==null ? 'test' : data.Login__c;
        String password = data==null ? 'test' : data.Password__c;
        HDP_WSDL.LoginResult loginResult = obj.login(login, password);
        HDP_ExternalSoapWSDL.HA_HospitalSoapController hospWSDLController = new HDP_ExternalSoapWSDL.HA_HospitalSoapController();
        HDP_ExternalSoapWSDL.SessionHeader_element sessionHeader = new HDP_ExternalSoapWSDL.SessionHeader_element();
        sessionHeader.sessionId = loginResult.sessionId;
        hospWSDLController.SessionHeader = sessionHeader;
        return hospWSDLController;
    }
    public void clearExt() {
        ext = new HDP_Hospital();
    }

    public void searchHospitalsRecords() {
        isCleared = false;

        HDP_ExternalSoapWSDL.HA_HospitalSoapController hospWSDLController = initSOAPRequest();
        isCleared = false;
        hospitalsList = new List<HDP_Hospital>();

        List<HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper> result = hospWSDLController.getHospitals(encodeSearchParams(searchFields.name), searchFields.city);
        if (result == null) {
            resultSize = 0;
            isEmpty = true;
            return;
        }
        respond = result.size()>0 ? result[0].message : '';
        isEmpty = false;
        for (HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper hsp : result) {
            hospitalsList.add(HDP_Hospital.fromExternalWrapper(hsp));
        }
        if (hospitalsList.size() == 0) {
            isEmpty = true;
            resultSize = 0;
        } else {
            isEmpty = false;
        }
        resultSize = hospitalsList.size();
        pageNumber = 0;

        reloadPagedHospitals();
    }

    public void deleteHospital(String Id) {
        HDP_ExternalSoapWSDL.HA_HospitalSoapController hospWSDLController = initSOAPRequest();
        HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper result = hospWSDLController.deleteHospitalById(Id);
        respond = result.message;
    }
    public void editHospital() {
        HDP_ExternalSoapWSDL.HA_HospitalSoapController hospWSDLController = initSOAPRequest();
        promptBeforeEdit = false;
        HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper result = hospWSDLController.updateHospitalById(HDP_Hospital.toExternalWrapper(ext));
        respond = result.message;
        if (!String.isEmpty(result.message)) {
            promptBeforeEdit = true;
            showErrorPopup();
        }
        for (HDP_Hospital hsp : hospitalsList)
        {
            if (hsp.id == ext.id) {
                hsp = HDP_Hospital.updateHospital(hsp,ext);
            }
        }
        reloadPagedHospitals();
    }

    public void showPopup() {
        idToDelete = ApexPages.currentPage().getParameters().get('idToDelete');
        promptBeforeDelete = true;
    }
    public void hidePopup() {
        promptBeforeDelete = false;
        clearExt();
    }
    public void createHospitalRecords() {
        HDP_ExternalSoapWSDL.HA_HospitalSoapController hospWSDLController = initSOAPRequest();
        HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper hospital = new HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper();
        hospital = HDP_Hospital.toExternalWrapper(ext);
        hospital.name = hospital.name==null ? '' : encodeSearchParams(hospital.name);
        HDP_ExternalSoapWSDL.HA_HospitalObjectWrapper result = hospWSDLController.createHospital(hospital);
        respond = result.message;
        hospitalsList = hospitalsList==null ? new List<HDP_Hospital>() : hospitalsList;
        if (String.isEmpty(result.message)) {
            promptBeforeCreate = false;
            hospitalsList.add(ext);
        } else {
            showErrorPopup();
        }
        reloadPagedHospitals();
    }
    public void showCreatePopup() {
        clearExt();
        promptBeforeCreate = true;
    }
    public void hideCreatePopup() {
        promptBeforeCreate = false;
    }

    public void showEditPopup() {
        idToEdit = ApexPages.currentPage().getParameters().get('idToEdit');
        for (HDP_Hospital hsp : hospitalsList) {
            if (hsp.id == idToEdit) {
                ext=hsp.Clone();
                promptBeforeEdit = true;
            }
        }
    }
    public void hideEditPopup() {
        promptBeforeEdit = false;
        clearExt();
    }
    public void deleteHospitalFromParams() {
        deleteHospital(idToDelete);
        promptBeforeDelete = false;
        Integer index = 0;
        for (HDP_Hospital hsp : hospitalsList ?.clone()) {
            if (hsp.id == idToDelete) {
                hospitalsList.remove(index);
                reloadPagedHospitals();
                return;
            }
            index++;
        }
    }
    public void clearHospitalsRecords() {
        hospitalsList = new List<HDP_Hospital>();
        searchFields = new HDP_Hospital();
        isCleared = true;
    }

    public void reloadPagedHospitals() {
        if (pageSize == null) {
            pageSize = 2;
        }
        if (pageNumber == null) {
            pageNumber = 0;
        }
        if (hospitalsList == null) {
            hospitalsList = new List<HDP_Hospital>();
        }
        resultSize = hospitalsList.size();
        pagedHospitalsList = new List<HDP_Hospital>();
        for (Integer i = pageSize * pageNumber; i < (pageNumber + 1) * pageSize; i++) {
            if (i < resultSize)
                pagedHospitalsList.add(hospitalsList[i]);
        }
        if (pageSize * (pageNumber + 1) < resultSize) {
            hasNext = true;
        } else {
            hasNext = false;
        }
        if (pageNumber <= 0) {
            hasPrevious = false;
        } else {
            hasPrevious = true;
        }
    }

    public void previous() {
        pageNumber -= hasPrevious ? 1 : 0;
        reloadPagedHospitals();
    }
    public void next() {
        pageNumber += hasNext ? 1 : 0;
        reloadPagedHospitals();
    }
    public void first() {
        pageNumber = 0;
        reloadPagedHospitals();
    }
    public void last() {
        pageNumber = (resultSize / pageSize);
        reloadPagedHospitals();
    }

    public void showErrorPopup() {
        promptErrorHandling = true;
    }
    public void hideErrorPopup() {
        promptErrorHandling = false;
        respond = null;
    }
    private static String encodeSearchParams(String request) { return EncodingUtil.urlEncode(request, 'UTF-8'); }

}