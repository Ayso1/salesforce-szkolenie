({
    doInit: function(component, event, helper) {
        helper.fetchProjects(component);
        helper.setTodayDate(component);
    },

    handleCheckboxChangeStep0: function(component, event, helper) {
        helper.toggleNextButtonStep0(component);
    },

    goToNextStep: function(component, event, helper) {
        helper.handleNextStep(component);
    },

    goToPreviousStep: function(component, event, helper) {
        helper.handlePreviousStep(component);
    },

    toggleSelectAll: function(component, event, helper) {
       helper.selectAllProducts(component, event);
    },

    handleSelect: function(component, event, helper) {
        helper.handleTableSelection(component);
    },

    handleSave: function(component, event, helper) {
        helper.saveDraftValues(component, event);
    },

    handleInputChange: function(component, event, helper) {
        helper.updateRealizationDateVisibility(component);
    },

    handleDateChange: function(component, event, helper) {
        helper.validateRealizationDate(component);
    },

    handleStartDateChange: function(component, event, helper) {
          helper.updateRealizationDate(component);
    },

    saveAndGoToNextStep: function(component, event, helper) {
        helper.handleSaveAndProceed(component);
    },

    finishProcess: function(component, event, helper) {
        helper.finishProcess(component);
    }
})