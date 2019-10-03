({
    doFMInit : function(component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id"); //0032a00000ddYWWAA2 // 0053i000001B5cgAAC
        component.set("v.currentUserId", userId);
        component.find("userDataService").reloadRecord(true, function(loadedResult){
            console.log(JSON.stringify(loadedResult));
        });
    },
    
    handleUserRecord: function (component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            var userData = component.get("v.userRecord");
            var partnerAcctId = userData.fields.Partner_Account_ID__c.value
            component.set("v.accountRecId", partnerAcctId);
        }
    },
    
    handleUploadFinished: function (component, event, helper) {
        component.find("accountDataService").reloadRecord(true, function(loadedResult){
            component.set("v.accountRecordFields.Monthly_Acct_List_Uploaded__c", true);
            component.find("accountDataService").saveRecord(function(saveResult){
                console.log(JSON.stringify(saveResult));
            })
        });
    }
})