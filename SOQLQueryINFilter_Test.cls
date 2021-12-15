@isTest
public class SOQLQueryINFilter_Test {

    //list variables used by all test methods
    public static list<Account> parentAccounts = new list<Account>();
    public static list<Id> parentIds = new list<Id>();
    public static list<Account> childAccounts = new list<Account>();
    
    //public class used to populate and insert the records in the public list variables
    public static void testRecords(){
        
        for(integer i = 0; i < 10; i++){
            parentAccounts.add(new Account(name = 'parentTest'));
        }
        
        insert parentAccounts;
        
        for(Account acc: parentAccounts){
            parentIds.add(acc.Id);
        }
        
        for(integer i = 0; i < 10; i++){
            
            string childAccountName;
            if(i<3)
                childAccountName = 'childTestLow'; //alter the name of some child accounts for filter testing
            else
                childAccountName = 'childTestHigh';
            
            childAccounts.add(new Account(name = childAccountName, parentId = parentAccounts[i].id));
        }
        insert childAccounts;
    }
    
    //test the base query with no extra filters or limits
    private static testMethod void testBasicQuery(){
        
        //run testRecords method to create the necessary test records
        testRecords();
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentIds = parentIds;
        
        //run the actual query method to get back results
        list<SOQLQueryINFilter.QueryResults> testResults = SOQLQueryINFilter.getQueryRecords(testParams);
        
        //convert SObject results into Accounts
        for(SObject s : testResults[0].records){
            resultRecords.add((Account)s);
    	}
        
        //expect all 10 child accounts matched
        System.assertEquals(10, resultRecords.size());
    }
    
    //test the base query with extra filters included
    private static testMethod void testComplexQuery(){  
        
        //run testRecords method to create the necessary test records
        testRecords();
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentIds = parentIds;
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

    //test the base query with a limit imposed
    private static testMethod void testLimitQuery(){  
        
        //run testRecords method to create the necessary test records
        testRecords();
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentIds = parentIds;
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
        testRecords();
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentIds = parentIds;
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
        testRecords();
        
        //create a list variable for the test parameters and another list variable for the resulting child accounts
        list<SOQLQueryINFilter.QueryParameters> testParams = new list<SOQLQueryInFilter.QueryParameters>();
        list<Account> resultRecords = new list<Account>();
        
        //build the parameters for the query
        testParams.add(new SOQLQueryINFilter.QueryParameters());
        testParams[0].objectApiName = 'Account';
        testParams[0].fieldsToQuery = 'Name, Id, ParentId';
        testParams[0].parentFieldName = 'ParentId';
        testParams[0].parentIds = parentIds;
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
}
