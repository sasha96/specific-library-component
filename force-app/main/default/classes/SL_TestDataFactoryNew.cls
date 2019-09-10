public abstract class SL_TestDataFactoryNew {
 
    private static Map<Boolean, String> mapMessageByResult = new Map<Boolean, String>();
    private static Integer failures = 0;
    private static Integer passes = 0;

    public static void generateUniqTestData() {
        SL_TestDataFactoryNew.createSObject(new Account(), 'SL_TestDataFactoryNew.AccountDefaults', true);
        SL_TestDataFactoryNew.createSObject(new Lead(), 'SL_TestDataFactoryNew.LeadDefaults', true);
        SL_TestDataFactoryNew.createSObject(new Campaign(), 'SL_TestDataFactoryNew.CampaignDefaults', true);
        SL_TestDataFactoryNew.createSObject(new Opportunity(), 'SL_TestDataFactoryNew.OpportunityDefaults', true);
        SL_TestDataFactoryNew.createSObject(new Contact(), 'SL_TestDataFactoryNew.ContactDefaultsLight', true);
        SL_TestDataFactoryNew.createSObject(new User(), 'SL_TestDataFactoryNew.UserDefaults', true);
        SL_TestDataFactoryNew.createSObject(new Product2(), 'SL_TestDataFactoryNew.Product2Defaults', true);
        SL_TestDataFactoryNew.createSObject(new CollaborationGroup(), 'SL_TestDataFactoryNew.CollaborationGroupDefaults', true);
        SL_TestDataFactoryNew.createSObject(new Document(), 'SL_TestDataFactoryNew.DocumentDefaults', true);
        SL_TestDataFactoryNew.createSObject(new Group(), 'SL_TestDataFactoryNew.GroupDefaults', true); 
        SL_TestDataFactoryNew.createSObject(new Pricebook2(), 'SL_TestDataFactoryNew.Pricebook2Defaults', true);
        SL_TestDataFactoryNew.createSObject(new Case(), 'SL_TestDataFactoryNew.CaseDefaults', true);
        SL_TestDataFactoryNew.createSObject(new Task(), 'SL_TestDataFactoryNew.TaskDefault', true);
        SL_TestDataFactoryNew.createSObject(new Topic(), 'SL_TestDataFactoryNew.TopicDefaults', true);
        SL_TestDataFactoryNew.createSObject(new Attachment(), 'SL_TestDataFactoryNew.AttachmentDefaults', true);
        SL_TestDataFactoryNew.createSObject(new PricebookEntry(), 'SL_TestDataFactoryNew.PriceBookEntryDefaults', true);
        SL_TestDataFactoryNew.createSObject(new OpportunityLineItem(), 'SL_TestDataFactoryNew.OpportunityLineItemyDefaults', true);
        SL_TestDataFactoryNew.createSObject(new ContentVersion(), 'SL_TestDataFactoryNew.ContentVersionDefaults', true);
        SL_TestDataFactoryNew.createSObject(new ContentDocumentLink(), 'SL_TestDataFactoryNew.ContentDocumentLinkDefaults', true);
        SL_TestDataFactoryNew.createSObject(new FeedItem(), 'SL_TestDataFactoryNew.FeedItemDefaults', true);
    }

    public static void generateListTestData() {
        SL_TestDataFactoryNew.createSObjectList(new Account(), 5, 'SL_TestDataFactoryNew.AccountDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Lead(), 5, 'SL_TestDataFactoryNew.LeadDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Campaign(), 5, 'SL_TestDataFactoryNew.CampaignDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Opportunity(), 5, 'SL_TestDataFactoryNew.OpportunityDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Contact(), 5, 'SL_TestDataFactoryNew.ContactDefaultsLight', true);
        SL_TestDataFactoryNew.createSObjectList(new User(), 5, 'SL_TestDataFactoryNew.UserDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Product2(), 5, 'SL_TestDataFactoryNew.Product2Defaults', true);
        SL_TestDataFactoryNew.createSObjectList(new CollaborationGroup(), 5, 'SL_TestDataFactoryNew.CollaborationGroupDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Document(), 5, 'SL_TestDataFactoryNew.DocumentDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Group(), 5, 'SL_TestDataFactoryNew.GroupDefaults', true); 
        SL_TestDataFactoryNew.createSObjectList(new Pricebook2(), 5, 'SL_TestDataFactoryNew.Pricebook2Defaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Case(), 5, 'SL_TestDataFactoryNew.CaseDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Task(), 5,'SL_TestDataFactoryNew.TaskDefault', true);
        SL_TestDataFactoryNew.createSObjectList(new Topic(), 5, 'SL_TestDataFactoryNew.TopicDefaults', true);
		SL_TestDataFactoryNew.createSObjectList(new ContentVersion(), 5,'SL_TestDataFactoryNew.ContentVersionDefaults', true);
		SL_TestDataFactoryNew.createSObjectList(new FeedItem(), 5,'SL_TestDataFactoryNew.FeedItemDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new Attachment(), 5, 'SL_TestDataFactoryNew.AttachmentDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new ContentDocumentLink(), 5, 'SL_TestDataFactoryNew.ContentDocumentLinkDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new PricebookEntry(), 5, 'SL_TestDataFactoryNew.PriceBookEntryDefaults', true);
        SL_TestDataFactoryNew.createSObjectList(new OpportunityLineItem(), 5, 'SL_TestDataFactoryNew.OpportunityLineItemyDefaults', true);  
    }

    public static SObject createSObject(SObject sObj) {
        
        String objectName = String.valueOf(sObj.getSObjectType());

        String defaultClassName = 'SL_TestDataFactory.' + objectName.replaceAll('__(c|C)$|__', '') + 'Defaults';
    
        if (Type.forName(defaultClassName) != null) {
            sObj = createSObject(sObj, defaultClassName);
        }

        return sObj;
    }

    public static SObject createSObject(SObject sObj, Boolean doInsert) {
        
        SObject retObject = createSObject(sObj);
        
        if (doInsert) {
            insert retObject;
        }

        return retObject;
    }

    public static SObject createSObject(SObject sObj, String defaultClassName) {
        
        Type t = Type.forName(defaultClassName);
        
        if (t == null) {
            Throw new TestFactoryException('Invalid defaults class.');
        }

        FieldDefaults defaults = (FieldDefaults)t.newInstance();
        addFieldDefaults(sObj, defaults.getFieldDefaults());
        
        return sObj;
    }

    public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
        
        SObject retObject = createSObject(sObj, defaultClassName);
        
        if (doInsert) {
            insert retObject;
        }

        return retObject;
    }

    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
        return createSObjectList(sObj, numberOfObjects, (String)null);
    }

    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
        
        SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
        
        if (doInsert) {
            insert retList;
        }

        return retList;
    }

    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
        
        SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
        
        if (doInsert) {
            insert retList;
        }

        return retList;
    }

    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
        
        SObject[] sObjs = new SObject[] {};
        SObject newObj;

        if (defaultClassName == null) {
            newObj = createSObject(sObj);
        } else {
            newObj = createSObject(sObj, defaultClassName);
        }

        String nameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
        if (nameField == null) {
            nameField = 'Name';
        }

        for (Integer i = 0; i < numberOfObjects; i++) {
        
            SObject clonedSObj = newObj.clone(false, true);

            if (String.valueOf(sObj.getSObjectType()) == 'User'){
                String userEmail = (String)clonedSObj.get('Email');
                userEmail = userEmail.replace('@gmail.com', i + '@gmail.com');
                clonedSObj.put('UserName' , userEmail);
                clonedSObj.put('Email' , userEmail);
            } else if (String.valueOf(sObj.getSObjectType()) == 'Contact'){
                String userName = (String)clonedSObj.get('LastName');
                userName = userName + i;
                clonedSObj.put('LastName' , userName);
            } else if (String.valueOf(sObj.getSObjectType()) == 'Lead'){
                String userName = (String)clonedSObj.get('LastName');
                userName = userName + i;
                clonedSObj.put('LastName' , userName + i);
            } else if (String.valueOf(sObj.getSObjectType()) == 'Document'){
                String name = (String)clonedSObj.get('DeveloperName');
                name = name + i;
                clonedSObj.put('DeveloperName' , name + i);
            } else if (String.valueOf(sObj.getSObjectType()) == 'PricebookEntry'){
                Product2  newOne = (Product2) SL_TestDataFactoryNew.createSObject(new Product2(), 'SL_TestDataFactoryNew.Product2Defaults');
                    newOne.Name = 'newOneName' + i;
                insert newOne;
                clonedSObj.put('Product2Id' , newOne.Id);
            } else if (String.valueOf(sObj.getSObjectType()) == 'OpportunityLineItem'){
                Opportunity opp = TDF_Opportunity;
                PricebookEntry prc = TDF_PricebookEntry;
                clonedSObj.put('OpportunityId' , opp.Id);
                clonedSObj.put('PricebookEntryId' , prc.Id);
            } else if ( String.valueOf(sObj.getSObjectType()) == 'ContentDocumentLink'){
                ContentVersion contV = (ContentVersion) SL_TestDataFactoryNew.createSObject(new ContentVersion(), 'SL_TestDataFactoryNew.ContentVersionDefaults');
                    contV.title = 'test' + Math.random();
                insert contV;
                contV =  [SELECT id, ContentDocumentId FROM ContentVersion WHERE id =: contV.Id];
                clonedSObj.put('ContentDocumentId' , contV.ContentDocumentId);
            } else if (String.valueOf(sObj.getSObjectType()) == 'ContentVersion'){
                String userName = (String)clonedSObj.get('title');
                userName = userName + i;
                clonedSObj.put('title' , userName + i);
            } else if (String.valueOf(sObj.getSObjectType()) == 'FeedItem'){
                Opportunity newOpp = (Opportunity) SL_TestDataFactoryNew.createSObject(new Opportunity(), 'SL_TestDataFactoryNew.OpportunityDefaults');
                    newOpp.Name = 'testName' + i;
                insert newOpp;
                clonedSObj.put('ParentId' , newOpp.Id);
            } else {
                Map<String, Schema.SobjectField> fields = newObj.getSObjectType().getDescribe().fields.getMap();
                if (!fields.get(nameField).getDescribe().isAutonumber()) {
                    clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i );
                }
            }
            sObjs.add(clonedSObj);
        }

        return sObjs;
    }

    private static void addFieldDefaults(SObject sObj, Map<Schema.SObjectField, Object> defaults) {
    
        Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
        for (Schema.SObjectField field : defaults.keySet()) {
            if (!populatedFields.containsKey(String.valueOf(field))) {
                sObj.put(field, defaults.get(field));
            }
        }
    }

    private static Map<String, String> nameFieldMap = new Map<String, String> {
        'User' => 'UserName',
        'Contact' => 'LastName',
        'Case' => 'Subject',
        'Lead' => 'LastName',
        'Task' => 'Subject'
    };

    public class TestFactoryException extends Exception {}

    public interface FieldDefaults {
        Map<Schema.SObjectField, Object> getFieldDefaults();
    }

    public class AccountDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Account.Name => 'Test New Acc - 01',
                Account.BillingCity =>'New York',
                Account.BillingPostalCode => '10021',
                Account.BillingCountry => 'USA',
                Account.BillingStreet => 'Broadway ' ,
                Account.BillingState =>  'State' 
            };
        }
    }

    public class LeadDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Lead.FirstName => 'John',
                Lead.LastName => 'Doe',
                Lead.Status => 'Inquiry',
                Lead.Email => 'lead@silverlinecrm.test',
                Lead.Company => 'Test'
            };
        }
    }

    public class CampaignDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Campaign.Name => 'Test Campaign'
            };
        }
    }

    public class OpportunityDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Opportunity.Name => 'Test Opportunity',
                Opportunity.StageName => 'Closed Won',
                Opportunity.CloseDate => Date.today()
            };
        }
    }

    public class ContactDefaultsLight implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Contact.FirstName => 'ResourceFN',
                Contact.LastName => 'ResourceLN'
            };
        }
    }

    public class UserDefaults implements FieldDefaults {
        
        Profile prof = [SELECT id from profile where name = 'System Administrator'];
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                User.Username => 'sasha888@gmail.com',
                User.LastName =>'Bla',
                User.Alias =>'sas',
                User.TimeZoneSidKey => 'America/New_York',
                User.LocaleSidKey => 'en_GB',
                User.EmailEncodingKey => 'UTF-8',
                User.ProfileId => (prof != null ? prof.id : null),
                User.LanguageLocaleKey => 'en_US',
                User.Email => 'sasha888@gmail.com'
            };
        }
    }

    public class Product2Defaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Product2.Name => 'Test Product Entry',
                Product2.Description => 'Test Product Entry',
                Product2.isActive => true
            };
        }
    }
    
    public class CollaborationGroupDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                CollaborationGroup.Name=>'Test Sales Wins',
                CollaborationGroup.CollaborationType=>'Private'
            };
        }
    }

    public class DocumentDefaults implements FieldDefaults {
        
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Document.Body => Blob.valueOf('Sample Text'),
                Document.ContentType => 'application/pdf',
                Document.DeveloperName => 'Clock_Icon',
                Document.IsPublic => true,
                Document.Name => 'Test_Document',
                Document.FolderId => UserInfo.getUserId()
            };
        }
    }

    public class GroupDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Group.Name => 'Test SL_ctrl_DynTbl_Test group'
            };
        }
    }
    
    public class Pricebook2Defaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Pricebook2.Name => 'Custom Pricebook',
                Pricebook2.isActive => true
            };
        }
    }

    public class CaseDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Case.Origin => 'Web',
                Case.Status =>'New',
                Case.Reason => 'Administration Request',
                Case.Subject => 'Test Subject'
            };
        }
    }

    public class TaskDefault implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Task.Subject=>'Donni',
                Task.Status=>'Completed',
                Task.Priority=>'Normal',
                Task.OwnerId => UserInfo.getUserId()
            };
        }
    }

    public class TopicDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                Topic.Name => 'Test Topic 1'
            };
        }
    }

    public class AttachmentDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            
            Account acc = TDF_Account;
    
            return new Map<Schema.SObjectField, Object> {
                Attachment.name => String.valueOf('test.txt'),
                Attachment.ContentType => 'contentType',
                Attachment.Body => Blob.valueOf('Unit Test Attachment Body'),
                Attachment.ParentId => acc.Id
            };
        }
    }

    public class PriceBookEntryDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            
            Product2 prd = TDF_Product2;
 
            return new Map<Schema.SObjectField, Object> {
                PricebookEntry.UnitPrice => 300,
                PricebookEntry.isActive => true,
                PricebookEntry.Pricebook2Id => Test.getStandardPricebookId(),
                PricebookEntry.Product2Id => prd.Id,
                PricebookEntry.UseStandardPrice => false
            };
        }
    }

    public class OpportunityLineItemyDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {

            Opportunity opp = TDF_Opportunity;
            PricebookEntry prc = TDF_PricebookEntry;

            return new Map<Schema.SObjectField, Object> {
                OpportunityLineItem.UnitPrice => 1,
                OpportunityLineItem.Quantity => 2,
                OpportunityLineItem.ServiceDate => Date.today(),
                OpportunityLineItem.OpportunityId => opp.Id,
                OpportunityLineItem.PricebookEntryId => prc.Id
            };
        }
    }

    public class ContentVersionDefaults implements FieldDefaults {
       
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            return new Map<Schema.SObjectField, Object> {
                ContentVersion.title=>'ABC',
                ContentVersion.PathOnClient =>'test1',
                ContentVersion.VersionData =>Blob.valueOf('Test Content')
            };
        }
    }

    public class ContentDocumentLinkDefaults implements FieldDefaults {
    
        public Map<Schema.SObjectField, Object> getFieldDefaults() {

            ContentVersion contV = TDF_ContentVersion;

            Opportunity opp = TDF_Opportunity;

            return new Map<Schema.SObjectField, Object> {
                ContentDocumentLink.ShareType => 'V',
                ContentDocumentLink.Visibility => 'InternalUsers',
                ContentDocumentLink.ContentDocumentId => contV.ContentDocumentId,
                ContentDocumentLink.LinkedEntityId => opp.id
            };
        }
    }

    public class FeedItemDefaults implements FieldDefaults {
        
        public Map<Schema.SObjectField, Object> getFieldDefaults() {
            
            Opportunity opp = TDF_Opportunity;
            
            return new Map<Schema.SObjectField, Object> {
                FeedItem.type => 'ContentPost',
                FeedItem.Body => 'Hello',
                FeedItem.ParentId => opp.Id
            };
        }
    }

    public static Opportunity TDF_Opportunity {
        get {
            if ( TDF_Opportunity == null ) {
                List<Opportunity> lstOpps = [SELECT id, Name FROM Opportunity LIMIT 1];
                if(lstOpps.size() > 0){
                    TDF_Opportunity = lstOpps[0];
                }else{
                    TDF_Opportunity = (Opportunity) SL_TestDataFactoryNew.createSObject(new Opportunity(), 'SL_TestDataFactoryNew.OpportunityDefaults', true);
                }
            }
            return TDF_Opportunity;
        } private set;
    }

    public static Account TDF_Account {
        get {
            if ( TDF_Account == null ) {
                List<Account> lstAccs = [SELECT id, Name FROM Account LIMIT 1];
                if(lstAccs.size() > 0){
                    TDF_Account = lstAccs[0];
                }else{
                    TDF_Account = (Account) SL_TestDataFactoryNew.createSObject(new Account(), 'SL_TestDataFactoryNew.AccountDefaults', true);
                }
            }
            return TDF_Account;
        } private set;
    }

    public static Topic TDF_Topic {
        get {
            if ( TDF_Topic == null ) {
                List<Topic> lstTops = [SELECT id, Name FROM Topic LIMIT 1];
                if(lstTops.size() > 0){
                    TDF_Topic = lstTops[0];
                }else{
                    TDF_Topic = (Topic) SL_TestDataFactoryNew.createSObject(new Topic(), 'SL_TestDataFactoryNew.TopicDefaults', true);
                }
            }
            return TDF_Topic;
        } private set;
    }
    
    public static Product2 TDF_Product2 {
        get {
            if ( TDF_Product2 == null ) {
                List<Product2> lstProds = [SELECT id, Name FROM Product2 LIMIT 1];
                if(lstProds.size() > 0){
                    TDF_Product2 = lstProds[0];
                }else{
                    TDF_Product2 = (Product2) SL_TestDataFactoryNew.createSObject(new Product2(), 'SL_TestDataFactoryNew.Product2Defaults', true);
                }
            }
            return TDF_Product2;
        } private set;
    }
    
    public static ContentVersion TDF_ContentVersion {
        get {
            if ( TDF_ContentVersion == null ) {
                List<ContentVersion> lstContVers = [SELECT id, title, ContentDocumentId FROM ContentVersion LIMIT 1];
                if(lstContVers.size() > 0){
                    TDF_ContentVersion = lstContVers[0];
                }else{
                    TDF_ContentVersion = (ContentVersion) SL_TestDataFactoryNew.createSObject(new ContentVersion(), 'SL_TestDataFactoryNew.ContentVersionDefaults', true);
                }
            }
            return TDF_ContentVersion;
        } private set;
    }
    
    public static PricebookEntry TDF_PricebookEntry {
        get {
            if ( TDF_PricebookEntry == null ) {
                List<PricebookEntry> lstPrices = [SELECT id FROM PricebookEntry LIMIT 1];
                if(lstPrices.size() > 0){
                    TDF_PricebookEntry = lstPrices[0];
                }else{
                    TDF_PricebookEntry = (PricebookEntry) SL_TestDataFactoryNew.createSObject(new PricebookEntry(), 'SL_TestDataFactoryNew.PriceBookEntryDefaults', true);
                }
            }
            return TDF_PricebookEntry;
        } private set;
    }

    //used to soft assert primitive data types
    public static void softAssertEquals(Object o1, Object o2){
        
        String message;

        if(o1 == o2) {
            passes++;
            message = '\n\nSoft Assert Succeeded: [' + o1 + ' = ' + o2 + ']\n';
            system.debug(message);
            trackSoftAssertResult(true, message);
        }
        else {
            failures++;
            message = '\n\nSoft Assert Failed: [' + o1 + ' != ' + o2 + ']\n';
            system.debug(message);
            trackSoftAssertResult(false, message);
        }
    }

    //used to soft assert primitive data types
    public static void softAssertNotEquals(Object o1, Object o2){
        
        String message;

        if(o1 == o2) {
            failures++;
            message = '\n\nSoft Assert Failed: [' + o1 + ' = ' + o2 + ']\n';
            system.debug(message);
            trackSoftAssertResult(false, message);
        }
        else {
            passes++;
            message = '\n\nSoft Assert Passed: [' + o1 + ' != ' + o2 + ']\n';
            system.debug(message);
            trackSoftAssertResult(true, message);
        }
    }

    public static void softAssert(Boolean result, String message) {
        
        if (result) {
            passes++;
            system.debug(message);
            trackSoftAssertResult(true, message);
        } else {
            failures++;
            system.debug(message);
            trackSoftAssertResult(false, message);
        }
    }

    //call after all soft asserts completed in a given method to determine
    // if any or all test passed
    // if one or more soft assert test fail, entire method will fail
    public static void hardAssertAllResults() {
        
        if (mapMessageByResult.containsKey(false)) {
            //fail
            String failResult = mapMessageByResult.get(false);
            String passResult = mapMessageByResult.containsKey(true) ? ' with results ' + mapMessageByResult.get(true) : '';
            mapMessageByResult.clear(); //clear results for next test
            System.assert(false, 'Fail: ' + failures + ' test(s) fail because of ' + failResult + ' '
                    + passes + ' test(s) passes' + passResult);
        } else {
            //pass
            System.assert(true);
        }
    }

    private static void trackSoftAssertResult(Boolean hasPass, String testResult) {
        
        if(mapMessageByResult.containsKey(hasPass)) {
            testResult = mapMessageByResult.get(hasPass) + '\n' + testResult;
        }

        mapMessageByResult.put(hasPass, testResult);
    }


}