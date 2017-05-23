global class GB_Deploy {
    public List<GBLite__GridBuddySettings__c> GB_Settings {get;set;}
    public List<GBLite__GB_Global_Meta__c> GB_Meta {get;set;}
    
    public GB_Deploy() {
        GB_Settings = [
            SELECT 
                GBLite__Definition__c,
                GBLite__Custom_CSS_File__c,
                GBLite__Grid_Name__c,
                GBLite__Custom_JS_File__c,
                GBLite__Default_Definition__c,
                LastModifiedDate,
                LastModifiedBy.Name
            FROM    GBLite__GridBuddySettings__c
            WHERE   GBLite__Default_Definition__c = true
            ORDER BY GBLite__Grid_Name__c
        ];
            
        GB_Meta = [
            SELECT Id,
                GBLite__Response_Message__c, 
                GBLite__Type__c, 
                GBLite__Grid_Name__c, 
                GBLite__Request_Status__c, 
                GBLite__Controlling_Field__c, 
                GBLite__Object_API_Name__c, 
                GBLite__Object_Dot_Field_Name__c, 
                GBLite__Picklist_Meta__c,
                LastModifiedDate,
                LastModifiedBy.Name
            FROM    GBLite__GB_Global_Meta__c 
            WHERE   GBLite__Type__c = 'Action'
            ORDER BY GBLite__Object_API_Name__c
        ];
    }
    
    @RemoteAction global static String updateSetting(String Id, String base64Def) {
        
        GBLite__GridBuddySettings__c setting = [SELECT Id, GBLite__Definition__c FROM GBLite__GridBuddySettings__c WHERE Id = :Id];

        if (setting != null) {
            String result = 'success';
            try {
                setting.GBLite__Definition__c = EncodingUtil.base64Decode(base64Def).tostring();
                update setting;
            } catch (Exception e) {
                result = 'error:' + e;
            }
            return result;
        } else {
            return 'failed';
        }

        //String str = '---->' + Id + ': ' + base64Def;
        //return 'success: ' + str;
    }
}