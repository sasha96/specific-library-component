/**
*  Class name  :   SL_LookupController_test
*  Created by  :   Alex Zhurylo
*  Created on  :   08/09/19
*  Description :   test class for SL_LookupController
**/
@isTest
public class SL_LookupController_test {
    
    @TestSetup
    public static void initialize(){
        Contact con = new Contact();
            con.FirstName = 'testCont';
            con.LastName = 'testCont';
        insert con;
        Contact newCont = con.clone(false, false, false, false);
            newCont.FirstName = 'testCont-clone';
        insert newCont;
    }

    @isTest
    public static void search_test(){
        
        List<Contact> lstConts = [SELECT id, Name FROM Contact LIMIT 2 ];
        List<sObject> returnedResult = SL_LookupController.search(lstConts[0].Name, 'Contact', 'FirstName', ' name != \' te12 \'', 1, new List<Id>{lstConts[1].Id} );

        String query = 'SELECT Name FROM Contact WHERE FirstName LIKE \'%'+ lstConts[0].Name +'%\'  LIMIT 1' ;
        List<sObject> expectedResult = Database.query(query);

        System.assertEquals(returnedResult, expectedResult);
    }

    @isTest
    public static void getRecord_test(){

        List<Contact> lstConts = [SELECT id, FirstName FROM Contact LIMIT 1 ];

        sObject retuned = SL_LookupController.getRecord(lstConts[0].Id, 'Contact', 'FirstName' );
        String recordId = lstConts[0].Id;
       	Set<String> fieldsToQuery = new Set<string>();
			fieldsToQuery.add('Id');
			fieldsToQuery.add('FirstName');
		
	    String query = 'SELECT ' + String.join(new List<String> (fieldsToQuery), ', ') +  ' FROM ' + 'Contact' + ' WHERE Id = :recordId';
        
        List<sObject> expectedResult = Database.query(query);
        System.assertEquals(retuned, expectedResult[0]);
    }

    @isTest
    public static void getMultiRecords_test(){
        
        List<Contact> lstConts = [SELECT id, FirstName FROM Contact LIMIT 2 ];
        List<Id> lstIds = new List<Id>();
        for (Integer i = 0; i < lstConts.size(); i++) {
            lstIds.add(lstConts[i].Id);
        }
        
        List<sObject> returnedResult = SL_LookupController.getMultiRecords(JSON.serialize(lstIds), 'Contact', 'FirstName');
        System.assertEquals(returnedResult.size(), 2);
    }
}