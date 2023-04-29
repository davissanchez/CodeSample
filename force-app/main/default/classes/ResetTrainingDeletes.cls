/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is 1 of 2 controllers for resetTraining LWC. When a system admin resets the training
* system, deleteRecords calls a batch to delete each sObject and checkJobStatuses makes sure
* batches were successful. 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Author: Davis Sanchez
* Last Modified By: Davis Sanchez
* Version: 1.0
* Created: 2022-04-03
* Modified: 
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Changes: 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

public without sharing class ResetTrainingDeletes {
    @AuraEnabled
    public static String deleteRecords(String sObjectApiName){
        String where = (sObjectApiName == 'Contact') ? 'WHERE Account.isPersonAccount != true AND TrainingRecordId__c = null' : 'WHERE TrainingRecordId__c = null';
        String jobId = Database.executeBatch(new DeleteRecordsBatch(sObjectApiName, where));
        return JobId;
    }

    @AuraEnabled
    public static Boolean checkJobStatuses(List<String> jobIds){
        
        List<AsyncApexJob> jobs = [SELECT Id, Status, NumberOfErrors, ExtendedStatus, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'DeleteRecordsBatch' AND Id IN :jobIds];

        for(AsyncApexJob job : jobs){
            Boolean success = (job.Status == 'Completed') && (job.NumberOfErrors == 0) ? true : false;
            Boolean notDone = (job.Status != 'Completed') && (job.NumberOfErrors == 0) ? true : false;
            if(success){
                continue;
            } else if(notDone){
                return false;
            } else{
                throw new AuraHandledException(job.ApexClass.Name + ' had ' + job.NumberOfErrors + ' errors: ' + job.ExtendedStatus);
            }
        }
        return true;
    }
}