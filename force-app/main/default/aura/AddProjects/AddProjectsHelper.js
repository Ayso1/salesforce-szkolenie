({
    fetchProducts: function(component) {
        let action = component.get("c.getAllProducts");

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let products = response.getReturnValue();

                let designServices = [];
                let renovationServices = [];
                let furnitureFittings = [];
                let furnishingFittingsInstallation = [];
                let materials = [];

                products.forEach(product => {
                    switch (product.Family) {
                        case 'Design Services':
                            designServices.push(product);
                            break;
                        case 'Renovation Services':
                            renovationServices.push(product);
                            break;
                        case 'Furniture & Fittings':
                            furnitureFittings.push(product);
                            break;
                        case 'Furnishing & Fittings Installation':
                            furnishingFittingsInstallation.push(product);
                            break;
                        case 'Materials':
                            materials.push(product);
                            break;
                    }
                });

                component.set("v.designServices", designServices);
                component.set("v.renovationServices", renovationServices);
                component.set("v.furnitureFittings", furnitureFittings);
                component.set("v.furnishingFittingsInstallation", furnishingFittingsInstallation);
                component.set("v.materials", materials);
            } else {
                console.error("Failed to fetch products.");
            }
        });
        $A.enqueueAction(action);
    },

    saveSelectedProductsAndTime: function(component, selectedProducts, realizationTime) {
        let action = component.get("c.saveSelectedProductsAndTime");
        action.setParams({ selectedProductIds: selectedProducts, realizationTime: realizationTime });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
            } else {
                console.error("Failed to save selected products and realization time.");
            }
        }),

        $A.enqueueAction(action);
    },

     getSelectedProducts: function(selectedProductIds, products) {
            return products.filter(product => selectedProductIds.includes(product.Id));
     }

})