({
    doInit: function(component, event, helper) {
        helper.fetchProducts(component);
        let today = new Date().toISOString().split('T')[0];
        component.set("v.todayDate", today);
    },

    handleCheckboxChangeStep0: function(component, event, helper) {
            let checkboxes = component.find("checkbox");
            let isNextButtonDisabled = true;

            if (Array.isArray(checkboxes)) {
                isNextButtonDisabled = !checkboxes.some(checkbox => checkbox.get("v.checked"));
            } else {
                isNextButtonDisabled = !checkboxes.get("v.checked");
            }

            component.set("v.isNextButtonDisabledStep0", isNextButtonDisabled);
        },

    handleDateChange: function(component, event, helper) {
           let realizationTime = component.find("realizationTime").get("v.value");
           let today = component.get("v.todayDate");

           if (realizationTime && realizationTime >= today) {
               component.set("v.isNextButtonDisabled", false);
           } else {
               component.set("v.isNextButtonDisabled", true);
           }
       },

     toggleSelectAll: function(component, event, helper) {
             let selectAll = event.getSource().get("v.checked");
             let checkboxes = component.find("checkbox");

             if (Array.isArray(checkboxes)) {
                 checkboxes.forEach(function(checkbox) {
                     checkbox.set("v.checked", selectAll);
                 });
             } else if (checkboxes) {
                 checkboxes.set("v.checked", selectAll);
             }
     },

    goToNextStep: function(component, event, helper) {
        let selectedProductsStep0 = [];
        let checkboxesStep0 = component.find("checkbox");

        if (Array.isArray(checkboxesStep0)) {
            checkboxesStep0.forEach(checkbox => {
                if (checkbox.get("v.checked")) {
                    selectedProductsStep0.push(checkbox.get("v.value"));
                }
            });
        } else {
            if (checkboxesStep0.get("v.checked")) {
                selectedProductsStep0.push(checkbox.get("v.value"));
            }
        }

        component.set("v.selectedProducts", selectedProductsStep0);
        component.set("v.currentStep", 1);
    },

    saveAndGoToNextStep: function(component, event, helper) {
        let selectedProductsStep1 = [];
        let checkboxesStep1 = component.find("checkbox");

        if (Array.isArray(checkboxesStep1)) {
            checkboxesStep1.forEach(checkbox => {
                if (checkbox.get("v.checked")) {
                    selectedProductsStep1.push(checkbox.get("v.value"));
                }
            });
        } else {
            if (checkboxesStep1.get("v.checked")) {
                selectedProductsStep1.push(checkbox.get("v.value"));
            }
        }

        let allSelectedProducts = component.get("v.selectedProducts");
        allSelectedProducts = allSelectedProducts.concat(selectedProductsStep1);

        component.set("v.selectedProducts", allSelectedProducts);
        component.set("v.currentStep", 2);
    },

    saveFinalStep: function(component, event, helper) {
        let realizationTime = component.find("realizationTime").get("v.value");
        let selectedProducts = component.get("v.selectedProducts");

        component.set("v.realizationTime", realizationTime);

        let designServices = component.get("v.designServices");
        let renovationServices = component.get("v.renovationServices");
        let furnitureFittings = component.get("v.furnitureFittings");
        let furnishingFittingsInstallation = component.get("v.furnishingFittingsInstallation");
        let materials = component.get("v.materials");

        component.set("v.filteredDesignServices", helper.getSelectedProducts(selectedProducts, designServices));
        component.set("v.filteredRenovationServices", helper.getSelectedProducts(selectedProducts, renovationServices));
        component.set("v.filteredFurnitureFittings", helper.getSelectedProducts(selectedProducts, furnitureFittings));
        component.set("v.filteredFurnishingFittingsInstallation", helper.getSelectedProducts(selectedProducts, furnishingFittingsInstallation));
        component.set("v.filteredMaterials", helper.getSelectedProducts(selectedProducts, materials));

        component.set("v.currentStep", 3);
    },

    finishProcess: function(component, event, helper) {
            let realizationTime = component.get("v.realizationTime");
            let selectedProducts = component.get("v.selectedProducts");
            let oppId = component.get("v.recordId");

            let action = component.get("c.saveSelectedProductsAndTime");
            action.setParams({
                selectedProductIds: selectedProducts,
                realizationTime: realizationTime,
                oppId: oppId
            });

            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    let closeAction = $A.get("e.force:closeQuickAction");
                    closeAction.fire();
                    component.find('notifLib').showToast({
                                        "title": "Success",
                                        "message": "Tasks have been created successfully.",
                                        "variant": "success"
                    });
                } else {
                    console.error("Failed to create task.");
                }
            });

            $A.enqueueAction(action);
        }
})
