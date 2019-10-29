@isTest
public with sharing class TestECMOffloader {

	@TestSetup
	private static void setupData(){
		installNDOCSystemProperties();
	}

	@isTest
	private static void testActivation_onActivate_createSystemProperties() {
		Test.startTest();
		new ECMOffloader.ECMActivator().onActivate();
		Test.stopTest();

		verifyPluginConfigurationsInstalled();
		verifyNDOCSystemPropertiesUpdated(ECMOffloader.PLUGIN_NAME, ECMOffloader.PLUGIN_VERSION);
	}

	@isTest
	private static void testActivation_onDeactivate_clearNDOCSystemPropertyValues() {
		new ECMOffloader.ECMActivator().onActivate();

		verifyPluginConfigurationsInstalled();
		verifyNDOCSystemPropertiesUpdated(ECMOffloader.PLUGIN_NAME, ECMOffloader.PLUGIN_VERSION);

		Test.startTest();
		new ECMOffloader.ECMActivator().onDeactivate();
		Test.stopTest();
		
		verifyNDOCSystemPropertiesUpdated(null, null);
	}

	@isTest
	private static void testActivation_onActivate_registerTriggerBeans() {
		Test.startTest();
		new ECMOffloader.ECMActivator().onActivate();
		Test.stopTest();

		System.assert(verifyBeanInstallation());
	}

	@isTest
	private static void testActivation_onDeactivate_deregisterTriggerBeans() {
		new ECMOffloader.ECMActivator().onActivate();

		verifyPluginConfigurationsInstalled();
		verifyNDOCSystemPropertiesUpdated(ECMOffloader.PLUGIN_NAME, ECMOffloader.PLUGIN_VERSION);

		Test.startTest();
		new ECMOffloader.ECMActivator().onDeactivate();
		Test.stopTest();
		
		System.assert(!verifyBeanInstallation());
	}

	private static Boolean verifyBeanInstallation(){
		if(nforce.BeanFactory.getInstance().getBeanByUniqueName(ECMOffloader.BEAN_TRIGGER_HANDLER) == null){
			return false;
		}
		return true;
	}

	private static void verifyPluginConfigurationsInstalled(){
		nFUSE.PluginConfigurationManager configManager =
			new nFUSE.PluginConfigurationManager(ECMOffloader.PLUGIN_NAME, ECMOffloader.PLUGIN_VERSION);
		List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = configManager.getConfigurations();

		List<String> keysToCheck = expectedProperties.clone();
		System.assertEquals(6, keysToCheck.size());
		for(nFUSE.PluginConfigurationManager.PluginConfiguration currentConfig : configs) {
			removeValueFromList(keysToCheck, currentConfig.key);
		}
		System.assertEquals(0, keysToCheck.size());
	}

	private static void removeValueFromList(List<Object> theList, Object theValue) {
		for(Integer i = 0; i < theList.size(); i++) {
			if(theList.get(i) == theValue) {
				theList.remove(i);
				return;
			}
		}
	}

	private static void installNDOCSystemProperties(){
		List<nFORCE__System_Properties__c> props = new List<nFORCE__System_Properties__c>();
		nFORCE__System_Properties__c prop1 = new nFORCE__System_Properties__c(
			Name = 'TEST ECM PROP1',
			nFORCE__Category_Name__c = ECMOffloader.PLUGIN_CONFIG_CATEGORY,
			nFORCE__Key__c = 'ecm_plugin_name',
			nFORCE__Value__c = null,
			nFORCE__Is_Active__c = true,
			nFUSE__Value_Data_Type__c = 'TEXT'
		);
		nFORCE__System_Properties__c prop2 = new nFORCE__System_Properties__c(
			Name = 'TEST ECM PROP2',
			nFORCE__Category_Name__c = ECMOffloader.PLUGIN_CONFIG_CATEGORY,
			nFORCE__Key__c = 'ecm_plugin_version',
			nFORCE__Value__c = null,
			nFORCE__Is_Active__c = true,
			nFUSE__Value_Data_Type__c = 'TEXT'
		);
		insert new List<SObject>{prop1, prop2};
	}

	private static void verifyNDOCSystemPropertiesUpdated(String prop1, String prop2){
		List<nFORCE__System_Properties__c> props = getNDOCSystemProperties();
		System.assertEquals(2, props.size());
		Boolean found1 = false;
		Boolean found2 = false;
		for(nFORCE__System_Properties__c prop : props){
			if(prop.nFORCE__Value__c == prop1){
				found1 = true;
			}
			if(prop.nFORCE__Value__c == prop2){
				found2 = true;
			}
		}
		System.assert(found1);
		System.assert(found2);
	}

	private static List<nFORCE__System_Properties__c> getNDOCSystemProperties(){
		List<nFORCE__System_Properties__c> props = [
			SELECT
				Id,
				nFORCE__Value__c
			FROM
				nFORCE__System_Properties__c
			WHERE
			nFORCE__Category_Name__c =: ECMOffloader.PLUGIN_CONFIG_CATEGORY
			AND
			nFORCE__Is_Active__c = true
		];
		return props;
	}

	private static List<String> expectedProperties = new List<String> {
		ECMOffloader.CRITERIA_BASED_OFFLOAD_KEY,
		ECMOffloader.DELETE_AFTER_OFFLOAD_KEY,
		ECMOffloader.USERNAME_KEY,
		ECMOffloader.PASSWORD_KEY,
		ECMOffloader.DELETE_AFTER_OFFLOAD_RETENTION_KEY,
		ECMOffloader.API_KEY
	};
}