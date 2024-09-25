import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { CurrentPageReference } from 'lightning/navigation';
import hasExternalProduct from '@salesforce/apex/NewCaseHelper.hasExternalProduct';
import sendCaseEvent from '@salesforce/apex/CaseEventCallout.sendCaseEvent';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import NewCaseLabel from "@salesforce/label/c.New_Case_Label";
import Cancel from "@salesforce/label/c.Cancel_Button";
import Save from "@salesforce/label/c.Save_Label";
import ErrorChecking from "@salesforce/label/c.Error_Checking_External_Product";
import ErrorCreating from "@salesforce/label/c.Error_Creating_Case";
import CreatedSuccessfully from "@salesforce/label/c.Case_Created_Successfully";

export default class NewCase extends LightningElement {
    channelName = '/event/Response_Data__e';
    subscription = {};
    orderId;
    subject = '';
    description = '';
    isLoading = false;

    label = {
        NewCaseLabel,
        Cancel,
        Save,
        ErrorChecking,
        ErrorCreating,
        CreatedSuccessfully,
    };

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.orderId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        this.registerErrorListener();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleFieldChange(event) {
        const fieldName = event.target.fieldName;
        if (fieldName === 'Subject') {
            this.subject = event.target.value;
        } else if (fieldName === 'Description') {
            this.description = event.target.value;
        }
    }

    async handleSubmit(event) {
        event.preventDefault();
        this.isLoading = true;
        try {
            const hasExternal = await hasExternalProduct({ orderId: this.orderId });
            if (hasExternal) {
                await sendCaseEvent({ subject: this.subject, description: this.description });

                this.handleSubscribe();
            } else {
                this.template.querySelector('lightning-record-edit-form').submit();
            }
        } catch (error) {
            console.error('Error checking external product:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: this.label.ErrorChecking,
                variant: 'error'
            }));
            this.isLoading = false;
        }
    }

    handleSuccess(event) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: this.label.CreatedSuccessfully,
            variant: 'success'
        }));
        this.closeModal();
    }

    handleError(event) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: this.label.ErrorCreating,
            variant: 'error'
        }));
    }

    handleCancel() {
        this.closeModal();
    }

    closeModal() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSubscribe() {
        const messageCallback = (response) => {
            console.log('New event received: ', JSON.stringify(response));
            const responseData = response.data.payload.Response_Body__c;

            if (responseData.includes('Success')) {

                this.template.querySelector('lightning-record-edit-form').submit();
            } else {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: responseData,
                    variant: 'error'
                }));
            }

            this.isLoading = false;
            this.handleUnsubscribe();
        };

        subscribe(this.channelName, -1, messageCallback)
            .then(response => {
                console.log('Subscription request sent to: ', JSON.stringify(response.channel));
                this.subscription = response;
            });
    }

    handleUnsubscribe() {
        if (this.subscription) {
            unsubscribe(this.subscription, response => {
                console.log('Unsubscribed from channel: ', response);
            });
        }
    }

    registerErrorListener() {
        onError(error => {
            console.error('EMP API error: ', JSON.stringify(error));
            this.isLoading = false;
        });
    }
}
