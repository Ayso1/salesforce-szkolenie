import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import STAGE_NAME_FIELD from '@salesforce/schema/Opportunity.StageName';

export default class CreatOrderQuickAction extends LightningElement {
    wireRecordId;
    currectRecordId;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.wireRecordId = currentPageReference.state.recordId;
        }
    }

    @api set recordId(value) {
        this.currectRecordId = value;
    }

    get recordId() {
        return this.currectRecordId;
    }

    @api invoke() {
        const fields = {};
        fields['Id'] = this.currectRecordId;
        fields[STAGE_NAME_FIELD.fieldApiName] = 'Closed Won';

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Order created successfully',
                    variant: 'success'
                }));

                this.dispatchEvent(new CustomEvent('closequickaction'));
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }));
            });
    }
}
