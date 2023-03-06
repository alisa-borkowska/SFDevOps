/**
 * Created by alisa.borkowska on 01.12.2022.
 */

public with sharing class HDP_DoctorSearchController {
    public String searchFirstName { get; set; }
    public String searchLastName { get; set; }
    public String searchEmail { get; set; }
    public String searchCountry { get; set; }
    public List<Doctor__c> doctorsList { get; set; }
    public Boolean isEmpty { get; set; }
    public Boolean isCleared { get; set; } {
        isCleared = true;
    }
    public List<Doctor__c> pagedDoctorsList { get; set; }
    public Integer pageNumber { get; set; }
    public Integer resultSize { get; set; }
    public integer pageSize { get; set; } {
        pageSize = 2;
    }
    public Boolean hasPrevious { get; set; }
    public Boolean hasNext { get; set; }
    public String sortOrder { get; set; }
    public List<SelectOption> countryOptions { set; }
    public Document downloadDocument { set; }

    public void searchDoctorRecords() {
        isCleared = false;
        if (searchCountry == null) {
            searchCountry = '';
        }
        doctorsList = [
                SELECT Id, Name, Email__c, License_Number__c, Street__c, City__c, Country__c
                FROM Doctor__c
                WHERE First_Name__c LIKE :'%' + searchFirstName + '%'
                OR Last_Name__c LIKE :'%' + searchLastName + '%'
                OR Email__c LIKE :'%' + searchEmail + '%'
                OR Country__c LIKE :'%' + searchCountry + '%'
        ];
        if (doctorsList.size() == 0) {
            isEmpty = true;

        } else {
            isEmpty = false;

        }

        resultSize = doctorsList.size();
        if (pageNumber == null) {
            pageNumber = 0;
        }
        reloadPagedDoctors();
    }

    public void clearDoctorRecords() {
        doctorsList = new List<Doctor__c>();
        isCleared = true;
        searchFirstName = null;
        searchLastName = null;
        searchEmail = null;
        searchCountry = null;
    }

    public List<SelectOption> getCountryOptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<Doctor__c> docList = [Select Country__c From Doctor__c];
        List<String> uniqueValues = new List<String>();
        for (Doctor__c doc : docList) {
            if (uniqueValues.contains(doc.Country__c)) {
                continue;
            } else if (doc.Country__c == null) {
                continue;
            }
            uniqueValues.add(doc.Country__c);
            options.add(new SelectOption(doc.Country__c, doc.Country__c));

        }
        options.add(new SelectOption('', 'Any'));
        return options;
    }



    public void reloadPagedDoctors() {
        pagedDoctorsList = new List<Doctor__c>();
        for (Integer i = pageSize * pageNumber; i < (pageNumber + 1) * pageSize; i++) {
            if (resultSize > i)
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
        pageNumber -= 1;
        reloadPagedDoctors();
    }
    public void next() {
        pageNumber += 1;
        reloadPagedDoctors();
    }
    public void first() {
        pageNumber = 0;
        reloadPagedDoctors();
    }
    public void last() {
        pageNumber = (resultSize / pageSize) - 1;
        reloadPagedDoctors();
    }

    public PageReference exportCSV() {
        Document document = new Document();

        document.name = 'doctors.csv';
        String fileContent;
        fileContent = 'Full Name,Email,License Number,Full Address' + '\n';
        for (Doctor__c doc : doctorsList) {
            fileContent += String.format('"{0}","{1}","{2}","{3}"\n', new List<Object>{
                    doc.Name, doc.Email__c, doc.License_Number__c, doc.Street__c + ',' + doc.City__c + ',' + doc.Country__c
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
        for (Doctor__c doc : doctorsList) {
            fileContent += String.format('<Row><Cell><Data ss:Type="String">{0}</Data></Cell><Cell><Data ss:Type="String">{1}</Data></Cell><Cell><Data ss:Type="String">{2}</Data></Cell><Cell><Data ss:Type="String">{3}</Data></Cell></Row>\n', new List<Object>{
                    doc.Name, doc.Email__c, doc.License_Number__c, doc.Street__c + ',' + doc.City__c + ',' + doc.Country__c
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


    public void sortByFullName() {
        if (sortOrder == 'Name DESC') {
            sortOrder = 'Name ASC';
            doctorsList = [
                    SELECT Id, Name, Email__c, License_Number__c, Street__c, City__c, Country__c
                    FROM Doctor__c
                    WHERE First_Name__c LIKE :'%' + searchFirstName + '%'
                    AND Last_Name__c LIKE :'%' + searchLastName + '%'
                    AND Email__c LIKE :'%' + searchEmail + '%'
                    AND Country__c LIKE :'%' + searchCountry + '%'
                    ORDER BY Name ASC
            ];
        } else {
            sortOrder = 'Name DESC';
            doctorsList = [
                    SELECT Id, Name, Email__c, License_Number__c, Street__c, City__c, Country__c
                    FROM Doctor__c
                    WHERE First_Name__c LIKE :'%' + searchFirstName + '%'
                    AND Last_Name__c LIKE :'%' + searchLastName + '%'
                    AND Email__c LIKE :'%' + searchEmail + '%'
                    AND Country__c LIKE :'%' + searchCountry + '%'
                    ORDER BY Name DESC
            ];
        }
        reloadPagedDoctors();
    }
    public void sortByEmail() {
        if (sortOrder == 'Email DESC') {
            sortOrder = 'Email ASC';
            doctorsList = [
                    SELECT Id, Name, Email__c, License_Number__c, Street__c, City__c, Country__c
                    FROM Doctor__c
                    WHERE First_Name__c LIKE :'%' + searchFirstName + '%'
                    AND Last_Name__c LIKE :'%' + searchLastName + '%'
                    AND Email__c LIKE :'%' + searchEmail + '%'
                    AND Country__c LIKE :'%' + searchCountry + '%'
                    ORDER BY Email__c ASC
            ];
        } else {
            sortOrder = 'Email DESC';
            doctorsList = [
                    SELECT Id, Name, Email__c, License_Number__c, Street__c, City__c, Country__c
                    FROM Doctor__c
                    WHERE First_Name__c LIKE :'%' + searchFirstName + '%'
                    AND Last_Name__c LIKE :'%' + searchLastName + '%'
                    AND Email__c LIKE :'%' + searchEmail + '%'
                    AND Country__c LIKE :'%' + searchCountry + '%'
                    ORDER BY Email__c DESC
            ];
        }
        reloadPagedDoctors();
    }
    public void sortByLicenseNumber() {
        if (sortOrder == 'LicenseNumber DESC') {
            sortOrder = 'LicenseNumber ASC';
            doctorsList = [
                    SELECT Id, Name, Email__c, License_Number__c, Street__c, City__c, Country__c
                    FROM Doctor__c
                    WHERE First_Name__c LIKE :'%' + searchFirstName + '%'
                    AND Last_Name__c LIKE :'%' + searchLastName + '%'
                    AND Email__c LIKE :'%' + searchEmail + '%'
                    AND Country__c LIKE :'%' + searchCountry + '%'
                    ORDER BY License_Number__c ASC
            ];
        } else {
            sortOrder = 'LicenseNumber DESC';
            doctorsList = [
                    SELECT Id, Name, Email__c, License_Number__c, Street__c, City__c, Country__c
                    FROM Doctor__c
                    WHERE First_Name__c LIKE :'%' + searchFirstName + '%'
                    AND Last_Name__c LIKE :'%' + searchLastName + '%'
                    AND Email__c LIKE :'%' + searchEmail + '%'
                    AND Country__c LIKE :'%' + searchCountry + '%'
                    ORDER BY License_Number__c DESC
            ];
        }
        reloadPagedDoctors();
    }
    public void sortByFullAddress() {
        if (sortOrder == 'FullAddress DESC') {
            sortOrder = 'FullAddress ASC';
            doctorsList = [
                    SELECT Id, Name, Email__c, License_Number__c, Street__c, City__c, Country__c
                    FROM Doctor__c
                    WHERE First_Name__c LIKE :'%' + searchFirstName + '%'
                    AND Last_Name__c LIKE :'%' + searchLastName + '%'
                    AND Email__c LIKE :'%' + searchEmail + '%'
                    AND Country__c LIKE :'%' + searchCountry + '%'
                    ORDER BY Country__c ASC
            ];
        } else {
            sortOrder = 'FullAddress DESC';
            doctorsList = [
                    SELECT Id, Name, Email__c, License_Number__c, Street__c, City__c, Country__c
                    FROM Doctor__c
                    WHERE First_Name__c LIKE :'%' + searchFirstName + '%'
                    AND Last_Name__c LIKE :'%' + searchLastName + '%'
                    AND Email__c LIKE :'%' + searchEmail + '%'
                    AND Country__c LIKE :'%' + searchCountry + '%'
                    ORDER BY Country__c DESC
            ];
        }
        reloadPagedDoctors();
    }
    public void spinner() {

    }
}