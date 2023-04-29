/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is 1 of 2 controllers for resetTraining LWC. It reads CSV files containing records 
* native to the training system and upserts the records (upsert rather than update because trainees
* can delete some records). Methods are invoked when a system admin resets the training system via
* resetTraining LWC. CSVs are maintained by trainers.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Author: Davis Sanchez
* Last Modified By: Davis Sanchez
* Version: 1.0
* Created: 2022-04-03
* Modified: 2022-04-20
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Changes: 
*   2022-04-20: Added createDate and createDatetime methods and changed all uses of Date.valueOf()
*   and Datetime.valueOf() to use createDate and createDateTime. Dates in CSVs are now stored
*   like '2023 4 13' rather than like '2023-04-13' because the latter string triggers excel to 
*   auto format the date incorrectly, which added extra steps for Trainers when updating CSVs.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class ResetTrainingUpserts {
    @AuraEnabled
    public static List<String> readCsv(String staticResourceName){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        String csvAsString = sr.Body.toString();
        List<String> csvFileLines = csvAsString.split('\n');
        return csvFileLines;
    }

    @AuraEnabled
    public static Datetime createDatetime(String dtString){
        List<String> params = dtString.split(' ');

        Integer year = Integer.valueOf(params[0]);
        Integer month = Integer.valueOf(params[1]);
        Integer day = Integer.valueOf(params[2]);
        Integer hour = Integer.valueOf(params[3]);
        Integer min = Integer.valueOf(params[4]);
        Integer sec = Integer.valueOf(params[5]);

        Datetime dt = Datetime.newInstance(year, month, day, hour, min, sec);
        return dt;
    }

    @AuraEnabled
    public static Date createDate(String dateString){
        List<String> params = dateString.split(' ');

        Integer year = Integer.valueOf(params[0]);
        Integer month = Integer.valueOf(params[1]);
        Integer day = Integer.valueOf(params[2]);

        Date d = Date.newInstance(year, month, day);
        return d;
    }

    @AuraEnabled
    public static void upsertAccountContactRelations(String staticResourceName){
        List<AccountContactRelation> upsertList = new List<AccountContactRelation>();
        List<String> csvFileLines = readCsv(staticResourceName);

        for(Integer i = 1; i < csvFileLines.size(); i++){
            List<String> csvRecordData = csvFileLines[i].split(',');
            AccountContactRelation acr = new AccountContactRelation();

            acr.TrainingRecordId__c = csvRecordData[0];
            if(String.isBlank(acr.TrainingRecordId__c)){
                break;
            }
            acr.AccountId = String.isBlank(csvRecordData[1]) ? null : csvRecordData[1];
            acr.ContactId = String.isBlank(csvRecordData[2]) ? null : csvRecordData[2];
            acr.Roles = String.isBlank(csvRecordData[3]) ? null : csvRecordData[3];
            acr.StartDate = String.isBlank(csvRecordData[4]) ? null : createDate(csvRecordData[4]);
            acr.EndDate = String.isBlank(csvRecordData[5]) ? null : createDate(csvRecordData[5]);

            upsertList.add(acr);
        }

        try{
            upsert upsertList TrainingRecordId__c;
        } catch(Exception e){
            throw new AuraHandledException('There was a problem upserting Account Contact Relations: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void upsertBusinessAccounts(String staticResourceName){
        List<Account> upsertList = new List<Account>();
        List<String> csvFileLines = readCsv(staticResourceName);

        for(Integer i = 1; i < csvFileLines.size(); i++){
            List<String> csvRecordData = csvFileLines[i].split(',');
            Account ba = new Account();
            ba.TrainingRecordId__c = csvRecordData[0];
            if(String.isBlank(ba.TrainingRecordId__c)){
                break;
            }
            ba.Name = csvRecordData[1];
            ba.AccountSource = String.isBlank(csvRecordData[2]) ? null : csvRecordData[2];
            ba.Agency__c = String.isBlank(csvRecordData[3]) ? null : csvRecordData[3];
            ba.Dissolved__c = Boolean.valueOf(csvRecordData[4]);
            ba.NumberOfEmployees = String.isBlank(csvRecordData[5]) ? null : Integer.valueOf(csvRecordData[5]);
            ba.Form_of_Business__c = String.isBlank(csvRecordData[6]) ? null : csvRecordData[6];
            ba.Industry = String.isBlank(csvRecordData[7]) ? null : csvRecordData[7];
            ba.Primary_Spoken_Language__c = String.isBlank(csvRecordData[8]) ? null : csvRecordData[8];
            ba.Representative__c = String.isBlank(csvRecordData[9]) ? null : csvRecordData[9];
            ba.Representative_Position__c = String.isBlank(csvRecordData[10]) ? null : csvRecordData[10];
            ba.Maintain_Threat_Alert__c = Boolean.valueOf(csvRecordData[11]);
            ba.Written_Language__c = String.isBlank(csvRecordData[12]) ? null : csvRecordData[12];
            ba.RecordTypeId = String.isBlank(csvRecordData[13]) ? null : csvRecordData[13];
            ba.BillingCity = String.isBlank(csvRecordData[14]) ? null : csvRecordData[14];
            ba.BillingCountryCode = String.isBlank(csvRecordData[15]) ? null : csvRecordData[15];
            ba.BillingState = String.isBlank(csvRecordData[16]) ? null : csvRecordData[16];
            ba.BillingStateCode = String.isBlank(csvRecordData[17]) ? null : csvRecordData[17];
            ba.Mailing_Name__c = String.isBlank(csvRecordData[18]) ? null : csvRecordData[18];
            ba.PIR_Date__c = String.isBlank(csvRecordData[19]) ? null : createDate(csvRecordData[19]);
            ba.Secondary_Spoken_Language__c = String.isBlank(csvRecordData[20]) ? null : csvRecordData[20];
            ba.Source__c = String.isBlank(csvRecordData[21]) ? null : csvRecordData[21];
            ba.Taxpayer_ID_Type__c = String.isBlank(csvRecordData[22]) ? null : csvRecordData[22];
            ba.Website = String.isBlank(csvRecordData[23]) ? null : csvRecordData[23];
            ba.BillingStreet = String.isBlank(csvRecordData[24]) ? null : csvRecordData[24];
            ba.BillingPostalCode = String.isBlank(csvRecordData[25]) ? null : csvRecordData[25];
            ba.ShippingCountryCode = String.isBlank(csvRecordData[26]) ? null : csvRecordData[26];
            ba.ShippingStreet = String.isBlank(csvRecordData[27]) ? null : csvRecordData[27];
            ba.ShippingCity = String.isBlank(csvRecordData[28]) ? null : csvRecordData[28];
            ba.ShippingPostalCode = String.isBlank(csvRecordData[29]) ? null : csvRecordData[29];
            ba.ShippingState = String.isBlank(csvRecordData[30]) ? null : csvRecordData[30];
            ba.ShippingStateCode = String.isBlank(csvRecordData[31]) ? null : csvRecordData[31];
            ba.COI_Account__c = String.isBlank(csvRecordData[32]) ? null : csvRecordData[32];
            ba.COI_Account_Person__c = String.isBlank(csvRecordData[33]) ? null : csvRecordData[33];
            ba.Greeting__c = String.isBlank(csvRecordData[34]) ? null : csvRecordData[34];
            ba.PIR_Outcome__c = String.isBlank(csvRecordData[35]) ? null : csvRecordData[35];

            upsertList.add(ba);
        }

        try{
            upsert upsertList TrainingRecordId__c;
        } catch(Exception e){
            throw new AuraHandledException('There was a problem resetting Business Accounts: ' + e.getMessage());
        }
    }

    //There's a method that upserts every object, but I didn't include the rest here. 
}