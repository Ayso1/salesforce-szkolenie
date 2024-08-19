({
    fetchProducts: function(component) {
        let action = component.get("c.getProductsByFamily");
        action.setParams({ productFamily: 'Design Services' });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.products", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})
