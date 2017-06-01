global without sharing class GB_Deploy {
    public transient List<Setting> SettingsList {get;set;}
    private transient List<Meta> MetaList {get;set;}

    static public transient Map<String, Meta> MetaMap {get;set;}

    public GB_Deploy() {
        MetaList = new List<Meta>();

        for (GBLite__GB_Global_Meta__c gbm : [
            SELECT Id,
                GBLite__Type__c, 
                GBLite__Grid_Name__c,
                GBLite__Object_API_Name__c, 
                GBLite__Picklist_Meta__c,
                GBLite__Summary__c,
                LastModifiedDate,
                LastModifiedBy.Name
            FROM    GBLite__GB_Global_Meta__c 
            WHERE   GBLite__Type__c in ('Action', 'Custom Code - CSS', 'Custom Code - JavaScript')
            ORDER BY GBLite__Object_API_Name__c
        ]) {
            if (gbm.GBLite__Type__c == 'Action') {
                MetaList.add(new MetaAction(gbm));    
            }
            if (gbm.GBLite__Type__c == 'Custom Code - CSS') {
                MetaList.add(new MetaCSS(gbm));    
            }
            if (gbm.GBLite__Type__c == 'Custom Code - JavaScript') {
                MetaList.add(new MetaJS(gbm));    
            }
        }

        MetaMap = new Map<String, Meta>();
        for (Meta m : MetaList) {
            MetaMap.put(m.Id, m);
        }

        SettingsList = new List<Setting>();
        for (GBLite__GridBuddySettings__c s : [
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
        ]) {
            SettingsList.add(new Setting(s));

        }
    }

    private static List<Meta> getMetaContent(String strIds) {
        String[] ids = strIds.split(',');
        List<Meta> contentList = new List<Meta>();

        for (String id : ids) {
            contentList.add(MetaMap.get(Id));
        }

        return contentList;
    }

    private static String base64Encode(String txt) {
        return EncodingUtil.base64Encode(Blob.valueOf(txt == null ? '' : txt));
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

    //@RemoteAction global static String getMetaContent(String Id, String base64Def) {

    //}

    public class Setting {
        public List<Meta> Actions {get;set;}
        public List<Meta> CustomCSS {get;set;}
        public List<Meta> CustomJS {get;set;}

        public GBLite__GridBuddySettings__c Rec {get;set;}
        public String Name {get; private set;}
        public String ContentBase64 {get; private set;}

        public Setting(GBLite__GridBuddySettings__c rec) {
            Name = rec.GBLite__Grid_Name__c;
            Rec = rec;
            ContentBase64 = GB_Deploy.base64Encode(rec.GBLite__Definition__c);

            String str_actions;
            String str_customCSSIds;
            String str_customJSIds;
            JSONParser parser = JSON.createParser(rec.GBLite__Definition__c);

             while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'actions') {
                    parser.nextToken();
                    str_actions = parser.getText();
                    Actions = GB_Deploy.getMetaContent(str_actions);
                }
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'customCSSIds') {
                    parser.nextToken();
                    str_customCSSIds = parser.getText();
                    CustomCSS = GB_Deploy.getMetaContent(str_customCSSIds);
                }
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'customJSIds') {
                    parser.nextToken();
                    str_customJSIds = parser.getText();
                    CustomJS = GB_Deploy.getMetaContent(str_customJSIds);
                }
             }
        }
    }

    public virtual class Meta {
        public String Id {get; private set;}
        public String Name {get; private set;}
        public String Type {get; private set;}
        public String ContentBase64 {get; private set;}
    }

    public class MetaCSS extends Meta {
        public GBLite__GB_Global_Meta__c GBmeta {get; private set;}

        public MetaCSS(GBLite__GB_Global_Meta__c rec) {
            GBmeta = rec;
            Id = rec.Id;
            Type = 'CSS';
            ContentBase64 = GB_Deploy.base64Encode(GBmeta.GBLite__Picklist_Meta__c);
            Name = GBmeta.GBLite__Summary__c;
        }
    }
    public class MetaJS extends Meta {
        public GBLite__GB_Global_Meta__c GBmeta {get; private set;}

        public MetaJS(GBLite__GB_Global_Meta__c rec) {
            GBmeta = rec;
            Id = rec.Id;
            Type = 'JS';
            ContentBase64 = GB_Deploy.base64Encode(GBmeta.GBLite__Picklist_Meta__c);
            Name = GBmeta.GBLite__Summary__c;
        }
    }
    public class MetaAction extends Meta {
        public GBLite__GB_Global_Meta__c GBmeta {get; private set;}

        public MetaAction(GBLite__GB_Global_Meta__c rec) {
            GBmeta = rec;
            Id = rec.Id;
            Type = 'ACTION';
            ContentBase64 = GB_Deploy.base64Encode(GBmeta.GBLite__Picklist_Meta__c);

            JSONParser parser = JSON.createParser(rec.GBLite__Picklist_Meta__c); //.replaceAll('/\\"/g', '"')
            String label = '';
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'actionLabel') {
                    parser.nextToken();
                    label = parser.getText();
                }
            }

            Name = label;//GBmeta.GBLite__Object_API_Name__c; //${item.Picklist_Meta.actionLabel}
        }
    }
}