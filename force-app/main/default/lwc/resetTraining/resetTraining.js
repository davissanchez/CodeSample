/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This LWC opens the trainingResetModal component, and when prompted deletes all records created
* by trainees and upserts all records native to the training system to their original state.
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
import { LightningElement } from "lwc";
import resetTrainingModal from "c/resetTrainingModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import upsertProducers from "@salesforce/apex/ResetTrainingUpserts.upsertProducers";
import upsertArchivedNotes from "@salesforce/apex/ResetTrainingUpserts.upsertArchivedNotes";
import upsertInsurancePolicyParticipants from "@salesforce/apex/ResetTrainingUpserts.upsertInsurancePolicyParticipants";
import upsertInsurancePolicies from "@salesforce/apex/ResetTrainingUpserts.upsertInsurancePolicies";
import upsertClaims from "@salesforce/apex/ResetTrainingUpserts.upsertClaims";
import upsertContactPointEmails from "@salesforce/apex/ResetTrainingUpserts.upsertContactPointEmails";
import upsertContactPointPhones from "@salesforce/apex/ResetTrainingUpserts.upsertContactPointPhones";
import upsertAccountContactRelations from "@salesforce/apex/ResetTrainingUpserts.upsertAccountContactRelations";
import upsertAssociatedLocations from "@salesforce/apex/ResetTrainingUpserts.upsertAssociatedLocations";
import upsertLocations from "@salesforce/apex/ResetTrainingUpserts.upsertLocations";
import upsertLeads from "@salesforce/apex/ResetTrainingUpserts.upsertLeads";
import upsertContacts from "@salesforce/apex/ResetTrainingUpserts.upsertContacts";
import upsertHouseholdAccounts from "@salesforce/apex/ResetTrainingUpserts.upsertHouseholdAccounts";
import upsertIndividualAccounts from "@salesforce/apex/ResetTrainingUpserts.upsertIndividualAccounts";
import upsertUserAccounts from "@salesforce/apex/ResetTrainingUpserts.upsertUserAccounts";
import upsertBusinessAccounts from "@salesforce/apex/ResetTrainingUpserts.upsertBusinessAccounts";
import upsertTasks from "@salesforce/apex/ResetTrainingUpserts.upsertTasks";
import upsertOpportunities from "@salesforce/apex/ResetTrainingUpserts.upsertOpportunities";
import upsertEvents from "@salesforce/apex/ResetTrainingUpserts.upsertEvents";
import deleteRecords from "@salesforce/apex/ResetTrainingDeletes.deleteRecords";
import checkJobStatuses from "@salesforce/apex/ResetTrainingDeletes.checkJobStatuses";

export default class ResetTrainingEnvironment extends LightningElement {
  isLoading = false;

  async handleClick() {
    const result = await resetTrainingModal.open({
      size: "medium",
      description: "Are you sure you want to reset the training environment?",
    });

    if (result == "reset") {
        this.isLoading = true;
        await Promise.all([this.massDelete(),this.upsertRecords()]);
        this.showToast("The training environment has been successfully reset.", "success");
        this.isLoading = false;
    }
  }

  async massDelete() {
    const taskJob = await deleteRecords({ sObjectApiName: "Task" });
    const eventJob = await deleteRecords({ sObjectApiName: "Event" });
    const noteJob = await deleteRecords({ sObjectApiName: "Archived_Note__c" });
    const ippJob = await deleteRecords({ sObjectApiName: "InsurancePolicyParticipant" });
    const acrJob = await deleteRecords({ sObjectApiName: "AccountContactRelation" });
    const alJob = await deleteRecords({ sObjectApiName: "AssociatedLocation" });
    const cpeJob = await deleteRecords({ sObjectApiName: "ContactPointEmail" });
    const cppJob = await deleteRecords({ sObjectApiName: "ContactPointPhone" });
    const oppJob = await deleteRecords({ sObjectApiName: "Opportunity" });
    const claimJob = await deleteRecords({ sObjectApiName: "Claim" });
    let jobIds = [taskJob, eventJob, noteJob, ippJob, acrJob, alJob, cpeJob, cppJob, oppJob, claimJob];
    await this.checkSuccess(jobIds);

    const producerJob = await deleteRecords({ sObjectApiName: "Producer" });
    const ipJob = await deleteRecords({ sObjectApiName: "InsurancePolicy" });
    const locJob = await deleteRecords({ sObjectApiName: "Location" });
    const leadJob = await deleteRecords({ sObjectApiName: "Lead" });
    const conJob = await deleteRecords({ sObjectApiName: "Contact" });
    jobIds = [producerJob, ipJob, locJob, leadJob, conJob];
    await this.checkSuccess(jobIds);
    
    const accJob = await deleteRecords({ sObjectApiName: "Account" });
    jobIds = [accJob];
    await this.checkSuccess(jobIds);
  }

  async checkSuccess(jobIds) {
    try{
      const isSuccess = await checkJobStatuses({ jobIds: jobIds } );
      if (isSuccess) {
        return;
      } else {
        await this.delay();
        await this.checkSuccess(jobIds);
      }
    } catch (error) {
      const message = error.body.message;
      this.showToast(message, "error");
      console.log(message);
    } 
  }

  async upsertRecords() {
    try{
      await Promise.all([
        upsertArchivedNotes({ staticResourceName: "Training_ArchivedNotes" }),
        upsertHouseholdAccounts({ staticResourceName: "Training_HouseholdAccounts" }), 
        upsertIndividualAccounts({ staticResourceName: "Training_IndividualAccounts" }), 
        upsertUserAccounts({ staticResourceName: "Training_UserAccounts" }),
        upsertBusinessAccounts({ staticResourceName: "Training_BusinessAccounts" }),
        upsertClaims({ staticResourceName: "Training_Claims" }),
        upsertLocations({ staticResourceName: "Training_Locations" }),
        upsertLeads({ staticResourceName: "Training_Leads" }),
        upsertContacts({ staticResourceName: "Training_Contacts" }),
        upsertInsurancePolicies({ staticResourceName: "Training_InsurancePolicies" }),
        upsertProducers({ staticResourceName: "Training_Producers" }),
        upsertOpportunities({ staticResourceName: "Training_Opportunities" }),
        upsertInsurancePolicyParticipants({ staticResourceName: "Training_InsurancePolicyParticipants" }),
        upsertContactPointEmails({ staticResourceName: "Training_ContactPointEmails" }),
        upsertContactPointPhones({ staticResourceName: "Training_ContactPointPhones" }),
        upsertAccountContactRelations({ staticResourceName: "Training_AccountContactRelations" }),
        upsertAssociatedLocations({ staticResourceName: "Training_AssociatedLocations" }),
        upsertTasks({ staticResourceName: "Training_Tasks" }),
        upsertEvents({ staticResourceName: "Training_Events" }),
      ]);
    } catch(error) {
      const message = error.body.message;
      this.showToast(message, "error");
      console.log(message);
    }
  }

  delay() {
    return new Promise(resolve => setTimeout(resolve, 1000));
  }

  showToast(message, variant) {
    const event = new ShowToastEvent({
      message: message,
      variant: variant,
    });
    this.dispatchEvent(event);
  }
}