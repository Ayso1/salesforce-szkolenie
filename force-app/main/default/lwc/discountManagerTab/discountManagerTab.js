import { LightningElement, track, wire } from 'lwc';
import {
    IsConsoleNavigation,
    getFocusedTabInfo,
    refreshTab
} from 'lightning/platformWorkspaceApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductOptions from '@salesforce/apex/ProductController.getProductOptions';
import getDiscountTypeOptions from '@salesforce/apex/ProductController.getDiscountTypeOptions';
import getDiscountTypes from '@salesforce/apex/ProductController.getDiscountTypes';
import applyDiscountToProduct from '@salesforce/apex/ProductController.applyDiscountToProduct';
import createDiscountType from '@salesforce/apex/ProductController.createDiscountType';
import DiscountManagementLabel from "@salesforce/label/c.Discount_Management_Label";
import AddDiscountLabel from "@salesforce/label/c.Add_Discount_Label";
import CreateDiscountType from "@salesforce/label/c.Create_Discount_Type_Label";
import ProductDiscountManagement from "@salesforce/label/c.Product_Discount_Management_Label";
import SelectProduct from "@salesforce/label/c.Select_Product_Label";
import SelectDiscountType from "@salesforce/label/c.Select_Discount_Type_Label";
import DiscountValuePercentage from "@salesforce/label/c.Discount_Value_Percentage_Label";
import DiscountUnit from "@salesforce/label/c.Discount_Unit_Label";
import ApplyDiscount from "@salesforce/label/c.Apply_Discount_Label";
import DiscountTypes from "@salesforce/label/c.Discount_Types_Label";
import CreateNewDiscountType from "@salesforce/label/c.Create_New_Discount_Type_Label";
import DiscountValuePercentagePlaceholder from "@salesforce/label/c.DiscountValuePercentage_Placeholder_Label";
import ErrorFetchingProductLabel from "@salesforce/label/c.Error_Fetching_Product_Label";
import DiscountAppliedSuccessfully from "@salesforce/label/c.Discount_Applied_Successfully_Label";
import ErrorApplyingDiscount from "@salesforce/label/c.Error_Applying_Discount_Label";
import ErrorLoadingDiscountTypes from "@salesforce/label/c.Error_Loading_Discount_Types_Label";
import Value from "@salesforce/label/c.Value_Label";
import Percent from "@salesforce/label/c.Percent_Label";
import Name from "@salesforce/label/c.Name_Label";
import StartDate from "@salesforce/label/c.Start_Date_Label";
import EndDate from "@salesforce/label/c.End_Date_Label";
import RecurringDiscount from "@salesforce/label/c.Recurring_Discount_Label";
import DiscountPeriod from "@salesforce/label/c.Discount_Period_Label";

export default class DiscountManagerTab extends LightningElement {

    label = {
        DiscountManagementLabel,
        AddDiscountLabel,
        CreateDiscountType,
        ProductDiscountManagement,
        SelectProduct,
        SelectDiscountType,
        DiscountValuePercentage,
        DiscountUnit,
        ApplyDiscount,
        DiscountTypes,
        CreateNewDiscountType,
        DiscountValuePercentagePlaceholder,
        ErrorFetchingProductLabel,
        DiscountAppliedSuccessfully,
        ErrorApplyingDiscount,
        ErrorLoadingDiscountTypes,
        Value,
        Percent,
        Name,
        StartDate,
        EndDate,
        RecurringDiscount,
        DiscountPeriod,
    };

    @track selectedProduct = '';
    @track selectedDiscountType = '';
    @track discountValue = '';
    @track selectedDiscountUnit = this.label.Value;

    @track selectedNavItem = 'add_discount';
    @track isAddDiscountVisible = true;
    @track isModalOpen = false;

    @track productOptions = [];
    @track discountTypeOptions = [];
    @track discountTypeData = [];

    @track isAddDiscountVisible = true;
    @track isCreateDiscountTypeVisible = false;

    @wire(getProductOptions)
    wiredProducts({ error, data }) {
        if (data) {
            this.productOptions = data.map(product => {
                return { label: product.label, value: product.value };
            });
        } else if (error) {
            this.showToast('Error', this.label.ErrorFetchingProductLabel, 'error');
        }
    }

    @wire(getDiscountTypeOptions)
    wiredDiscountTypes({ error, data }) {
        if (data) {
            this.discountTypeOptions = data.map(discountType => {
                return { label: discountType.label, value: discountType.value };
            });
        }
    }
    handleNavigation(event) {
        const selectedItem = event.currentTarget.name;

         this.selectedNavItem = selectedItem;
          if (selectedItem === 'add_discount') {
                 this.showAddDiscountSection();
          } else if (selectedItem === 'create_discount_type') {
              this.showCreateDiscountTypeSection();
          }
    }

    handleProductChange(event) {
        this.selectedProduct = event.detail.value;
        this.selectedDiscountType = '';
        this.discountValue = '';
    }

    handleDiscountTypeChange(event) {
        this.selectedDiscountType = event.detail.value;
        this.discountValue = '';
    }

    handleDiscountValueChange(event) {
        this.discountValue = event.detail.value;
    }

    handleDiscountUnitChange(event) {
        this.selectedDiscountUnit = event.detail.value;
    }

    get isDiscountTypeDisabled() {
        return !this.selectedProduct;
    }

    get isDiscountValueDisabled() {
        return !this.selectedDiscountType;
    }

    get isApplyButtonDisabled() {
        return !this.discountValue;
    }

    async applyDiscount() {
        try {
            await applyDiscountToProduct({
                productId: this.selectedProduct,
                discountType: this.selectedDiscountType,
                discountValue: this.discountValue,
                discountUnit: this.selectedDiscountUnit
            });
            this.showToast('Success', this.label.DiscountAppliedSuccessfully, 'success');
            this.resetForm();
        } catch (error) {
            this.showToast('Error', this.label.ErrorApplyingDiscount, 'error');
            console.error('Error applying discount:', error);
        }
    }

    showAddDiscountSection() {
        this.isAddDiscountVisible = true;
        this.isCreateDiscountTypeVisible = false;
    }

    showCreateDiscountTypeSection() {
        this.isAddDiscountVisible = false;
        this.isCreateDiscountTypeVisible = true;
        this.loadDiscountTypes();
    }

    async loadDiscountTypes() {
        try {
            const data = await getDiscountTypes();
            this.discountTypeData = data.map(record => ({
                id: record.Id,
                name: record.Name,
                startDate: record.Start_Date__c,
                endDate: record.End_Date__c,
                recurringDiscount: record.Recurring_Discount__c,
                discountPeriod: record.Discount_Period__c
            }));
        } catch (error) {
            this.showToast('Error', this.label.ErrorLoadingDiscountTypes, 'error');
            console.error('Error loading discount types:', error);
        }
    }

    get discountUnitOptions() {
        return [
            { label: this.label.Value, value: this.label.Value },
            { label: this.label.Percent, value: this.label.Percent }
        ];
    }

    get discountTypeColumns() {
        return [
            { label: this.label.Name, fieldName: 'name' },
            { label: this.label.StartDate, fieldName: 'startDate', type: 'date' },
            { label: this.label.EndDate, fieldName: 'endDate', type: 'date' },
            { label: this.label.RecurringDiscount, fieldName: 'recurringDiscount', type: 'boolean' },
            { label: this.label.DiscountPeriod, fieldName: 'discountPeriod' }
        ];
    }

     connectedCallback() {
        this.isAddDiscountVisible = true;
        this.isCreateDiscountTypeVisible = false;
    }

     handleOpenModal() {
        this.isModalOpen = true;
     }

     handleCloseModal() {
        this.isModalOpen = false;
     }

    resetForm() {
        this.selectedProduct = '';
        this.selectedDiscountType = '';
        this.discountValue = '';
        this.selectedDiscountUnit = this.label.Value;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}
