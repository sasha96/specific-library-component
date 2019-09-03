/**
*  Class name  :   SL_ctrl_LibraryFormHandler_test
*  Created by  :   Alex Zhurylo
*  Created on  :   09/03/2019
*  Description :   test class for SL_ctrl_LibraryFormHandler
**/
@isTest
public class SL_ctrl_LibraryFormHandler_test {

    /*   getLibraryItemsByName_test
	* 1) return all ContentWorkspace and tale first item;
    * 2) create new Account record;
    * 3) call getLibraryItemsByName and pass all required params;
	*/
    @istest
    public static void getLibraryItemsByName_test() {
        
        List<ContentWorkspace> librariesList = [SELECT id, Name, Description FROM ContentWorkspace ];
              
        if(librariesList.size() > 0){
            String libraryName = librariesList[0].Name; 

            Account acc = (Account) SL_TestDataFactoryNew.createSObject(new Account(), 'SL_TestDataFactoryNew.AccountDefaults', true);
            String returnedResult = SL_ctrl_LibraryFormHandler.getLibraryItemsByName(libraryName, acc.Id);

            SL_TestDataFactoryNew.softAssertNotEquals(returnedResult, null);
            SL_TestDataFactoryNew.hardAssertAllResults();
        } 
    }

    /*   saveFile_test
	* 1) return all ContentWorkspace and tale first item;
    * 2) call saveFile and pass all required params;
	*/
    @isTest
    public static void saveFile_test(){
        
        List<ContentWorkspace> librariesList = [SELECT id, Name, Description FROM ContentWorkspace ];
        if(librariesList.size() > 0){
            List<String> strFileNames = new List<String>{' New Text Document.image'};
            String base64Data = '2VsZWN0IElkLCBuYW1lLCBkZXZlbG9wZXJuYW1lLCBjcmVhdGVkZGF0ZSBmcm9tIEdyb3VwICB3aGVyZSBkZXZlbG9wZXJOYW1lID0gJ1ZsYWRpbWlyX1ByaXNobGFrJw0KU2VsZWN0IElkLCBVc2VyT3JHcm91cElkIGZyb20gR3JvdXBNZW1iZXIgd2hlcmUgR3JvdXBJZCA9ICcwMEc1QzAwMDAwMXJobUNVQVEn';
            Id idOfLibrary = librariesList[0].Id;
                        
            SL_ctrl_LibraryFormHandler.saveFile(strFileNames, base64Data, idOfLibrary);
        }
    }

    /*   createRemoveLinks_test
	* 1) create ContentVersion, ContentDocumentLink;
    * 2) return ContentDocumentLink and ContentDocument;
    * 2) call createRemoveLinks two times and pass all required params;
	*/
    @isTest
    public static void createRemoveLinks_test(){
        
        ContentVersion vers = (ContentVersion) SL_TestDataFactoryNew.createSObject(new ContentVersion(), 'SL_TestDataFactoryNew.ContentVersionDefaults', true);
        ContentDocumentLink contDocLink = (ContentDocumentLink) SL_TestDataFactoryNew.createSObject(new ContentDocumentLink(), 'SL_TestDataFactoryNew.ContentDocumentLinkDefaults', true);
        ContentDocumentLink afterInsertDocLink = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE id =: contDocLink.Id LIMIT 1];
        list<ContentDocument> contDocs = [SELECT id FROM ContentDocument ];
        String recordId = afterInsertDocLink.LinkedEntityId;
        List<String> listOfFielsToInsert = new List<String>{contDocs[0].Id};
        List<String> listOfFielsToRemove = new List<String>{contDocs[0].Id};
        
        try{
            SL_ctrl_LibraryFormHandler.createRemoveLinks(listOfFielsToInsert, listOfFielsToRemove, recordId);
        }catch(Exception ex){
            SL_ctrl_LibraryFormHandler.createRemoveLinks(new List<String>(), listOfFielsToRemove, recordId);
        }
    }
}
