/**
*  Class name  :   SL_ctrl_LibraryFormHandler
*  Created by  :   Alex Zhurylo
*  Created on  :   09/03/2019
*  Description :   handler for library form
**/
public class SL_ctrl_LibraryFormHandler {

    @AuraEnabled
    public static String getLibraryName(){
        Id currentUser =  UserInfo.getUserId();
        User usr = [SELECT id, Profile.Name FROM User WHERE id =: currentUser];
        String profName = usr.Profile.Name;

        List<LibraryFormSettings__mdt> lstOfReocrds = [SELECT id, label, developername, Library_Name__c, Profile_Name__c, Folder_Name__c 
                                                        FROM LibraryFormSettings__mdt
                                                        WHERE Profile_Name__c =:profName];
        if(lstOfReocrds.size() > 0){
            return JSON.serialize(lstOfReocrds[0]);
        }else{
            lstOfReocrds = [SELECT id, label, developername, Library_Name__c, Profile_Name__c 
                                                        FROM LibraryFormSettings__mdt
                                                        WHERE Profile_Name__c =: 'Default'];
            if(lstOfReocrds.size() > 0){
                return JSON.serialize(lstOfReocrds[0]);
            }
        }
        throw new LibraryFormException('Error happemed in SL_ctrl_LibraryFormHandler.getLibraryName().' +
                                        ' Because there are no library due to your profile assigned in custom metadata' + 
                                        ' LibraryFormSettings__mdt. Please contact your administration. ');
    }
    
    @AuraEnabled
    public static String getLibraryOrFolder(){
        
        LibraryFormSettings__mdt libraryRecord =  (LibraryFormSettings__mdt)JSON.deserialize(getLibraryName(), LibraryFormSettings__mdt.class); 
        
        List<ContentWorkspace> librariesList = [SELECT id, name, RootContentFolderId, Description FROM ContentWorkspace WHERE name =: libraryRecord.Library_Name__c LIMIT 1 ];
        
        if(librariesList.size() > 0){
            return JSON.serialize(new LibratyFolderWrapper(libraryRecord.Folder_Name__c, librariesList[0]));
        } else{
            return JSON.serialize(new LibratyFolderWrapper(libraryRecord.Folder_Name__c, null));
        }
    }

    @AuraEnabled
    public static String getLibraryItemsByName(String libraryName, String recordId){
        
        List<ContentWorkspace> librariesList = [SELECT id, name, Description, RootContentFolderId FROM ContentWorkspace WHERE name =: libraryName LIMIT 1 ];

        if(librariesList.size() == 1){
           
            List<ContentFolderItem>lstFiles =  [ SELECT id, title, FileType, FileExtension, ContentSize, LastModifiedDate 
                                                    FROM ContentFolderItem 
                                                    WHERE parentcontentfolderid =: librariesList[0].RootContentFolderId AND FileType != null AND fileExtension != null ORDER By Title];
            
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
    public static void saveFileInFolder(List<String> strFileNames, String base64Data, Id idOfLibrary, String folderName){

        saveFile(strFileNames, base64Data, idOfLibrary); 

        LibratyFolderWrapper wrapper = (LibratyFolderWrapper)JSON.deserialize(getLibraryOrFolder(), LibratyFolderWrapper.class); 
        ContentWorkspace libraryEntity = wrapper.libraryRecord;

        String libraryId = libraryEntity.RootContentFolderId;
        List<ContentFolder> lstFolders = [SELECT id FROM ContentFolder WHERE Name =: folderName 
                                            AND ParentContentFolderId =: libraryId];

        String fileName = strFileNames[0].replace('(','');
               fileName = fileName.replace(')','');

        List <ContentFolderMember> lsMembers = [SELECT id, ParentContentFolderId FROM ContentFolderMember  
                                            WHERE ParentContentFolderId  =: libraryId AND ChildRecordId IN (SELECT id FROM ContentDocument 
                                            WHERE ParentId =: idOfLibrary AND Title =: fileName )];

        for (Integer i = 0; i < lsMembers.size(); i++) {
            lsMembers[i].ParentContentFolderId = lstFolders[0].Id;
        }
        update lsMembers; 
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

    @AuraEnabled
    public static String getFilesFromFolder(String folderName, String recordId){
         
        LibratyFolderWrapper wrapper = (LibratyFolderWrapper)JSON.deserialize(getLibraryOrFolder(), LibratyFolderWrapper.class); 
        ContentWorkspace libraryEntity = wrapper.libraryRecord;

        String libraryId = libraryEntity.RootContentFolderId;
        
        List<ContentFolder> lstFolders = [SELECT id FROM ContentFolder WHERE Name =: folderName 
                                            AND ParentContentFolderId =: libraryId];
        
        List<ContentFolderItem> lstFolderItems = [SELECT id, title, FileType, FileExtension, ContentSize, LastModifiedDate 
                                                    FROM ContentFolderItem 
                                                    WHERE parentcontentfolderid =: lstFolders[0].Id];
        
        List<ContentDocumentLink> lstCreatedLinks = [SELECT Id, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =: recordId];

        if(lstFolderItems.size() > 0){
            return JSON.serialize(new LibratyItemsWrapper(libraryEntity, lstFolderItems, lstCreatedLinks));
        }else{
            throw new LibraryFormException('Error happened in SL_ctrl_LibraryFormHandler.getFilesFromFolder. Please contact your administration');
        }
    }
    
    public class LibratyItemsWrapper {
        private ContentWorkspace libraryRecord {get;set;}
        private List<ContentDocument> lstFiles {get;set;}
        private List<ContentDocumentLink> lstCreatedLinks {get;set;}
        private List<ContentFolderItem> lstFolderItems {get;set;}

        private LibratyItemsWrapper(ContentWorkspace libraryRecord, List<ContentDocument> lstFiles, List<ContentDocumentLink> lstCreatedLinks) {
            this.libraryRecord = libraryRecord;
            this.lstFiles = lstFiles;
            this.lstCreatedLinks = lstCreatedLinks;
        }

        private LibratyItemsWrapper(ContentWorkspace libraryRecord, List<ContentFolderItem> lstFolderItems, List<ContentDocumentLink> lstCreatedLinks) {
            this.libraryRecord = libraryRecord;
            this.lstFolderItems = lstFolderItems;
            this.lstCreatedLinks = lstCreatedLinks;
        }
    } 

    public class LibratyFolderWrapper {
        private String folderName {get;set;}
        private ContentWorkspace libraryRecord {get;set;}
        private LibratyFolderWrapper(String folderName, ContentWorkspace libraryRecord){
            this.folderName = folderName;
            this.libraryRecord = libraryRecord;
        }
    }

    public class LibraryFormException extends Exception {}

}