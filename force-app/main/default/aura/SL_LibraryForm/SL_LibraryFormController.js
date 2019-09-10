({
    closeModalWindow: function (component, event, helper) {
        debugger;
        $A.get("e.force:closeQuickAction").fire();
        if (event.getParam('refreshPage')) {
            $A.get('e.force:refreshView').fire();
        }

        if (event.getParam('reloadPage')) {
            window.location.reload();
        }
    },

    doInit: function (component, event, helper) {

        if (component.get('v.folderName') && component.get('v.mode') === 'flow element') {
            component.set('v.folderName', '\'' + component.get('v.folderName') + '\'');
        }
        var recordId = component.get('v.recordId');
        component.set('v.recordId', recordId);

        var action = component.get("c.getLibraryOrFolder");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var returnedResult = JSON.parse(response.getReturnValue());
                var folderName = returnedResult.folderName;
                var libraryRecord = returnedResult.libraryRecord;

                if (!component.get('v.folderName') && folderName) {
                    if (component.get('v.mode') === 'flow element') {
                        component.set('v.folderName', '\'' + folderName + '\'');
                    } else {
                        component.set('v.folderName', folderName);
                    }
                }

                if (component.get('v.folderName')) {
                    component.set('v.getLibraryId', '\'' + libraryRecord.RootContentFolderId + '\'');
                } else {
                    component.set('v.getLibraryId', '\'' + libraryRecord.Id + '\'');
                }

            }
            else if (state === "INCOMPLETE") {
                console.log(state);
            }
            else if (state === "ERROR") {
                console.log(state);
            }
            component.set('v.loadAllData', true);
        });

        $A.enqueueAction(action);
    }
})