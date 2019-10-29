public with sharing class TestFactory {    

    public static List<SObject> createNewSobject(String sObjectAPIName, Integer noOfsObjects) 
    {
        Schema.SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectAPIName);
 
        // Instantiate the sobject from the token.
        List<Sobject> sObjs = new List<sObject>();

        Schema.DescribeSObjectResult descObj = schemaType.getDescribe();

        Map<String, Schema.SObjectField> fields = descObj.fields.getMap();

        Integer counter = 0;
        for(Integer i = 0; i < noOfsObjects; i++){
            Sobject sObj = schemaType.newSobject();
            for(String f : fields.keyset())
            {         

                Schema.DescribeFieldResult desribeResult = fields.get(f).getDescribe();
                if( desribeResult.isCreateable() && !desribeResult.isNillable() && !desribeResult.isDefaultedOnCreate() )
                {
                    System.debug('desribeResult.getName() >>>>'+desribeResult.getName());
                    sObj.put(desribeResult.getName(), 'Test '+counter);
                    //This is mandatory / required field
                    ++counter;
                }                
            }
            sObjs.add(sObj);
        }
        return sObjs;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr ='';
        while (randStr.length() < len) {
        Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}