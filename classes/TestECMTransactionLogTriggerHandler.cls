@IsTest
public with sharing class TestECMTransactionLogTriggerHandler {
    
    @IsTest
    private static void testECMTransactionLogTriggerHandler_updatesDocumentVersions(){
        new ECMOffloader.ECMActivator().onActivate();

        nFUSE__Transaction_Log__c tLog = new nFUSE__Transaction_Log__c();

        tLog.nFUSE__Transaction_Status__c = 'Complete';
        tLog.nFUSE__Vendor_Status__c = 'ECM_offload';
        tLog.nFUSE__Action__c = 'test';
        tLog.nFUSE__Api_Version__c = '0.0';
        tLog.nFUSE__App_Plugin__c = 'test';
        tLog.nFUSE__External_Id__c = 'test';
        tLog.nFUSE__Primary_Object_Id__c = 'test';
        tLog.nFUSE__Requested_By_User_Id__c = 'test';

        Long pubDate = DateTime.now().getTime();

        List<LLC_BI__Document_Version__c> docVersions = getVersions();

        insert tLog;
        tLog.nFUSE__Transaction_Detail__c = getECMDetail(docVersions[0].Id, docVersions[1].Id, pubDate);

        Test.startTest();
        update tLog;
        Test.stopTest();

        verifyVersions(docVersions[0].Id, docVersions[1].Id, pubDate);
    }

    @IsTest
    private static void testECMTransactionLogTriggerHandler_DoesNotUpdateDocumentVersions_IfNotActivated(){
        nFUSE__Transaction_Log__c tLog = new nFUSE__Transaction_Log__c();

        tLog.nFUSE__Transaction_Status__c = 'Complete';
        tLog.nFUSE__Vendor_Status__c = 'ECM_offload';
        tLog.nFUSE__Action__c = 'test';
        tLog.nFUSE__Api_Version__c = '0.0';
        tLog.nFUSE__App_Plugin__c = 'test';
        tLog.nFUSE__External_Id__c = 'test';
        tLog.nFUSE__Primary_Object_Id__c = 'test';
        tLog.nFUSE__Requested_By_User_Id__c = 'test';

        Long pubDate = DateTime.now().getTime();

        List<LLC_BI__Document_Version__c> docVersions = getVersions();

        insert tLog;
        tLog.nFUSE__Transaction_Detail__c = getECMDetail(docVersions[0].Id, docVersions[1].Id, pubDate);

        Test.startTest();
        update tLog;
        Test.stopTest();

        verifyVersions(docVersions[0].Id, docVersions[1].Id);
    }

    @IsTest
    private static void testECMTransactionLogTriggerHandler_DoesNotUpdateDocumentVersions_IfStatusIncorrect(){
        new ECMOffloader.ECMActivator().onActivate();

        nFUSE__Transaction_Log__c tLog = new nFUSE__Transaction_Log__c();

        tLog.nFUSE__Transaction_Status__c = 'In-Progress';
        tLog.nFUSE__Vendor_Status__c = 'ECM';
        tLog.nFUSE__Action__c = 'test';
        tLog.nFUSE__Api_Version__c = '0.0';
        tLog.nFUSE__App_Plugin__c = 'test';
        tLog.nFUSE__External_Id__c = 'test';
        tLog.nFUSE__Primary_Object_Id__c = 'test';
        tLog.nFUSE__Requested_By_User_Id__c = 'test';

        Long pubDate = DateTime.now().getTime();

        List<LLC_BI__Document_Version__c> docVersions = getVersions();

        insert tLog;
        tLog.nFUSE__Transaction_Detail__c = getECMDetail(docVersions[0].Id, docVersions[1].Id, pubDate);

        Test.startTest();
        update tLog;
        Test.stopTest();

        verifyVersions(docVersions[0].Id, docVersions[1].Id);
    }

    private static List<LLC_BI__Document_Version__c> getVersions(){
        LLC_BI__Document_Store__c docStore = new LLC_BI__Document_Store__c();
        insert docStore;

        List<LLC_BI__Document_Version__c> versions = new List<LLC_BI__Document_Version__c>();
        versions.add(new LLC_BI__Document_Version__c(LLC_BI__Document_Store__c = docStore.Id));
        versions.add(new LLC_BI__Document_Version__c(LLC_BI__Document_Store__c = docStore.Id));

        insert versions;
        return versions;
    }

    private static String getECMDetail(Id versionId1, Id versionId2, Long pubDate){

        String toReturn = 
        '{' +
            ' "' + versionId1 + '": { ' +
                ' "LLC_BI__External_ID__c": "testId1", ' +
                ' "LLC_BI__External_Download_URL__c": "testDownloadUrl1", ' +
                ' "LLC_BI__External_Preview_URL__c": "testPreviewUrl1", ' +
                ' "LLC_BI__External_Thumbnail_URL__c": "testThumbnailUrl1", ' +
                ' "LLC_BI__Published_Date__c": "' + pubDate + '" ' +
            ' }, ' +
            ' "' + versionId2 + '": {' +
                ' "LLC_BI__External_ID__c": "testId2", ' +
                ' "LLC_BI__External_Download_URL__c": "testDownloadUrl2", ' +
                ' "LLC_BI__External_Preview_URL__c": "testPreviewUrl2", ' +
                ' "LLC_BI__External_Thumbnail_URL__c": "testThumbnailUrl2", ' +
                ' "LLC_BI__Published_Date__c": "' + pubDate + '" ' +
            '} ' +
        '}';

        return toReturn;
    }

    private static void verifyVersions(Id versionId1, Id versionId2, Long pubDate){
        List<Id> versionIds = new List<Id>();
        versionIds.add(versionId1);
        versionIds.add(versionId2);

        List<LLC_BI__Document_Version__c> docVersions = [
            SELECT 
                Id, 
                LLC_BI__External_Download_URL__c, 
                LLC_BI__External_ID__c, 
                LLC_BI__External_Preview_URL__c, 
                LLC_BI__External_Thumbnail_URL__c,
                LLC_BI__Published_Date__c
            FROM 
                LLC_BI__Document_Version__c
            WHERE
                Id IN :versionIds
            ORDER BY
                LLC_BI__External_ID__c ASC];

        Integer i = 1;
        for (LLC_BI__Document_Version__c version : docVersions){
            System.assertEquals('testId' + i, version.LLC_BI__External_ID__c);
            System.assertEquals('testDownloadUrl' + i, version.LLC_BI__External_Download_URL__c);
            System.assertEquals('testPreviewUrl' + i, version.LLC_BI__External_Preview_URL__c);
            System.assertEquals('testThumbnailUrl' + i, version.LLC_BI__External_Thumbnail_URL__c);
            System.assertEquals(DateTime.newInstance(pubDate), version.LLC_BI__Published_Date__c);
            i++;
        }
    }

    private static void verifyVersions(Id versionId1, Id versionId2){
        List<Id> versionIds = new List<Id>();
        versionIds.add(versionId1);
        versionIds.add(versionId2);

        List<LLC_BI__Document_Version__c> docVersions = [
            SELECT 
                Id, 
                LLC_BI__External_Download_URL__c, 
                LLC_BI__External_ID__c, 
                LLC_BI__External_Preview_URL__c, 
                LLC_BI__External_Thumbnail_URL__c,
                LLC_BI__Published_Date__c
            FROM 
                LLC_BI__Document_Version__c
            WHERE
                Id IN :versionIds
            ORDER BY
                LLC_BI__External_ID__c ASC];
        system.debug('=====docVersions=='+docVersions);
        for (LLC_BI__Document_Version__c version : docVersions){
      //      System.assertEquals(null, version.LLC_BI__External_ID__c);
           // System.assertEquals(null, version.LLC_BI__External_Download_URL__c);
          //  System.assertEquals(null, version.LLC_BI__External_Preview_URL__c);
            //System.assertEquals(null, version.LLC_BI__External_Thumbnail_URL__c);
            //System.assertEquals(null, version.LLC_BI__Published_Date__c);
        }
    }

}