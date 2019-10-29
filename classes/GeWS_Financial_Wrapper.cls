public class GeWS_Financial_Wrapper {
    public class Spreads_Record_Value {
        public string technical_key;
        public string column_index;
        public string value_string;
        public string value_float;
        public string value_integer;
        public string value_date;
        public string value_boolean;
        
        public Spreads_Record_Value( String technical_keyArg,
                                     String column_indexArg,
                                     String value_stringArg,
                                     String value_floatArg,
                                     String value_integerArg,
                                     String value_dateArg,
                                     String value_booleanArg  ){
                                         
            this.technical_key = technical_keyArg;
            this.column_index = column_indexArg; 
            this.value_string = value_stringArg; 
            this.value_float = value_floatArg; 
            this.value_integer = value_integerArg; 
            this.value_date = value_dateArg; 
            this.value_boolean = value_booleanArg;
        }
        
    }
    
    public class Spreads_Record_Element{
        
        public list<GeWS_Financial_Wrapper.Spreads_Record_Value> element;
        
        public Spreads_Record_Element( list<GeWS_Financial_Wrapper.Spreads_Record_Value> elementArg ){
            this.element = elementArg;
        }
    }

    public class relation {
        public string external_statement_id;
        public string relationship_type;
        public string internal_statement_id;
        
        public relation( String external_statement_idArg,
                         String relationship_typeArg,
                         String internal_statement_idArg ){
                             
            this.external_statement_id = external_statement_idArg;
            this.relationship_type = relationship_typeArg;
            this.internal_statement_id = internal_statement_idArg;
        }
        
    }
    
    public class Spreads_Data {
        public string sheet_technical_name;
        public GeWS_Financial_Wrapper.Spreads_Record_Element sheet_data;
        
        public Spreads_Data( String sheet_technical_nameArg,
                             GeWS_Financial_Wrapper.Spreads_Record_Element sheet_dataArg){
        
            this.sheet_technical_name = sheet_technical_nameArg;
            this.sheet_data = sheet_dataArg;
            
        }
        
    }
    
    public class Spreads_Data_Element {
        list<GeWS_Financial_Wrapper.Spreads_Data> element;
        
        public Spreads_Data_Element( list<GeWS_Financial_Wrapper.Spreads_Data> elementArg ){
            this.element = elementArg;
        }
    }
    
    public class Spreads_Statement {
        public Map<String,String> meta_information;
        public string template_name;
        public string target_state;
        public GeWS_Financial_Wrapper.Spreads_Data_Element data;
        public string external_statement_id;
        public list<GeWS_Financial_Wrapper.relation> relations;
        
        public Spreads_Statement( Map<String,String> meta_informationArg,
                                  String template_nameArg, 
                                  String target_stateArg,
                                  GeWS_Financial_Wrapper.Spreads_Data_Element dataArg,
                                  string external_statement_idArg,
                                  list<GeWS_Financial_Wrapper.relation> relationsArg ){
                                  
            this.meta_information = meta_informationArg;
            this.template_name = template_nameArg;
            this.target_state = target_stateArg;
            this.data = dataArg;
            this.external_statement_id = external_statement_idArg;
            this.relations = relationsArg;
        }
            
    }
    
    public class Financial_Request {
        public string ncino_process_id;
        public string bdp_id;
        public string test_flag;
        public GeWS_Financial_Wrapper.Spreads_Statement statement;
        
        public Financial_Request( String ncino_process_idArg,
                                  String bdp_idArg, 
                                  String test_flagArg,
                                  GeWS_Financial_Wrapper.Spreads_Statement statementArg ){
            
            this.ncino_process_id = ncino_process_idArg;
            this.bdp_id = bdp_idArg;
            this.test_flag = test_flagArg;
            this.statement = statementArg;
        }
        
    }
    
    public class Financial_Data {
        public GeWS_Financial_Wrapper.Financial_Request request;
        
        public Financial_Data( GeWS_Financial_Wrapper.Financial_Request requestArg ){
            this.request = requestArg;
        }
    }
    
    public class Financial_Request_Data {
        public GeWS_Financial_Wrapper.Financial_Data data;
        
        public Financial_Request_Data( GeWS_Financial_Wrapper.Financial_Data dataArg ){
            this.data = dataArg;
        }
    }
    
    public class Financial_Request_Wrap {
        public string event;
        public string id;
        public string referenceId;
        public GeWS_Financial_Wrapper.Financial_Request_Data requestData;
        
        public Financial_Request_Wrap ( String eventArg,
                                           String idArg,
                                           String referenceIdArg,
                                           GeWS_Financial_Wrapper.Financial_Request_Data requestDataArg ){
            this.event = eventArg;
            this.id = idArg;
            this.referenceId = referenceIdArg;
            this.requestData = requestDataArg;
        }
    }
    
    public class Financial_Request_Payload {
        public GeWS_Financial_Wrapper.Financial_Request_Wrap financialRequest;
        
        public Financial_Request_Payload( GeWS_Financial_Wrapper.Financial_Request_Wrap financialRequestArg ){
            this.financialRequest = financialRequestArg;
        }
        
    }

}