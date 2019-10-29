global class ECMOffloader {

    global with sharing class ECMActivator implements nFUSE.IPluginActivator {

        public void onActivate() {
            List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs = createProperties();
            new nFUSE.PluginConfigurationManager(PLUGIN_NAME, PLUGIN_VERSION).softInsertConfigurations(configs);

            Map<String, String> keyValueMap = new Map<String, String>{
                ECM_PLUGIN_NAME_KEY => PLUGIN_NAME,
                ECM_PLUGIN_VERSION_KEY => PLUGIN_VERSION
            };
            
            system.debug('-----keyValueMap-----'+keyValueMap);
            updateProperty(keyValueMap);

            registerECMTransactionLogTriggerHandler();
        }

        public void onDeactivate() {
            Map<String, String> keyValueMap = new Map<String, String>{
                ECM_PLUGIN_NAME_KEY => null,
                ECM_PLUGIN_VERSION_KEY => null
            };
            updateProperty(keyValueMap);
system.debug('-----keyValueMap-----'+keyValueMap);
            deregisterECMTransactionLogTriggerHandler();
        }

        private List<nFUSE.PluginConfigurationManager.PluginConfiguration> createProperties() {
            List<nFUSE.PluginConfigurationManager.PluginConfiguration> configs =
                new List<nFUSE.PluginConfigurationManager.PluginConfiguration>();

            for (String key : PROPERTY_MAP.keySet()) {
                nFUSE.PluginConfigurationManager.PluginConfiguration config =
                    new nFUSE.PluginConfigurationManager.PluginConfiguration();

                config.pluginName = PLUGIN_NAME;
                config.pluginVersion = PLUGIN_VERSION;
                config.category = PLUGIN_NAME;
                config.key = key;
                config.value = PROPERTY_MAP.get(key);
                config.valueDataType = 'String';
                config.isEncrypted = false;

                configs.add(config);
            }
            system.debug('-----configs-----'+configs);
            return configs;
        }

        private void updateProperty(Map<String, String> keyValueMap){
            List<nFORCE__System_Properties__c> props = [
                SELECT
                    Id,
                    nFORCE__Key__c
                FROM
                    nFORCE__System_Properties__c
                WHERE
                    nFORCE__Category_Name__c =: PLUGIN_CONFIG_CATEGORY
                AND
                    nFORCE__Key__c IN: keyValueMap.keySet()
                AND
                    nFORCE__Is_Active__c = true
            ];

            if(props != null && !props.isEmpty()){
                for(nFORCE__System_Properties__c prop : props){
                    prop.nFORCE__Value__c = keyValueMap.get(prop.nFORCE__Key__c);
                }
            }
            system.debug('-----props-----'+props);
            nFORCE.DmlUtility.updateObj(props);
        }

        private void registerECMTransactionLogTriggerHandler(){

            nFORCE.BeanRegistry.getInstance().registerBean(
                BEAN_TRIGGER_HANDLER,
                nFORCE.ATriggerHandler.class,
                ECMTransactionLogTriggerHandler.class,
                null,
                true
            );

            nFORCE.BeanRegistry.getInstance().registerBean(
                BEAN_TRIGGER_PIPELINE,
                nFORCE.IPipelineContainer.class,
                nFORCE.TriggerPipeline.class,
                new Map<String, Object> {
                    nFORCE.PipelineContainer.PIPELINE_BEAN_UNIQUE_NAMES => new String[] {
                        BEAN_TRIGGER_HANDLER
                    }
                },
                true
            );
        }

        private void deregisterECMTransactionLogTriggerHandler(){
            nFORCE.BeanRegistry.getInstance().deregisterBean(BEAN_TRIGGER_HANDLER);
            nFORCE.BeanRegistry.getInstance().deregisterBean(BEAN_TRIGGER_PIPELINE);
        }

    }

    @TestVisible
    private Static final String
        PLUGIN_NAME = 'ECM_Offloader',
        PLUGIN_VERSION = '1.0',
        PLUGIN_CONFIG_CATEGORY = 'ECM Offloader',
        CRITERIA_BASED_OFFLOAD_KEY = 'criteria_based_offload',
        CRITERIA_BASED_OFFLOAD_VALUE = 'false',
        DELETE_AFTER_OFFLOAD_KEY = 'delete_after_offload',
        DELETE_AFTER_OFFLOAD_VALUE = 'false',
        DELETE_AFTER_OFFLOAD_RETENTION_KEY = 'delete_after_offload_retention',
        ECM_PLUGIN_NAME_KEY = 'ecm_plugin_name',
        ECM_PLUGIN_VERSION_KEY = 'ecm_plugin_version',
        USERNAME_KEY = 'username',
        PASSWORD_KEY = 'password',
        PASSWORD_VALUE = '',
        API_KEY = 'api_key',
        API_VALUE = '',
        BEAN_TRIGGER_PIPELINE = 'nFORCE.TriggerPipeline',
        BEAN_TRIGGER_HANDLER = nFORCE.BeanRegistry.getInstance()
        .generateUniqueBeanName(ECMTransactionLogTriggerHandler.class, 'ecm-transaction-log-pipeline-handler');

    @TestVisible
    private Static final Map<String, String> PROPERTY_MAP = new Map<String, String>{
        CRITERIA_BASED_OFFLOAD_KEY => CRITERIA_BASED_OFFLOAD_VALUE,
        DELETE_AFTER_OFFLOAD_KEY => DELETE_AFTER_OFFLOAD_VALUE,
        DELETE_AFTER_OFFLOAD_RETENTION_KEY => '',
        USERNAME_KEY => '',
        PASSWORD_KEY => '',
        API_KEY => ''
    };
}