import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createDiscountType from '@salesforce/apex/ProductController.createDiscountType';
import getPicklistOptions from '@salesforce/apex/ProductController.getPicklistOptions';
import Name from "@salesforce/label/c.Name_Label";
import StartDate from "@salesforce/label/c.Start_Date_Label";
import EndDate from "@salesforce/label/c.End_Date_Label";
import CreateNewDiscountType from "@salesforce/label/c.Create_New_Discount_Type_Label";
import RecurringDiscount from "@salesforce/label/c.Recurring_Discount_Label";
import DiscountPeriod from "@salesforce/label/c.Discount_Period_Label";
import Cancel from "@salesforce/label/c.Cancel_Button";
import Save from "@salesforce/label/c.Save_Label";
import Yes from "@salesforce/label/c.Yes_Label";
import NameRequired from "@salesforce/label/c.Name_Required_Label";
import DiscountPeriodRequired from "@salesforce/label/c.Discount_Period_Required_Label";
import StartDateRequired from "@salesforce/label/c.Start_Date_Required_Label";
import EndDateRequired from "@salesforce/label/c.End_Date_Required_Label";
import DiscountTypeCreatedSuccessfully from "@salesforce/label/c.Discount_Type_Created_Successfully_Label";
import Close from "@salesforce/label/c.Close_Label";

export default class DiscountTypeModal extends LightningElement {
    @track name = '';
    @track startDate = '';
    @track endDate = '';
    @track recurringDiscount = [];
    @track discountPeriod = '';
    @track dayOfWeek = '';
    @track month = '';
    @track specificDay = '';
    @track specificDayMonth = '';
    @track specificStartDate = '';
    @track specificEndDate = '';
    @track discountPeriodOptions = [];
    @track dayOfWeekOptions = [];
    @track monthOptions = [];

    label = {
        Name,
        StartDate,
        EndDate,
        CreateNewDiscountType,
        RecurringDiscount,
        DiscountPeriod,
        Cancel,
        Save,
        Yes,
        Close,
        NameRequired,
        DiscountPeriodRequired,
        StartDateRequired,
        EndDateRequired,
        DiscountTypeCreatedSuccessfully,
    }

    @wire(getPicklistOptions, { objectName: 'Discount_Type__c', fieldName: 'Discount_Period__c' })
    wiredDiscountPeriodOptions({ error, data }) {
        if (data) {
            this.discountPeriodOptions = data.map(option => ({
                label: option,
                value: option
            }));
        } else if (error) {
            console.error('Error fetching discount period options:', error);
        }
    }

    @wire(getPicklistOptions, { objectName: 'Discount_Type__c', fieldName: 'Day_Of_Week__c' })
    wiredDayOfWeekOptions({ error, data }) {
        if (data) {
            this.dayOfWeekOptions = data.map(option => ({
                label: option,
                value: option
            }));
        } else if (error) {
            console.error('Error fetching day of week options:', error);
        }
    }

    @wire(getPicklistOptions, { objectName: 'Discount_Type__c', fieldName: 'Month__c' })
    wiredMonthOptions({ error, data }) {
        if (data) {
            this.monthOptions = data.map(option => ({
                label: option,
                value: option
            }));
        } else if (error) {
            console.error('Error fetching month options:', error);
        }
    }

    get recurringDiscountOptions() {
        return [
            { label: this.label.Yes, value: 'true' }
        ];
    }

    get isStartDateDisabled() {
        if(this.discountPeriod == 'Specific Date Range'){
             return false;
        }
        return this.recurringDiscount.includes('true');
    }

    get isEndDateDisabled() {
        if(this.discountPeriod == 'Specific Date Range'){
            return false;
        }
        return this.recurringDiscount.includes('true');
    }

    get isDiscountPeriodDisabled() {
        return !this.recurringDiscount.includes('true');
    }

    handleNameChange(event) {
        this.name = event.detail.value;
    }
    get isStartDateRequired() {
        return !this.recurringDiscount.includes('false');
    }

    get isEndDateRequired() {
        return !this.recurringDiscount.includes('false');
    }

    get isDiscountPeriodRequired() {
        return !this.recurringDiscount.includes('false');
    }

    handleStartDateChange(event) {
        this.startDate = event.detail.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.detail.value;
    }

    handleRecurringDiscountChange(event) {
        this.recurringDiscount = event.detail.value;
        if (this.recurringDiscount.includes('true')) {
            this.startDate = '';
            this.endDate = '';
        }else{
            this.discountPeriod = '';
            this.dayOfWeek = '';
            this.specificDay = '';
            this.specificDayMonth = '';
            this.specificStartDate = '';
            this.specificEndDate = '';
        }
    }

    handleDiscountPeriodChange(event) {
        this.discountPeriod = event.detail.value;
        if (this.discountPeriod !== 'Specific Date Range') {
            this.specificStartDate = '';
            this.specificEndDate = '';
        }
    }

    handleDayOfWeekChange(event) {
        this.dayOfWeek = event.detail.value;
    }

    handleMonthChange(event) {
        this.month = event.detail.value;
    }

    handleSpecificDayChange(event) {
        this.specificDay = event.detail.value;
    }

    handleSpecificDayMonthChange(event) {
        this.specificDayMonth = event.detail.value;
    }

    handleSpecificStartDateChange(event) {
        this.specificStartDate = event.detail.value;
    }

    handleSpecificEndDateChange(event) {
        this.specificEndDate = event.detail.value;
    }

    get isDayOfWeek() {
        return this.discountPeriod === 'Day of Week';
    }

    get isMonth() {
        return this.discountPeriod === 'Month';
    }

    get isSpecificDay() {
        return this.discountPeriod === 'Specific DD';
    }

    get isSpecificDayMonth() {
        return this.discountPeriod === 'Specific DD.MM';
    }

    get isSpecificDateRange() {
        return this.discountPeriod === 'Specific Date Range';
    }

    convertToDecimal(value) {
        const num = parseFloat(value);
        return isNaN(num) ? null : num;
    }


    async handleSave() {
        let isValid = true;
        let errorMessage = '';

        if (!this.name) {
            isValid = false;
            errorMessage += this.label.NameRequired + '\n';
        }

        if (this.recurringDiscount.includes('true')) {
            if (!this.discountPeriod) {
                isValid = false;
                errorMessage += this.label.DiscountPeriodRequired + '\n';
            }
        } else {
            if (!this.startDate) {
                isValid = false;
                errorMessage += this.label.StartDateRequired + '\n';
            }
            if (!this.endDate) {
                isValid = false;
                errorMessage += this.label.EndDateRequired + '\n';
            }
        }

        if (isValid) {
            try {
                console.log(this.startDate);
                console.log(this.endDate);

                const startDate = this.startDate ? new Date(this.startDate) : null;
                const endDate = this.endDate ? new Date(this.endDate) : null;
                await createDiscountType({
                    name: this.name,
                    startDate: startDate,
                    endDate: endDate,
                    recurringDiscount: this.recurringDiscount.includes('true'),
                    discountPeriod: this.discountPeriod,
                    dayOfWeek: this.dayOfWeek,
                    month: this.month,
                    specificDay: this.convertToDecimal(this.specificDay),
                    specificDayMonth: this.specificDayMonth,
                    specificStartDate: this.specificStartDate,
                    specificEndDate: this.specificEndDate
                });

                this.showToast('Success', this.label.DiscountTypeCreatedSuccessfully, 'success');
                this.handleClose();
            } catch (error) {
                console.error('Error creating discount type:', error);
            }
        } else {
            this.showToast('Error', errorMessage.trim(), 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}
