global without sharing class GB_Deploy {
    public transient List<Setting> SettingsList {get;set;}

    static public transient Map<String, Meta> MetaMap {get;set;}

    public List<GBLite__GridBuddySettings__c> NewSettingsList {get;set;}
    public List<GBLite__GB_Global_Meta__c> NewMetasList {get;set;}
    public Integer idx = 0;
    public Integer midx = 0;
    public String ErrMsg {get;set;}

    public GB_Deploy() {
        NewSettingsList = new List<GBLite__GridBuddySettings__c>();
        NewMetasList = new List<GBLite__GB_Global_Meta__c>();
        ErrMsg = '';
        GB_Deploy.cacheMeta();

        SettingsList = new List<Setting>();
        for (GBLite__GridBuddySettings__c s : [
            SELECT Id,
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
            Setting locSet = new Setting(s);
            SettingsList.add(locSet);
            MetaMap.put(locSet.Id, locSet);
        }

        
    }

    public void addSetting() {
        idx++;
        if (NewSettingsList != null) {
            NewSettingsList.add(new GBLite__GridBuddySettings__c(
                GBLite__Grid_Name__c = 'grid ' + idx,
                GBLite__Default_Definition__c = true,
                GBLite__Definition__c = '{}'
            ));
        } else {
            ErrMsg = 'error';
        }
    }

    public void saveSettings() {
        try {
            insert NewSettingsList;
            ErrMsg = 'done.';
        } catch (Exception e) {
            ErrMsg = e.getMessage();
        }
    }

    public void addMetaAction() {
        addMetaByType('action');
    }
    public void addMetaCSS() {
        addMetaByType('css');
    }
    public void addMetaJS() {
        addMetaByType('js');
    }

    public void addMetaByType(String mtype) {
        midx++;
        if (NewMetasList != null) {
            GBLite__GB_Global_Meta__c meta = new GBLite__GB_Global_Meta__c();

            if (mtype == 'action') {
                meta.GBLite__Type__c = 'Action';
                //meta.GBLite__Object_API_Name__c = 'Object';
                meta.GBLite__Picklist_Meta__c = '{}';
                meta.GBLite__Summary__c = '';
            }
            if (mtype == 'css') {
                meta.GBLite__Type__c = 'Custom Code - CSS';
                meta.GBLite__Summary__c = 'gbc_meta_' + midx + '_css';
                meta.GBLite__Picklist_Meta__c = '//empty';
            }
            if (mtype == 'js') {
                meta.GBLite__Type__c = 'Custom Code - JavaScript';
                meta.GBLite__Summary__c = 'gbc_meta_' + midx + '_js';
                meta.GBLite__Picklist_Meta__c = '//empty';
            }

            NewMetasList.add(meta);
        } else {
            ErrMsg = 'error';
        }
    }

    public void saveMetas() {
        try {
            for (GBLite__GB_Global_Meta__c meta : NewMetasList) {
                if (meta.GBLite__Type__c == 'Action') {
                    String sObj = meta.GBLite__Summary__c.split('.')[0];
                    String label = meta.GBLite__Summary__c.split('.')[1];
                    meta.GBLite__Object_API_Name__c = sObj;
                    meta.GBLite__Picklist_Meta__c = '{"actionLabel":"' + label + '"}';
                }
            }
            insert NewMetasList;
            ErrMsg = 'done.';
        } catch (Exception e) {
            ErrMsg = e.getMessage();
        }
    }

    private static List<GBLite__GB_Global_Meta__c> getMeta() {
        return [
            SELECT Id,
                GBLite__Type__c, 
                GBLite__Grid_Name__c,
                GBLite__Object_API_Name__c, 
                GBLite__Picklist_Meta__c,
                //GBLite__Summary__c,
                LastModifiedDate,
                LastModifiedBy.Name
            FROM    GBLite__GB_Global_Meta__c 
            WHERE   GBLite__Type__c in ('Action', 'Custom Code - CSS', 'Custom Code - JavaScript')
            ORDER BY GBLite__Object_API_Name__c
        ];
    }

    private static List<GBLite__GridBuddySettings__c> getSettings() {
        return [
            SELECT Id,
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
    }

    private static void cacheMeta() {
        MetaMap = new Map<String, Meta>();

        for (GBLite__GB_Global_Meta__c gbm : GB_Deploy.getMeta()) {
            Meta m = null;
            if (gbm.GBLite__Type__c == 'Action') {
               m = new MetaAction(gbm);
            }
            //if (gbm.GBLite__Type__c == 'Custom Code - CSS') {
            //   m = new MetaCSS(gbm);
            //}
            //if (gbm.GBLite__Type__c == 'Custom Code - JavaScript') {
            //   m = new MetaJS(gbm);
            //}
            if (m != null)
                MetaMap.put(m.Id, m);
        }
    }

    private static void cacheMetaByName() {
        MetaMap = new Map<String, Meta>();

        for (GBLite__GB_Global_Meta__c gbm : GB_Deploy.getMeta()) {
            Meta m = null;
            if (gbm.GBLite__Type__c == 'Action') {
               m = new MetaAction(gbm);
            }
            //if (gbm.GBLite__Type__c == 'Custom Code - CSS') {
            //   m = new MetaCSS(gbm);
            //}
            //if (gbm.GBLite__Type__c == 'Custom Code - JavaScript') {
            //   m = new MetaJS(gbm);
            //}
            if (m != null)
                MetaMap.put(m.Name, m);
        }
    }

    private static List<Meta> getMetaContent(String strIds) {
        List<Meta> contentList = new List<Meta>();
        
        if (strIds == null)
            return contentList;

        String[] ids = strIds.split(',');

        for (String id : ids) {
            contentList.add(GB_Deploy.MetaMap.get(Id));
        }

        return contentList;
    }

    private static String generateMetaExternalId(List<Meta> metas) {
        if (metas == null || metas.size() == 0) return '';

        String res = '';
        for (Meta m : metas) {
            if (m != null)
                res += ',' + m.Name;
        }
        if (res.length() > 0)
            return res.substring(1);
        else
            return res;
    }

    private static String generateMetaName(List<Meta> metas) {
        if (metas == null || metas.size() == 0) return '';

        String res = '';
        for (Meta m : metas) {
            if (m != null)
                res += ',' + m.Id;
        }
        if (res.length() > 0)
            return res.substring(1);
        else
            return res;
    }

    private static String base64Encode(String txt) {
        return EncodingUtil.base64Encode(Blob.valueOf(txt == null ? '' : txt));
    }

    //public String extractAllSettings() {
    //    GB_Deploy.cacheMeta();

    //    SettingsList = new List<Setting>();
    //    for (GBLite__GridBuddySettings__c s : GB_Deploy.getSettings()) {
    //        Setting locSet = new Setting(s);
    //        SettingsList.add(locSet);
    //        MetaMap.put(locSet.Id, locSet);
    //    }
    //}

    //public String extractAllMeta() {
        
    //}
    
    @RemoteAction global static String updateSetting(String Id, String base64Def) {
        
        GBLite__GridBuddySettings__c setting = [SELECT Id, GBLite__Definition__c FROM GBLite__GridBuddySettings__c WHERE Id = :Id];

        if (setting != null) {
            GB_Deploy.cacheMetaByName();
            String jsonString = EncodingUtil.base64Decode(base64Def).tostring();
            Map<String, Object> def = (Map<String, Object>)JSON.deserializeUntyped(jsonString);

            List<Meta> Actions = GB_Deploy.getMetaContent((String)def.get('actions'));
            //List<Meta> CustomCSS = GB_Deploy.getMetaContent((String)def.get('customCSSIds'));
            //List<Meta> CustomJS = GB_Deploy.getMetaContent((String)def.get('customJSIds'));

            def.put('actions', GB_Deploy.generateMetaName(Actions));
            //def.put('customCSSIds', GB_Deploy.generateMetaName(CustomCSS));
            //def.put('customJSIds', GB_Deploy.generateMetaName(CustomJS));

            setting.GBLite__Definition__c = JSON.serialize(def);
            String result = 'success';
            try {
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

    @RemoteAction global static String updateMeta(String sfId, String gbType, String base64Def) { 
        GBLite__GB_Global_Meta__c meta = [SELECT Id, GBLite__Picklist_Meta__c FROM GBLite__GB_Global_Meta__c WHERE Id = :sfId];

        try {
            if (meta != null) {
                String content = EncodingUtil.base64Decode(base64Def).tostring();
                if (gbType == 'action') {
                    Map<String, Object> def = (Map<String, Object>)JSON.deserializeUntyped(content);
                    content = JSON.serialize(def);
                }
                meta.GBLite__Picklist_Meta__c = content;

                String result = 'success';
                try {
                    update meta;
                } catch (Exception e) {
                    result = 'error:' + e;
                }
                return result;
            } else {
                return 'failed';
            }
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @RemoteAction global static String getBase64ContentByIdAndType(String recId, String recType) {

        if (recType == 'Setting') {
            GB_Deploy.cacheMeta();

            Setting m = new Setting([SELECT Id, GBLite__Definition__c, GBLite__Grid_Name__c, LastModifiedDate FROM GBLite__GridBuddySettings__c WHERE Id = :recId]);
            return m.ContentBase64;
        }

        if (recType == 'Action' /*|| recType == 'JS' || recType == 'CSS'*/) {
            String result = [SELECT GBLite__Picklist_Meta__c FROM GBLite__GB_Global_Meta__c WHERE Id = :recId].GBLite__Picklist_Meta__c;

            if (recType == 'Action') {
                Object jsonObj = JSON.deserializeUntyped(result);
                return GB_Deploy.base64Encode(JSON.serializePretty(jsonObj));
            } else {
                return GB_Deploy.base64Encode(result);
            }
        }

        return '';
    }


    public class Setting extends Meta {
        public List<Meta> Actions {get; private set;}
        //public List<Meta> CustomCSS {get; private set;}
        //public List<Meta> CustomJS {get; private set;}

        public GBLite__GridBuddySettings__c Rec {get; private set;}
        public String Id {get; private set;}
        public String Name {get; private set;}
        public String ContentBase64 {get; private set;}
        public String LastModifiedDate {get; private set;}

        //public GB_Settings_JSON Definition {get; private set;}

        public Setting(GBLite__GridBuddySettings__c record) {
            Id = record.Id;
            Name = record.GBLite__Grid_Name__c;
            Rec = record;
            LastModifiedDate = Rec.LastModifiedDate.formatGMT('YYYY-MM-dd HH:mm:ss');

            Map<String, Object> def = (Map<String, Object>)JSON.deserializeUntyped(record.GBLite__Definition__c);

            Actions = GB_Deploy.getMetaContent((String)def.get('actions'));
            //CustomCSS = GB_Deploy.getMetaContent((String)def.get('customCSSIds'));
            //CustomJS = GB_Deploy.getMetaContent((String)def.get('customJSIds'));


            def.put('actions', GB_Deploy.generateMetaExternalId(Actions));
            //def.put('customCSSIds', GB_Deploy.generateMetaExternalId(CustomCSS));
            //def.put('customJSIds', GB_Deploy.generateMetaExternalId(CustomJS));

            //System.debug('===' + this);
            //System.debug('===' + this.Definition);
            //System.debug('=+=' + JSON.serializePretty(Definition));

            ContentBase64 = GB_Deploy.base64Encode(JSON.serializePretty(def));
            //System.debug('=+=' + ContentBase64);
        }
    }

    public virtual class Meta {
        public String Id {get; private set;}
        public String Name {get; private set;}
        //public String Type {get; private set;}
        public String ContentBase64 {get; private set;}
    }

    //public class MetaCSS extends Meta {
    //    public GBLite__GB_Global_Meta__c GBmeta {get; private set;}

    //    public MetaCSS(GBLite__GB_Global_Meta__c rec) {
    //        GBmeta = rec;
    //        Id = rec.Id;
    //        //Type = 'CSS';
    //        ContentBase64 = GB_Deploy.base64Encode(GBmeta.GBLite__Picklist_Meta__c);
    //        Name = GBmeta.GBLite__Summary__c;
    //    }
    //}
    //public class MetaJS extends Meta {
    //    public GBLite__GB_Global_Meta__c GBmeta {get; private set;}

    //    public MetaJS(GBLite__GB_Global_Meta__c rec) {
    //        GBmeta = rec;
    //        Id = rec.Id;
    //        //Type = 'JS';
    //        ContentBase64 = GB_Deploy.base64Encode(GBmeta.GBLite__Picklist_Meta__c);
    //        Name = GBmeta.GBLite__Summary__c;
    //    }
    //}
    public class MetaAction extends Meta {
        public GBLite__GB_Global_Meta__c GBmeta {get; private set;}
        public GB_Action_JSON Definition {get; private set;}

        public MetaAction(GBLite__GB_Global_Meta__c rec) {
            GBmeta = rec;
            Id = rec.Id;
            //Type = 'ACTION';
            //ContentBase64 = GB_Deploy.base64Encode();

            //JSONParser parser = JSON.createParser(rec.GBLite__Picklist_Meta__c);
            Definition = (GB_Action_JSON)JSON.deserialize(GBmeta.GBLite__Picklist_Meta__c, GB_Action_JSON.class);

            ContentBase64 = GB_Deploy.base64Encode(JSON.serializePretty(Definition));

            Name = GBmeta.GBLite__Object_API_Name__c + '.' + Definition.actionLabel;
        }
    }
}