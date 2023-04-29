/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This modal is opened by the resetTraining LWC and starts the training system reset when the 'Reset
* Training Records' button is pushed.
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
import LightningModal from 'lightning/modal';

export default class ResetTrainingModal extends LightningModal {
    handleCancel(){
        this.close('cancel');
    }
    handleReset(){
        this.close('reset');
    }
}