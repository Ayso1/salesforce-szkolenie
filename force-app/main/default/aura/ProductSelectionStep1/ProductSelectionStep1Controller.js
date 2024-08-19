({
    doInit: function(component, event, helper) {
        helper.fetchProducts(component);
    },

    goToNextStep: function(component, event, helper) {
        let selectedProducts = [];
        let inputs = component.find("checkbox");
        inputs.forEach(input => {
            if(input.get("v.checked")) {
                selectedProducts.push(input.get("v.value"));
            }
        });
        component.set("v.selectedProducts", selectedProducts);
        // navigate to the next screen
    }
})
