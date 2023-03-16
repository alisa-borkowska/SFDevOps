public with sharing class FileController{
    @AuraEnabled(cacheable=true)
        public static List<ContentVersion> getVersionFiles(String recordId){
            try {
                return [
            SELECT
            Id,
            Title,
            ContentDocumentId,
            FileType, 
            ContentSize,
            FileExtension,
            VersionNumber,
            CreatedDate,
            VersionData,
            FirstPublishLocationId
            FROM ContentVersion
            WHERE FirstPublishLocationId =:recordId
            ORDER BY CreatedDate DESC
            ];
            
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            
        }

        @AuraEnabled(cacheable=false)
        public static void updateDisplayUrl (String recordId, String imageUrl)
        {       
            Product2 file = [SELECT Id, DisplayUrl
            FROM Product2
            WHERE Id =: recordId];
            
            file.DisplayUrl = imageUrl;
            update file;

        }

        @AuraEnabled(cacheable=false)
        public static void removeFile(String fileId){
            System.debug(fileId);
            ContentVersion cv = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE Id = :fileId
            ][0];
            ContentDocument file = [
                SELECT Id
                FROM ContentDocument
                WHERE Id = :cv.ContentDocumentId
            ][0];
            delete file;
        }
    }