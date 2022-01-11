@isTest
public class SOQLQueryINFilter_Test {

    //list variables used by all test methods
    public static list<Account> parentAccounts = new list<Account>();
    public static list<Account> childAccounts = new list<Account>();
    public static list<Account> adjacentAccounts = new list<Account>();
    
    //public class used to populate and insert the records in the public list variables
    public static void testRecords(boolean adj){
        
        for(integer i = 0; i < 10; i++){
            parentAccounts.add(new Account(name = 'parentTest'));
        }
        
        insert parentAccounts;
        
        for(integer i = 0; i < 10; i++){
            
            string childAccountName;
            if(i<3)
                childAccountName = 'childTestLow'; //alter the name of some child accounts for filter testing
            else
                childAccountName = 'childTestHigh';
            
            childAccounts.add(new Account(name = childAccountName, parentId = parentAccounts[i].id));
        }
        
        insert childAccounts;
        
        if(adj){
            for(integer i = 0; i < 10; i++){
                adjacentAccounts.add(new Account(name = 'adjacentTest', parentId = parentAccounts[i].id));
            }
            
            insert adjacentAccounts;
        }
    }
    
    //test the base parent records query with no extra filters or limits
    private static testMethod void testParentRecordsQuery(){
        
        //run testRecords method to create the necessary test records
        testRecords(false);
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentRecords = parentAccounts;
        
        //run the actual query method to get back results
        list<SOQLQueryINFilter.QueryResults> testResults = SOQLQueryINFilter.getQueryRecords(testParams);
        
        //convert SObject results into Accounts
        for(SObject s : testResults[0].records){
            resultRecords.add((Account)s);
        }
        
        //expect all 10 child accounts matched
        System.assertEquals(10, resultRecords.size());
    }
    
    //test the base adjacent records query with no extra filters or limits
    private static testMethod void testAdjacentRecordsQuery(){
        
        //run testRecords method to create the necessary test records
        testRecords(true);
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].adjacentRecords = adjacentAccounts;
        testParams[0].commonFieldName = 'ParentId';
        
        //run the actual query method to get back results
        list<SOQLQueryINFilter.QueryResults> testResults = SOQLQueryINFilter.getQueryRecords(testParams);
        
        //convert SObject results into Accounts
        for(SObject s : testResults[0].records){
            resultRecords.add((Account)s);
        }
        
        //expect all 20 child & adjacent accounts matched
        System.assertEquals(20, resultRecords.size());
    }    
    
    //test the base parent ids query with no extra filters or limits
    private static testMethod void testParentIdsQuery(){
        
        //run testRecords method to create the necessary test records
        testRecords(false);
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> startRecords = new list<Account>();
        list<Account> resultRecords = new list<Account>();
        list<string> accountIds = new list<string>();
        
        startRecords = [SELECT Name, Id, ParentId FROM Account];
        
        for(Account a : startRecords){
            accountIds.add(a.id);
        }
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentIds = accountIds;
        
        //run the actual query method to get back results
        list<SOQLQueryINFilter.QueryResults> testResults = SOQLQueryINFilter.getQueryRecords(testParams);
        
        //convert SObject results into Accounts
        for(SObject s : testResults[0].records){
            resultRecords.add((Account)s);
        }
        
        //expect all 10 child accounts matched
        System.assertEquals(10, resultRecords.size());
    }    
    
    //test the base parent records query with extra filters included
    private static testMethod void testComplexQuery(){  
        
        //run testRecords method to create the necessary test records
        testRecords(false);
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentRecords = parentAccounts;
        testParams[0].addFilters = true;
        testParams[0].addFilterString = 'name = \'childTestLow\'';
        
        //run the actual query method to get back results
        list<SOQLQueryINFilter.QueryResults> testResults = SOQLQueryINFilter.getQueryRecords(testParams);
        
        //convert SObject results into Accounts
        for(SObject s : testResults[0].records){
            resultRecords.add((Account)s);
        }
        
        //expect only the first 3 account records returned based on the filter parameter
        System.assertEquals(3, resultRecords.size());
    }    

    //test the base parent records query with a limit imposed
    private static testMethod void testLimitQuery(){  
        
        //run testRecords method to create the necessary test records
        testRecords(false);
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentRecords = parentAccounts;
        testParams[0].addLimit = true;
        testParams[0].recordLimit = 5;
        
        //run the actual query method to get back results
        list<SOQLQueryINFilter.QueryResults> testResults = SOQLQueryINFilter.getQueryRecords(testParams);
        
        //convert SObject results into Accounts
        for(SObject s : testResults[0].records){
            resultRecords.add((Account)s);
        }
        
        //expect 5 accounts returned based on the limit size
        System.assertEquals(5, resultRecords.size());        
    }   
    
    //test an invalid query string
    private static testMethod void testBadQuery(){  
        
        //run testRecords method to create the necessary test records
        testRecords(false);
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentRecords = parentAccounts;
        testParams[0].addLimit = true;
        testParams[0].recordLimit = -1;
        
        //run the actual query method inside a try/catch as we expect an error in this test
        list<SOQLQueryINFilter.QueryResults> testResults = new list<SOQLQueryINFilter.QueryResults>();
        try{
            testResults = SOQLQueryINFilter.getQueryRecords(testParams);
        }catch(Exception e){
            system.assertEquals('Limit must be a non-negative value',e.getMessage());
        }        
    } 
    
    //test the Max Limit Error Message
    private static testMethod void testMaxLimit(){  
        
        //run testRecords method to create the necessary test records
        testRecords(false);
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentRecords = parentAccounts;
        testParams[0].addLimit = true;
        testParams[0].recordLimit = 50001;
        
        //run the actual query method inside a try/catch as we expect an error in this test
        list<SOQLQueryINFilter.QueryResults> testResults = new list<SOQLQueryINFilter.QueryResults>();
        try{
            testResults = SOQLQueryINFilter.getQueryRecords(testParams);
        }catch(Exception e){
            system.assertEquals('You cannot query more than 50000 records.',e.getMessage());
        }      
    }
    
    //test the No param specified Limit Error Message
    private static testMethod void testNoParam(){  
        
        //run testRecords method to create the necessary test records
        testRecords(false);
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        
        //run the actual query method inside a try/catch as we expect an error in this test
        list<SOQLQueryINFilter.QueryResults> testResults = new list<SOQLQueryINFilter.QueryResults>();
        try{
            testResults = SOQLQueryINFilter.getQueryRecords(testParams);
        }catch(Exception e){
            system.assertEquals('You must specify 1 of these 3: a list of parent records, a list of parent ids, or a list of adjacent records with a common field on the adjacent record.',e.getMessage());
        }      
    }    
}
