gotToOppPage : function(component, event, helper) {
        if( (typeof sforce != 'undefined') && (sforce != null) ) {
            sforce.one.navigateToSObject(component.get("v.oppId"));
        } else {
            var urlEvent = $A.get("e.force:navigateToURL");
            if(urlEvent == undefined) {
                window.location = "/"+component.get("v.oppId");
            } else {
                urlEvent.setParams({
                    "url": "/"+component.get("v.oppId")
                });
                urlEvent.fire();
            }
        }
    }
