/**
*  Class name  :   SL_ctrl_LibraryFormHandler
*  Created by  :   Alex Zhurylo
*  Created on  :   09/03/2019
*  Description :   handler for library form
**/
public class SL_ctrl_LibraryFormHandler {
    
    @AuraEnabled
    public static String getLibraryItemsByName(String libraryName, String recordId){
        
        List<ContentWorkspace> librariesList = [SELECT id, name, Description FROM ContentWorkspace WHERE name =: libraryName LIMIT 1 ];

        if(librariesList.size() == 1){
            List<ContentDocument> lstFiles = [SELECT Id, LatestPublishedVersionId, LatestPublishedVersion.Title, LatestPublishedVersion.ContentSize, 
                                            LatestPublishedVersion.FileExtension, LatestPublishedVersion.LastModifiedDate 
                                            FROM ContentDocument 
                                            WHERE Id IN (SELECT ContentDocumentId FROM ContentWorkspaceDoc WHERE ContentWorkspace.Id =: librariesList[0].Id) 
                                            ORDER By LatestPublishedVersion.Title];
            
            List<ContentDocumentLink> lstCreatedLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: recordId];

            return JSON.serialize(new LibratyItemsWrapper(librariesList[0], lstFiles, lstCreatedLinks));
        }else{
            throw new LibraryFormException('Error happened in SL_ctrl_LibraryFormHandler.getLibraryItemsByName. Please contact your administration');
        }
    } 

    @AuraEnabled
    public static void saveFile(List<String> strFileNames, String base64Data, Id idOfLibrary) {

        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        List<ContentVersion> lstContVersions = new List<ContentVersion> ();
        for (Integer i = 0; i < strFileNames.size(); i++) {
            ContentVersion cv = new ContentVersion();
                cv.Title = strFileNames[i];
                cv.PathOnClient = '/' + strFileNames[i];
                cv.VersionData = EncodingUtil.base64Decode(base64Data);
                cv.IsMajorVersion = true;
            lstContVersions.add(cv);
        }
        insert lstContVersions;

        List<Id> lstIds = new List<Id>();
        for (Integer i = 0; i < lstContVersions.size(); i++) {
            lstIds.add(lstContVersions[i].Id);
        }
                
        List<ContentVersion> afterInsertContVersions = [SELECT id, ContentDocumentId FROM ContentVersion WHERE id IN : lstIds];

        List<ContentWorkspaceDoc> lstContWorks = new List<ContentWorkspaceDoc>();
        for (Integer i = 0; i < afterInsertContVersions.size(); i++) {
            ContentWorkspaceDoc cwdoc = new ContentWorkspaceDoc();
                cwDoc.ContentDocumentId = afterInsertContVersions[i].ContentDocumentId;
                cwDoc.ContentWorkspaceId = idOfLibrary;
            lstContWorks.add(cwdoc);
        }

        try{
            insert lstContWorks;
        }catch(Exception e ){
            throw new LibraryFormException('Error happened in SL_ctrl_LibraryFormHandler.saveFile. Please contact your administration');
        }
    }

    @AuraEnabled
    public static void createRemoveLinks(List<String> listOfFielsToInsert, List<String> listOfFielsToRemove, String recordId){
                
        List<ContentDocumentLink> lstFutureLinks = new List<ContentDocumentLink>();
        for (Integer i = 0; i < listOfFielsToInsert.size(); i++) {
            ContentDocumentLink link = new ContentDocumentLink();
                link.LinkedEntityId = recordId;
                link.ContentDocumentId = listOfFielsToInsert[i];
                link.shareType = 'v';
            lstFutureLinks.add(link);
        }
        
        if(lstFutureLinks.size() > 0){
            try{
                insert lstFutureLinks;
            }catch(Exception e){
                throw new LibraryFormException('Error happened in SL_ctrl_LibraryFormHandler.createRemoveLinks. Please contact your administration');
            }
        }

        if(listOfFielsToRemove.size() > 0){
            List<ContentDocumentLink> lstCreatedLinksToDelete = [SELECT Id, LinkedEntityId, ContentDocumentId 
                                                                FROM ContentDocumentLink 
                                                                where ContentDocumentId =: listOfFielsToRemove AND LinkedEntityId =: recordId];
            if(lstCreatedLinksToDelete.size() > 0){
                try{
                    delete lstCreatedLinksToDelete;
                }catch(Exception e){
                    throw new LibraryFormException('Error happened in SL_ctrl_LibraryFormHandler.createRemoveLinks. Please contact your administration');
                }
            }
        }
    }
    
    public class LibratyItemsWrapper {
        private ContentWorkspace libraryRecord {get;set;}
        private List<ContentDocument> lstFiles {get;set;}
        private List<ContentDocumentLink> lstCreatedLinks {get;set;}

        private LibratyItemsWrapper(ContentWorkspace libraryRecord, List<ContentDocument> lstFiles, List<ContentDocumentLink> lstCreatedLinks) {
            this.libraryRecord = libraryRecord;
            this.lstFiles = lstFiles;
            this.lstCreatedLinks = lstCreatedLinks;
        }
    } 

    public class LibraryFormException extends Exception {}

}