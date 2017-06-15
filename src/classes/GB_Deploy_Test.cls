@IsTest
global class GB_Deploy_Test {
    
    //@isTest 
    //static void test_constructor() {
    //    Test.startTest();
    //    GB_Deploy gbDeploy = new GB_Deploy();
    //    Test.stopTest();
    //}

    //@isTest 
    //static void test_update() {
    //    GBLite__GridBuddySettings__c test_setting = new GBLite__GridBuddySettings__c(
    //        GBLite__Grid_Name__c = 'test_grid',
    //        GBLite__Definition__c = '{"test": "test1"}'
    //    );
    //    insert test_setting;

    //    //GBLite__GB_Global_Meta__c test_meta = new GBLite__GB_Global_Meta__c(
    //    //    GBLite__Picklist_Meta__c = '{"actionLabel": "label1"}'
    //    //);        
    //    //insert test_meta;


    //    Test.startTest();
    //    GB_Deploy.updateSetting(String.valueOf(test_setting.Id), 'eyJ0ZXN0IjogInRoaXMgaXMgdGVzdCJ9');

    //    GBLite__GridBuddySettings__c setting = [SELECT Id, GBLite__Definition__c FROM GBLite__GridBuddySettings__c WHERE Id = :test_setting.Id];

    //    System.assertEquals(setting.GBLite__Definition__c, '{"test": "this is test"}');
    //    Test.stopTest();
    //}

    @isTest 
    static void test_dataPrep() {
        GBLite__GB_Global_Meta__c test_meta_action = new GBLite__GB_Global_Meta__c(
            //GBLite__Summary__c = '',
            GBLite__Picklist_Meta__c = '{"actionLabel": "label1"}',
            GBLite__Type__c = 'Action'
        );
        insert test_meta_action;

        //GBLite__GB_Global_Meta__c test_meta_css = new GBLite__GB_Global_Meta__c(
        //    GBLite__Summary__c = 'gbc_testgrid_css',
        //    GBLite__Picklist_Meta__c = 'body {width: 10px;}',
        //    GBLite__Type__c = 'Custom Code - CSS'
        //);
        //insert test_meta_css;

        //GBLite__GB_Global_Meta__c test_meta_js = new GBLite__GB_Global_Meta__c(
        //    GBLite__Summary__c = 'gbc_testgrid_js',
        //    GBLite__Picklist_Meta__c = 'var test = 1;',
        //    GBLite__Type__c = 'Custom Code - JavaScript'
        //);
        //insert test_meta_js;

        GBLite__GridBuddySettings__c test_setting = new GBLite__GridBuddySettings__c(
            GBLite__Grid_Name__c = 'test grid',
            GBLite__Definition__c = '{"actions": "'+test_meta_action.Id+'"}',
            GBLite__Default_Definition__c = true
        );
        insert test_setting;

        Test.startTest();
        GB_Deploy gbDeploy = new GB_Deploy();
        gbDeploy.addSetting();
        gbDeploy.saveSettings();
        gbDeploy.addMetaAction();
        gbDeploy.saveMetas();

        GB_Deploy.getMeta();
        GB_Deploy.getSettings();
        GB_Deploy.updateSetting(String.valueOf(test_setting.Id), 'eyJhY3Rpb25MYWJlbCI6ICJsYWJlbDEifQ==');
        GB_Deploy.updateMeta(String.valueOf(test_meta_action.Id), 'action', 'eyJhY3Rpb25MYWJlbCI6ICJsYWJlbDEifQ==');
        GB_Deploy.getBase64ContentByIdAndType(test_setting.Id, 'Setting');
        GB_Deploy.getBase64ContentByIdAndType(test_meta_action.Id, 'Action');
        GB_Deploy.base64Encode('Action');
        Test.stopTest();
    }
}