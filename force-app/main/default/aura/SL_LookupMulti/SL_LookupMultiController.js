({
    doInit: function (component, event, helper) {

        var iconParam = component.get('v.iconParam');
        var isEmptyIcon = iconParam === undefined ? true : false;
        component.set('v.isEmptyIcon', isEmptyIcon);

        var recordId = component.get("v.recordId");
        var searchField = component.get("v.searchField");
        var searchField = component.get("v.searchField");
        var objectApiName = component.get("v.objApiName");

        if (recordId !== null && recordId && recordId !== '') {

            var recordIds = recordId.split(';');

            var action = component.get("c.getMultiRecords");

            action.setParams({
                'recordIds': JSON.stringify(recordIds),
                'objectName': objectApiName,
                'mainField': searchField
            });
            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS") {

                    var lstRecords = response.getReturnValue().map(function (option) {
                        if (component.get('v.isForFlow')) {
                            if (option.LatestPublishedVersion) option.Name = option.LatestPublishedVersion.Title;
                            if (option.Title) option.Name = option.Title;
                            option.Id = option.Id;
                        } else {
                            option.Name = option[searchField];
                            option.Id = option['Id'];
                        }
                        return option;
                    });

                    component.set("v.selectedRecords", lstRecords);
                    var newIds = []
                    for (var v in lstRecords) {
                        newIds.push(lstRecords[v].Id);
                    }

                    component.set("v.recordId", newIds);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error Message',
                        message: 'Error happend in init method ',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }

    },

    setFocus: function (component, event, helper) {

        if (component.get("v.searchString") === '' || component.get("v.searchString") === undefined) {
            component.set("v.lstRecords", []);
        }
        var focus = function () {
            component.set("v.isDropdownOpen", true);
        }
        var blur = function () {
            component.set("v.isDropdownOpen", false);
        }
        component.find('dropdownUtilMulti').focus(focus, blur);

    },

    clearSearch: function (component, event, helper) {
        component.set("v.searchString", null);
    },

    doSearch: function (component, event, helper) {

        var searchString = component.get("v.searchString");
        if (searchString) {
            searchString = searchString.trim().replace(/\*/g).toLowerCase();
        }
        var objApiName = component.get("v.objApiName");
        var searchField = component.get("v.searchField");

        var searchTimeout = component.get('v.searchTimeout');
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }

        var selectedIds = component.get("v.recordId");

        searchTimeout = window.setTimeout(
            $A.getCallback(() => {
                var action = component.get("c.search");
                action.setParams({
                    'searchString': searchString,
                    'objectName': objApiName,
                    'fields': searchField,
                    'soslParams': component.get('v.soslParams'),
                    'limitOfRecords': component.get('v.limitOfRecords'),
                    'excludeIds': selectedIds !== undefined && selectedIds !== '' ? selectedIds : null
                });
                action.setCallback(this, function (response) {

                    if (response.getState() == "SUCCESS") {
                        var lstRecords = response.getReturnValue().map(function (option) {
                            if (component.get('v.isForFlow')) {
                                debugger;

                                if (option.LatestPublishedVersion) option.Name = option.LatestPublishedVersion.Title;
                                if (option.Title) option.Name = option.Title;
                            } else {
                                option.Name = option[searchField];
                            }
                            return option;
                        });

                        component.set("v.lstRecords", lstRecords);
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title: 'Error Message',
                            message: 'Error happend in search method',
                            duration: ' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                });
                action.setStorable();
                $A.enqueueAction(action);
                component.set('v.searchTimeout', null);
            }),
            300
        );
        component.set('v.searchTimeout', searchTimeout);

    },

    selectOption: function (component, event, helper) {

        var id = event.currentTarget.dataset.id;
        var lstRecords = component.get("v.lstRecords");

        var selected = lstRecords.filter(function (e) {
            return e.Id !== id;
        });
        component.set('v.lstRecords', selected);

        var newOptions = lstRecords.filter(function (e) {
            return e.Id === id;
        });

        var selectedRecords = component.get("v.selectedRecords");

        var isPush = true;
        for (var item = 0; item < selectedRecords.length; item++) {
            if (selectedRecords[item].Id === event.currentTarget.dataset.id) {
                isPush = false;
            }
        }

        if (isPush) {
            if (!selectedRecords) {
                selectedRecords = [];
            }
            selectedRecords.push(newOptions[0]);
            component.set("v.selectedRecords", selectedRecords);
            var recordIdNew = component.get("v.recordId");
            if (!recordIdNew) {
                recordIdNew = [];
            }
            recordIdNew.push(id);
            component.set("v.recordId", recordIdNew);
        }

    },

    handleRemove: function (component, event, helper) {

        var selectedRecords = component.get("v.selectedRecords");
        var id = event.currentTarget.dataset.id;

        var itemThatNeedAdded = selectedRecords.filter(function (e) {
            return e.Id == id;
        });

        var val = component.get('v.lstRecords');
        var itm = {
            'Name': itemThatNeedAdded[0].Name,
            'Id': itemThatNeedAdded[0].Id,
        };
        val.push(itm);

        var newList = val.sort(function (a, b) {
            if (a.text > b.text) {
                return 1;
            }
            if (a.text < b.text) {
                return -1;
            }
            return 0;
        });

        component.set('v.lstRecords', newList);

        component.set("v.selectedRecords", selectedRecords.filter(function (e) {
            return e.Id !== id;
        }));

        component.set("v.recordId", component.get('v.recordId').filter(function (e) {
            return e !== id;
        }));

    },

})