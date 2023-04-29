//This is a preexisting class written by another developer that I used for this project. See other files for my work.

public inherited sharing class DeleteRecordsBatch implements Database.Batchable<sObject> {
    public final String query;
    public final String objectApiName;
    public final String where;
    
    public DeleteRecordsBatch(String sObjectApiName, String where) {
        query = 'SELECT Id FROM ' + sObjectApiName + ' ' + where;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
 
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        delete scope;
    }
    
    public void finish(Database.BatchableContext bc) {}
}