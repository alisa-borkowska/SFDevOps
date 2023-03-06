public with sharing class HDP_SearchSLDSController {
    public HDP_Doctor searchFields { get; set; } {
        searchFields = new HDP_Doctor(); //todo Mary Jane
    }
    public HDP_Doctor ext { get; set; } {
    }
    public List<HDP_Doctor> doctorsList { get; set; }
    public Boolean isEmpty { get; set; }
    public Boolean isCleared { get; set; } {
        isCleared = true;
    }
    public List<HDP_Doctor> pagedDoctorsList { get; set; }
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


    public HTTPResponse sendAPIRequest(String url, String method, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        if (!String.isEmpty(body)) {
            req.setBody(body);
            req.setHeader('Content-Type', 'aplication/json');
        }
        Http http = new Http();
        HTTPResponse res = http.send(req);
        try {
            Map<String, Object> resBody = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            respond = String.valueOf(resBody.get('message'));
        }
        catch(Exception e){}
        return res;
    }
    public HTTPResponse sendAPIRequest(String url, String method) {
        return sendAPIRequest(url, method, '');
    }
    public void clearExt() {
        ext = new HDP_Doctor();
    }

    public void searchDoctorRecords() {
        isCleared = false;
        searchFields.firstName = encodeSearchParams(searchFields.firstName);
        searchFields.country = searchFields.country == null ? '' : searchFields.country;
        String endpointString = 'callout:My_Named_Credential/services/apexrest/v1/Doctor?' +
                (String.isEmpty(searchFields.firstName) ? '' : 'firstName=' + searchFields.firstName + '&') +
                (String.isEmpty(searchFields.lastName) ? '' : 'lastName=' + searchFields.lastName + '&') +
                (String.isEmpty(searchFields.email) ? '' : 'email=' + searchFields.email + '&') +
                (String.isEmpty(searchFields.country) ? '' : 'country=' + searchFields.country + '&');
        HTTPResponse res = sendAPIRequest(endpointString, 'GET');
        try {
            doctorsList = (List<HDP_Doctor>) JSON.deserialize(res.getBody(), List<HDP_Doctor>.class);
        } catch (System.JSONException e) {
            isEmpty = true;
            resultSize = 0;
            return;
        }
        if (doctorsList.size() == 0) {
            isEmpty = true;
            resultSize = 0;
        } else {
            isEmpty = false;
        }

        resultSize = doctorsList.size();
        if (pageNumber == null) {
            pageNumber = 0;
        }
        reloadPagedDoctors();
    }

    public void deleteDoctor(String Id) {
        String endpointString = 'callout:My_Named_Credential/services/apexrest/v1/Doctor/' + Id;
        sendAPIRequest(endpointString, 'DELETE');
    }
    public void editDoctor(String Id, String body) {
        String endpointString = 'callout:My_Named_Credential/services/apexrest/v1/Doctor/' + Id;
        sendAPIRequest(endpointString, 'PATCH', body);
    }

    public void editDoctorFromParams() {
        String body = JSON.serialize(ext);
        editDoctor(ext.doctorId, body);
        searchDoctorRecords();
        if (String.isEmpty(respond)) {
            promptBeforeEdit = false;
        }
        else {
            showErrorPopup();
        }
    }
    public void showPopup() {
        idToDelete = ApexPages.currentPage().getParameters().get('idToDelete');
        promptBeforeDelete = true;
    }
    public void hidePopup() {
        promptBeforeDelete = false;
        clearExt();
    }
    public void createDoctorRecords() {
        String endpointString = 'callout:My_Named_Credential/services/apexrest/v1/Doctor/';
        ext.doctorId = null;
        String body = '[' + JSON.serialize(ext) + ']';
        sendAPIRequest(endpointString, 'POST', body);
        searchDoctorRecords();
        if (String.isEmpty(respond)) {
            promptBeforeCreate = false;
        }
        else {
            showErrorPopup();
        }
    }
    public void showCreatePopup() {
        clearExt();
        promptBeforeCreate = true;
    }
    public void hideCreatePopup() {
        promptBeforeCreate = false;
    }

    public void showEditPopup() {
        promptBeforeEdit = true;
        idToEdit = ApexPages.currentPage().getParameters().get('idToEdit');
        for (HDP_Doctor doc : doctorsList) {
            if (doc.doctorId == idToEdit) {
                ext = doc;
                break;
            }
        }
    }
    public void hideEditPopup() {
        promptBeforeEdit = false;
        clearExt();
    }
    public void deleteDoctorFromParams() {
        deleteDoctor(idToDelete);
        promptBeforeDelete = false;
        Integer index = 0;
        for (HDP_Doctor doc : doctorsList ?.clone()) {
            if (doc.doctorId == idToDelete) {
                doctorsList.remove(index);
                reloadPagedDoctors();
                return;
            }
            index++;
        }
    }
    public void clearDoctorRecords() {
        doctorsList = new List<HDP_Doctor>();
        searchFields = new HDP_Doctor();
        isCleared = true;
    }

    public List<SelectOption> getCountryOptions() {
        List<SelectOption> options = new List<SelectOption>();

        List<HDP_Doctor> prevDoctors = doctorsList ?.clone();
        List<HDP_Doctor> prevPagedDoctors = pagedDoctorsList ?.clone();

        searchDoctorRecords();
        if (doctorsList == null) {
            return new List<SelectOption>();
        }
        List<HDP_Doctor> docList = doctorsList ?.clone();
        doctorsList = prevDoctors;
        pagedDoctorsList = prevPagedDoctors;

        List<String> uniqueValues = new List<String>();
        for (HDP_Doctor doc : docList) {
            if (uniqueValues.contains(doc.country)) {
                continue;
            } else if (doc.country == null) {
                continue;
            }
            uniqueValues.add(doc.country);
            options.add(new SelectOption(doc.country, doc.country));

        }
        options.add(new SelectOption('', 'Any'));
        return options;
    }


    public void reloadPagedDoctors() {
        if (pageSize == null) {
            pageSize = 2;
        }
        if (pageNumber == null) {
            pageNumber = 0;
        }
        if (doctorsList == null) {
            doctorsList = new List<HDP_Doctor>();
        }
        resultSize = doctorsList.size();
        pagedDoctorsList = new List<HDP_Doctor>();
        for (Integer i = pageSize * pageNumber; i < (pageNumber + 1) * pageSize; i++) {
            if (i < resultSize)
                pagedDoctorsList.add(doctorsList[i]);
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
        if (hasPrevious) pageNumber -= 1;
        reloadPagedDoctors();
    }
    public void next() {
        if (hasNext) pageNumber += 1;
        reloadPagedDoctors();
    }
    public void first() {
        pageNumber = 0;
        reloadPagedDoctors();
    }
    public void last() {
        pageNumber = (resultSize / pageSize);
        pageNumber = pageNumber>=0 ? pageNumber : 0;
        reloadPagedDoctors();
    }

    public PageReference exportCSV() {
        Document document = new Document();

        document.name = 'doctors.csv';
        String fileContent;
        fileContent = 'Full Name,Email,License Number,Full Address' + '\n';
        for (HDP_Doctor doc : doctorsList) {
            fileContent += String.format('"{0}","{1}","{2}","{3}"\n', new List<Object>{
                    doc.name, doc.email, doc.licenseNumber, doc.street + ',' + doc.city + ',' + doc.country
            });
        }
        document.body = blob.valueof(fileContent);
        document.folderId = UserInfo.getUserId();
        insert document;

        PageReference pageRef = new PageReference('/servlet/servlet.FileDownload?file=' + document.Id);
        pageRef.setRedirect(true);
        pageRef.setRedirectCode(301);
        return pageRef;
    }

    public PageReference exportXLS() {
        Document document = new Document();

        document.name = 'doctors.xls';
        String fileContent;
        fileContent = '<?xml version="1.0"?>\n<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"\nxmlns:o="urn:schemas-microsoft-com:office:office"\nxmlns:x="urn:schemas-microsoft-com:office:excel"\nxmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"\nxmlns:html="http://www.w3.org/TR/REC-html40">\n<Worksheet ss:Name="Sheet1">\n<Table ss:ExpandedColumnCount="2" ss:ExpandedRowCount="2" x:FullColumns="1" x:FullRows="1">';
        fileContent += '<Row><Cell><Data ss:Type="String">Full Name</Data></Cell><Cell><Data ss:Type="String">Email</Data></Cell><Cell><Data ss:Type="String">License Number</Data></Cell><Cell><Data ss:Type="String">Full Address</Data></Cell></Row>\n';
        for (HDP_Doctor doc : doctorsList) {
            fileContent += String.format('<Row><Cell><Data ss:Type="String">{0}</Data></Cell><Cell><Data ss:Type="String">{1}</Data></Cell><Cell><Data ss:Type="String">{2}</Data></Cell><Cell><Data ss:Type="String">{3}</Data></Cell></Row>\n', new List<Object>{
                    doc.name, doc.email, doc.licenseNumber, doc.street + ',' + doc.city + ',' + doc.country
            });
        }
        fileContent += '  </Table></Worksheet></Workbook>';
        document.body = blob.valueof(fileContent);
        document.folderId = UserInfo.getUserId();
        insert document;

        PageReference pageRef = new PageReference('/servlet/servlet.FileDownload?file=' + document.Id);
        pageRef.setRedirect(true);
        pageRef.setRedirectCode(301);
        return pageRef;
    }

    public void showErrorPopup() {
        promptErrorHandling = true;
    }
    public void hideErrorPopup() {
        promptErrorHandling = false;
        respond = null;
    }
    public String encodeSearchParams(String request) { return EncodingUtil.urlEncode(request, 'UTF-8'); }

}