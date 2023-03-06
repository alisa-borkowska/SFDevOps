public with sharing class OrganisationController {
    public Boolean isEmpty { get; set; }
    public Boolean isCleared { get; set; } {
        isCleared = true;
    }
    public String idToDelete { get; set; }
    public String idToEdit { get; set; }
    public Boolean promptBeforeDelete { get; set; }
    public Boolean promptErrorHandling { get; set; }
    public List<User> usersList { get; set; }
    public User us { get; set; }
    public String fullName { get; set; }
    public Integer apexClassesCount { get; set; }
    public Integer apexPagesCount { get; set; }
    public Integer apexLicensesCount { get; set; }
    public Boolean sessionIdPromptShown { get; set; } {
        sessionIdPromptShown = false;
    }
    public Integer usedApiCalls { get; set; }
    public String respond { get; set; }
    public Boolean isError { get; set; }
    public Boolean isSuccess { get; set; }
    public Id userToDeactivate;


    public void showPopup() {
        idToDelete = ApexPages.currentPage().getParameters().get('idToDelete');
        promptBeforeDelete = true;
    }
    public void hidePopup() {
        promptBeforeDelete = false;
    }


    public void getData() {
        apexLicensesCount = [
                SELECT UsedLicenses
                FROM UserLicense
                WHERE Name = 'Salesforce'
        ].UsedLicenses;
        apexClassesCount = [select Id from ApexClass LIMIT 10000].size();
        apexPagesCount = [SELECT Name FROM ApexPage].size();
        usersList = [
                SELECT Name, Id, Email, IsActive, TimeZoneSidKey, LastLoginDate, ProfileId, Profile.name
                FROM User
                WHERE IsActive = true
        ];
        usedApiCalls = getUsedApiCalls();
    }

    public Integer getUsedApiCalls() {
        String endpointString = url.getOrgDomainUrl().toExternalForm() + '/services/data/v50.0/limits';

        HttpRequest api = new HttpRequest();
        api.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        api.setEndpoint(endpointString);
        api.setMethod('GET');
        HTTPResponse res = new Http().send(api);

        Map<String, Object> test = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> dailyRequests = (Map<String, Object>) test.get('DailyApiRequests');
        return (Integer) dailyRequests.get('Max') - (Integer) dailyRequests.get('Remaining');
    }


    public void showSessionIdPrompt() {
        sessionIdPromptShown = true;
    }
    public void hideSessionIdPrompt() {
        sessionIdPromptShown = false;
    }

    public void passUserToDeactivate() {
        userToDeactivate = ApexPages.currentPage().getParameters().get('userToDeactivate');
        isError = false;
        isSuccess = true;
        User found = null;
        for (User u : usersList) {
            if (u.Id == userToDeactivate) {
                found = u;
                break;
            }
        }
        if (found != null) {
            found.IsActive = !found.IsActive;
            try {
                update found;
                System.debug('updated');
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug('Are you root?');
                respond = 'Failed to deactivate. Are you root?';
                isError = true;
                isSuccess = false;
            }
        }
        try {
            getData();
        } catch (Exception e) {}
    }

    public void setUserToDeactivate(Id userToDeactivate) {
        System.debug(userToDeactivate);
        System.debug(this.userToDeactivate);
        System.debug(usersList);
    }
}