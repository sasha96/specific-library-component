({
    closeModalWindow: function (component, event, helper) {

        $A.get("e.force:closeQuickAction").fire();
        if (event.getParam('refreshPage')) {
            $A.get('e.force:refreshView').fire();
        }
    },

    doInit: function (component, event, helper) {

        var recordId = component.get('v.recordId');
        component.set('v.recordId', recordId);
    }
})