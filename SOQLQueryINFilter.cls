public class SOQLQueryINFilter {
    
    //class definition for throwing custom exceptions
    public class FlowApexActionException extends Exception{}
    
    @InvocableMethod(label='SOQL Query with IN Filter' description='Returns a list of records that have a common parent record IN a list.')
    public static list<QueryResults> getQueryRecords(list<QueryParameters> queryParams){
        
        //throw custom error message if trying to query more than 50000 records
        if(queryParams[0].recordLimit > 50000)
            throw new FlowApexActionException('You cannot query more than 50000 records.');
        
        //verify that either a parent record or parent id list is provided
        if(queryParams[0].parentRecords == null && queryParams[0].parentIds == null && queryParams[0].adjacentRecords == null){
            throw new FlowApexActionException('You must specify 1 of these 3: a list of parent records, a list of parent ids, or a list of adjacent records with a common field on the adjacent record.');
        }
        
        //take the record collection variable and convert the ids into a list of strings so they can be queried against   
        list<String> parentIds = new list<String>();
        if(queryParams[0].parentIds == null && queryParams[0].adjacentRecords == null){
            for(SObject s : queryParams[0].parentRecords){
                if(s != null)
                    parentIds.add((String)s.get('Id'));
                    system.debug('parentID: ' + (String)s.get('Id'));
            }
        }else if(queryParams[0].adjacentRecords == null){
            parentIds.addAll(queryParams[0].parentIds);
        }else{
            for(SObject s : queryParams[0].adjacentRecords){
                if(s != null)
                    parentIds.add((String)s.get(queryParams[0].commonFieldName));
                    system.debug('parentID: ' + (String)s.get(queryParams[0].commonFieldName));
            }
        }
        
        //4 separate query strings are combined into the queryFull string depending on the optional parameters specified
        string query1 = 'Select '+ queryParams[0].fieldsToQuery + ' FROM ' +  queryParams[0].objectApiName + ' WHERE '; //always included
        string query2 = queryParams[0].addFilterString + ' AND '; //only if additional filters are used
        string query3 = queryParams[0].parentFieldName + ' IN :parentIds'; //always included
        string query4 = ' LIMIT ' + queryParams[0].recordLimit; //only if limits are used
        string queryFull;
        
        //logic to build the queryFull string depending on choices made
        if(queryParams[0].addFilters)
            queryFull = query1 + query2 + query3;
        else
            queryFull = query1 + query3;
        if(queryParams[0].addLimit)
            queryFull = queryFull + query4;
        
        //create the list variable to hold the QueryResults
        list<QueryResults> result = new list<QueryResults>();
        
        //try running the query and display error message if it fails
        try{
            sObject[] recordList = database.query(queryFull);
            QueryResults qr = new QueryResults();
            qr.records = recordList;
            system.debug('result size: ' + qr.records.size());
            result.add(qr);
        }catch(Exception e){
            throw e;
        }
        
        //return the Query Results
        return result;
    }
    
    //input parameters for the Apex action
    public class QueryParameters{
        @InvocableVariable(label='Api name of the object' required = true )
        public string objectApiName;
        
        @InvocableVariable(label='API names of the fields to query(comma separated)' required = true)
        public string fieldsToQuery;
        
        @InvocableVariable(label='Api name of the parent field' required = true )
        public string parentFieldName;
        
        @InvocableVariable(label='Api name of the common parent field between the two objects' required = false )
        public string commonFieldName;
        
        @InvocableVariable(label='Adjacent records (1 of 3 required: parent ids, parent records, adjacent records)' required = false)
        public list<SObject> adjacentRecords;
        
        @InvocableVariable(label='Parent records (1 of 3 required: parent ids, parent records, adjacent records)' required = false)
        public list<SObject> parentRecords;
        
        @InvocableVariable(label='Parent ids (1 of 3 required: parent ids, parent records, adjacent records)' required = false)
        public list<string> parentIds;
        
        @InvocableVariable(label='Include additional filters?' required = false)
        public boolean addFilters = false;
        
        @InvocableVariable(label='Additional filter parameters' required = false)
        public string addFilterString;
        
        @InvocableVariable(label='Include limit?' required = false)
        public boolean addLimit = false;
        
        @InvocableVariable(label='Limit size(no comma)' required = false)
        public integer recordLimit;
    }
    
    //output parameters of the Apex action
    public class QueryResults{
        @InvocableVariable(label='Child records')
    public list<SObject> records;        
    }

}
