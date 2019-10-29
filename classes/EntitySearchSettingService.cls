public with sharing class EntitySearchSettingService {
      
    public static EntitySearchSettings__mdt getCurrentEntitySearchSetting(){
        return EntitySearchSettingSelectorWS.getCurrentEntitySearchSetting();
    }
}