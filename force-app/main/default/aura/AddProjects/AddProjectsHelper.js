({
    fetchProjects: function(component) {
        let action = component.get("c.getAllProjects");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let projects = response.getReturnValue();
                component.set("v.projects", projects);
            } else {
                console.error("Failed to fetch projects.");
            }
        });
        $A.enqueueAction(action);
    },

    setTodayDate: function(component) {
        let today = new Date().toISOString().split('T')[0];
        component.set("v.todayDate", today);
    },

    toggleNextButtonStep0: function(component) {
        let checkboxes = component.find("checkbox");
        let isNextButtonDisabled = true;

        if (Array.isArray(checkboxes)) {
            isNextButtonDisabled = !checkboxes.some(checkbox => checkbox.get("v.checked"));
        } else {
            isNextButtonDisabled = !checkboxes.get("v.checked");
        }

        component.set("v.isNextButtonDisabledStep0", isNextButtonDisabled);
    },

    handleNextStep: function(component) {
        let selectedProjects = [];
        let checkboxes = component.find("checkbox");

        if (Array.isArray(checkboxes)) {
            checkboxes.forEach(checkbox => {
                if (checkbox.get("v.checked")) {
                    selectedProjects.push(checkbox.get("v.value"));
                }
            });
        } else {
            if (checkboxes.get("v.checked")) {
                selectedProjects.push(checkboxes.get("v.value"));
            }
        }

        component.set("v.selectedProjects", selectedProjects);
        this.fetchProductsByProjectIds(component, selectedProjects);
        component.set("v.currentStep", 1);
    },

    handlePreviousStep: function(component) {
        let currentStep = component.get("v.currentStep");

        if (currentStep > 0) {
            component.set("v.currentStep", currentStep - 1);
        }

        if (currentStep === 1) {
            this.resetStepOneState(component);
        } else if (currentStep === 2) {
            this.restoreSelectedProducts(component);
        }
    },

    resetStepOneState: function(component) {
        let selectedProjects = component.get("v.selectedProjects");
        let checkboxes = component.find("checkbox");
        let tables = this.getTables(component);

        let isNextButtonDisabled = !selectedProjects.length;

        component.set("v.selectedProjects", []);
        component.set("v.startDate", null);
        component.set("v.realizationTime", null);
        component.set("v.isSelectRealizationDateVisible", false);
        component.set("v.isRealizationDateDisabled", true);

        tables.forEach(table => {
            component.set(table.inputAttr, '');
            component.set(table.visibleAttr, false);
        });

        component.set("v.isNextButtonDisabledStep0", isNextButtonDisabled);
        component.set("v.isNextButtonDisabledStep1", true);

        if (Array.isArray(checkboxes)) {
            checkboxes.forEach(checkbox => {
                checkbox.set("v.checked", selectedProjects.includes(checkbox.get("v.value")));
            });
        } else {
            checkboxes.set("v.checked", selectedProjects.includes(checkboxes.get("v.value")));
        }

        tables.forEach(table => {
            let tableCmp = component.find(table.tableId);
            if (tableCmp) {
                tableCmp.set("v.selectedRows", []);
            }
        });
    },

    restoreSelectedProducts: function(component) {
        let selectedProducts = component.get("v.selectedProducts");
        let tables = this.getTables(component);

        tables.forEach(table => {
            let tableCmp = component.find(table.tableId);
            if (tableCmp) {
                let selectedRows = selectedProducts.filter(product => product.ProductFamily === table.family);
                let selectedRowIds = selectedRows.map(row => row.Id);

                if (selectedRowIds.length > 0) {
                    let currentSelectedRows = tableCmp.get("v.selectedRows") || [];
                    let updatedSelectedRows = [...new Set([...currentSelectedRows, ...selectedRowIds])];

                    tableCmp.set("v.selectedRows", updatedSelectedRows);
                }
            }
        });
    },

    selectAllProducts: function(component, event) {
        let selectAll = event.getSource().get("v.checked");
        let tables = this.getTables(component);
        let allSelectedProductIds = [];

        tables.forEach(table => {
            let tableCmp = component.find(table.tableId);
            if (tableCmp) {
                let tableData = component.get(table.dataAttr);
                let selectedRowIds = selectAll ? tableData.map(product => product.Id) : [];
                tableCmp.set("v.selectedRows", selectedRowIds);

                if (selectAll) {
                    allSelectedProductIds = allSelectedProductIds.concat(selectedRowIds);
                }
                component.set(table.visibleAttr, selectAll);
            }
        });

        component.set("v.selectedProducts", selectAll ? allSelectedProductIds : []);
    },

    handleTableSelection: function(component) {
        let tables = this.getTables(component);

        tables.forEach(table => {
            let tableCmp = component.find(table.tableId);
            if (tableCmp) {
                let selectedRows = tableCmp.getSelectedRows();
                if (selectedRows.length > 0) {
                    component.set(table.visibleAttr, true);
                } else {
                    component.set(table.inputAttr, '');
                    component.set(table.visibleAttr, false);
                }
            }
        });

        let isAnyTableVisible = tables.some(table => component.get(table.visibleAttr));
        let isAnyInputFilled = this.checkIfAnyInputFilled(component);

        component.set("v.isNextButtonDisabledStep1", !(isAnyTableVisible && isAnyInputFilled));
        component.set("v.isSelectRealizationDateVisible", (isAnyTableVisible && isAnyInputFilled));
    },

    saveDraftValues: function(component, event) {
        let updatedCells = event.getParam('draftValues');
        let allProjectProducts = component.get("v.allProjectProducts");

        updatedCells.forEach(updatedCell => {
            let index = allProjectProducts.findIndex(product => product.Product__c === updatedCell.Id);
            if (index !== -1) {
                allProjectProducts[index] = Object.assign({}, allProjectProducts[index], updatedCell);
            }
        });

        component.set("v.allProjectProducts", allProjectProducts);
        component.set("v.draftValues", []);

        this.updateProductLists(component, allProjectProducts);
    },

     updateRealizationDateVisibility: function(component) {
         let isAnyInputFilled = this.checkIfAnyInputFilled(component);
         component.set("v.startDate", null);
         component.set("v.realizationTime", null);
         component.set("v.isSelectRealizationDateVisible", isAnyInputFilled);
     },

     validateRealizationDate: function(component) {
         let realizationTime = component.find("realizationTime").get("v.value");
         let today = component.get("v.todayDate");

         component.set("v.isNextButtonDisabledStep1", !(realizationTime && realizationTime >= today));
     },

     updateRealizationDate: function(component) {
         let startDate = component.find("startDate").get("v.value");
         let totalDays = 0;
         let tables = this.getTables(component);
         let inputValues = {};

         tables.forEach(table => {
             inputValues[table.tableId] = parseInt(component.get(table.inputAttr) || 0, 10);
         });

         totalDays = Object.values(inputValues).reduce((sum, value) => sum + value, 0);

         if (startDate) {
             let startDateObj = new Date(startDate);
             let realizationDateObj = new Date(startDateObj);
             realizationDateObj.setDate(startDateObj.getDate() + totalDays);
             let realizationDate = realizationDateObj.toISOString().split('T')[0];

             component.set("v.realizationTime", realizationDate);
             component.set("v.isRealizationDateDisabled", false);
             component.set("v.isNextButtonDisabledStep1", false);
         } else {
             component.set("v.isRealizationDateDisabled", true);
             component.set("v.isNextButtonDisabledStep1", true);
         }
     },

     handleSaveAndProceed: function(component) {
         let selectedProducts = this.collectSelectedProducts(component);
         let realizationTime = component.find("realizationTime").get("v.value");
         let startDate = component.find("startDate").get("v.value");
         const oppId = component.get("v.recordId");

         const action = component.get("c.createTaskAndOppProduct");
          action.setParams({
              selectedProducts: selectedProducts,
              realizationTime: realizationTime,
              startDate: startDate,
              oppId: oppId
          });

          action.setCallback(this, response => {
              const state = response.getState();
              if (state === "SUCCESS") {
                  this.handleSuccess(component);
                  component.set("v.selectedProducts", selectedProducts);
                  component.set("v.realizationTime", realizationTime);
                  component.set("v.startDate", startDate);
                  component.set("v.currentStep", 2);
              } else if (state === "ERROR") {
                  const errors = response.getError();
                  let message = "Unknown error";

                  if (errors && Array.isArray(errors) && errors.length > 0) {
                      if (errors[0].pageErrors && errors[0].pageErrors.length > 0) {
                          message = errors[0].pageErrors[0].message;
                      } else {
                          message = errors[0].message;
                      }
                  }

                  component.find('notifLib').showToast({
                      "title": "Error",
                      "message": message,
                      "variant": "error"
                  });
              }
          });

         $A.enqueueAction(action);
     },

      collectSelectedProducts: function(component) {
         let selectedProducts = [];
         let tables = this.getTables(component);

         tables.forEach(table => {
             let tableCmp = component.find(table.tableId);
             if (tableCmp) {
                 let selectedRows = tableCmp.getSelectedRows();
                 selectedRows.forEach(product => {
                     product.ProductFamily = table.family;
                     selectedProducts.push(product);
                 });
             }
         });

         return selectedProducts;
     },


     finishProcess: function(component) {
          const closeAction = $A.get("e.force:closeQuickAction");
          closeAction.fire();
     },

     handleSuccess: function(component) {
         component.find('notifLib').showToast({
             title: "Success",
             message: $A.get("$Label.c.Task_Created_Label"),
             variant: "success"
         });
     },

    getTables: function(component) {
        return [
            {
                tableId: "designServicesTable",
                family: 'Design Services',
                dataAttr: "v.designServices",
                visibleAttr: "v.isDesignServicesInputVisible",
                inputAttr: "v.inputValueDesign"
            },
            {
                tableId: "renovationServicesTable",
                family: 'Renovation Services',
                dataAttr: "v.renovationServices",
                visibleAttr: "v.isRenovationServicesTableInputVisible",
                inputAttr: "v.inputValueRenovation"
            },
            {
                tableId: "furnitureFittingsTable",
                family: 'Furniture & Fittings',
                dataAttr: "v.furnitureFittings",
                visibleAttr: "v.isFurnitureFittingsTableInputVisible",
                inputAttr: "v.inputValueFurniture"
            },
            {
                tableId: "furnishingFittingsInstallationTable",
                family: 'Furnishing & Fittings Installation',
                dataAttr: "v.furnishingFittingsInstallation",
                visibleAttr: "v.isFurnishingFittingsInstallationTableInputVisible",
                inputAttr: "v.inputValueFurnishing"
            },
            {
                tableId: "materialsTable",
                family: 'Materials',
                dataAttr: "v.materials",
                visibleAttr: "v.isMaterialsTableInputVisible",
                inputAttr: "v.inputValueMaterials"
            }
        ];
    },

    checkIfAnyInputFilled: function(component) {
        let inputValueDesign = component.get("v.inputValueDesign");
        let inputValueRenovation = component.get("v.inputValueRenovation");
        let inputValueFurniture = component.get("v.inputValueFurniture");
        let inputValueFurnishing = component.get("v.inputValueFurnishing");
        let inputValueMaterials = component.get("v.inputValueMaterials");

        return [inputValueDesign, inputValueRenovation, inputValueFurniture,
                inputValueFurnishing, inputValueMaterials].some(value => {
            return value !== null && value !== undefined && value !== '' && value !== 0;
        });
    },

   fetchProductsByProjectIds: function(component, selectedProjectIds) {
       let action = component.get("c.getProductsByProjectIds");
       action.setParams({ projectIds: selectedProjectIds });
       action.setCallback(this, function(response) {
           if (response.getState() === "SUCCESS") {
               let projectProducts = response.getReturnValue();
               let renovationServices = [];
               let furnitureFittings = [];
               let furnishingFittingsInstallation = [];
               let materials = [];
               let designServices = [];

               projectProducts.forEach(product => {
                   let flatProduct = {
                       Id: product.Product__c,
                       ProductName: product.Product__r.Name,
                       Quantity__c: product.Quantity__c,
                       ProjectName: product.Project__r.Name,
                       ProductFamily: product.Project__r.Family,
                       Price__c: product.Price__c,
                       Discount_Price__c: product.Discount_Price__c
                   };

                   let family = product.Product__r.Family;
                   switch (family) {
                       case $A.get("$Label.c.Renovation_Services_Label"):
                           renovationServices.push(flatProduct);
                           break;
                       case $A.get("$Label.c.Furniture_Fittings_Label"):
                           furnitureFittings.push(flatProduct);
                           break;
                       case $A.get("$Label.c.Furnishing_Fittings_Installation_Label"):
                           furnishingFittingsInstallation.push(flatProduct);
                           break;
                       case $A.get("$Label.c.Materials_Label"):
                           materials.push(flatProduct);
                           break;
                       case $A.get("$Label.c.Design_Services_Label"):
                           designServices.push(flatProduct);
                           break;
                   }
               });

               component.set("v.renovationServices", renovationServices);
               component.set("v.furnitureFittings", furnitureFittings);
               component.set("v.furnishingFittingsInstallation", furnishingFittingsInstallation);
               component.set("v.materials", materials);
               component.set("v.designServices", designServices);

               component.set("v.allProjectProducts", projectProducts);
               component.set("v.productColumns", [
                   { label: $A.get("$Label.c.Product_Name_Label"), fieldName: 'ProductName', type: 'text', wrapText: true },
                   { label: $A.get("$Label.c.Project_Label"), fieldName: 'ProjectName', type: 'text', wrapText: true },
                   { label: $A.get("$Label.c.Quantity_Label"), fieldName: 'Quantity__c', type: 'number',  editable: true, wrapText: true },
                   { label: $A.get("$Label.c.Price_Label"), fieldName: 'Price__c',  type: 'currency', typeAttributes: { currencyCode: 'USD' }, wrapText: true},
                   { label: $A.get("$Label.c.Discount_Price_Label"), fieldName: 'Discount_Price__c',  type: 'currency', typeAttributes: { currencyCode: 'USD' }, wrapText: true},
               ]);
               component.set("v.selectedProductsColumns", [
                   { label: $A.get("$Label.c.Product_Name_Label"), fieldName: 'ProductName', type: 'text', wrapText: true },
                   { label: $A.get("$Label.c.Project_Label"), fieldName: 'ProjectName', type: 'text', wrapText: true },
                   { label: $A.get("$Label.c.Quantity_Label"), fieldName: 'Quantity__c', type: 'number', wrapText: true },
                   { label: $A.get("$Label.c.Price_Label"), fieldName: 'Price__c',  type: 'currency', typeAttributes: { currencyCode: 'USD' }, wrapText: true},
                   { label: $A.get("$Label.c.Discount_Price_Label"), fieldName: 'Discount_Price__c',  type: 'currency', typeAttributes: { currencyCode: 'USD' }, wrapText: true},
               ]);
           } else {
               console.error("Failed to fetch project products.");
           }
       });
       $A.enqueueAction(action);
   },

    updateProductLists: function(component, allProjectProducts) {
       let renovationServices = [];
       let furnitureFittings = [];
       let furnishingFittingsInstallation = [];
       let materials = [];
       let designServices = [];

       allProjectProducts.forEach(product => {
           let flatProduct = {
               Id: product.Product__c,
               ProductName: product.Product__r.Name,
               Quantity__c: product.Quantity__c,
               ProjectName: product.Project__r.Name,
               ProductFamily: product.Product__r.Family,
               Price__c: product.Price__c,
               Discount_Price__c: product.Discount_Price__c
           };

           let family = product.Product__r.Family;
           switch (family) {
               case $A.get("$Label.c.Renovation_Services_Label"):
                   renovationServices.push(flatProduct);
                   break;
               case $A.get("$Label.c.Furniture_Fittings_Label"):
                   furnitureFittings.push(flatProduct);
                   break;
               case $A.get("$Label.c.Furnishing_Fittings_Installation_Label"):
                   furnishingFittingsInstallation.push(flatProduct);
                   break;
               case $A.get("$Label.c.Materials_Label"):
                   materials.push(flatProduct);
                   break;
               case $A.get("$Label.c.Design_Services_Label"):
                   designServices.push(flatProduct);
                   break;
           }
       });

       component.set("v.renovationServices", renovationServices);
       component.set("v.furnitureFittings", furnitureFittings);
       component.set("v.furnishingFittingsInstallation", furnishingFittingsInstallation);
       component.set("v.materials", materials);
       component.set("v.designServices", designServices);
   },
})