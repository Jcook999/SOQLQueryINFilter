# SOQLQueryINFilter
Apex Action called by flows to support the SOQL 'IN' filter parameter
# Input Parameters:
  label='Api name of the object' required:true
    Description: The API name of the child object
  label='API names of the fields to query(comma separated)' required = true
    Description: The list of fields to query ex: name, Id, OwnerId
  label='Api name of the parent field' required = true
    Description: The API name of the field that links the parent and the child ex: ParentId
  label='Parent records' required = true
    Description: The collection variable of RECORDS(not a text collection) that the parent records are in 
  label='Include additional filters?' required = false
    Description: A boolean value indicating if you wish to provide filters beyond just CHILD RECORDS IN LIST OF PARENT RECORDS
  label='Additional filter parameters' required = false
    Description: Text string of the additional filter parameters ex: (name = 'ABC' OR name = '123') AND createdBy.Alias = 'jcook'
  label='Include limit?' required = false
    Description: A boolean value indicating if you want to specify a limit on the number of records returned
  label='Limit size(no comma)' required = false
    Description: Integer value of the limit to be imposed
# Output Parameters:
  label='Child records'
    Description: The record collection variable that the result child records will be stored in
