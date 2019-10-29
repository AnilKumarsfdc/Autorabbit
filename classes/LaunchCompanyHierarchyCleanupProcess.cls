public with sharing class LaunchCompanyHierarchyCleanupProcess {
    @InvocableMethod
    public static void invokeCleanupBatches() {
        System.debug('Clean up process launched');
        Database.executeBatch(new CompanySocialMediaSyncCleanup());
    }
}