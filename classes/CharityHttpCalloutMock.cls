@isTest
global class CharityHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"data":[{"countryCode":"GB","charityId":"ew-1060919-0","name":"Friends of Callicroft Primary School","firstRegisteredDate":"1997-02-25","isFilingCharity":true,"isSubsidiaryCharity":false,"currentStatus":{"status":"REGISTERED","startDate":"1997-02-25"}},{"countryCode":"GB","charityId":"ew-1057938-0","name":"Friends of St Johns Church, Boreham","firstRegisteredDate":"1996-09-10","isFilingCharity":true,"isSubsidiaryCharity":false,"currentStatus":{"status":"REGISTERED","startDate":"1996-09-10"}},{"countryCode":"GB","charityId":"ew-225971-0","name":"British Heart Foundation","firstRegisteredDate":"1963-03-26","isFilingCharity":true,"isSubsidiaryCharity":false,"currentStatus":{"status":"REGISTERED","startDate":"1963-03-26"},"corporateIdentity":{"countryCode":"GB","companyId":"00699547","name":"British Heart Foundation","officialStatus":"Active","simplifiedStatus":"Active"}}],"paging":{"totalRecords":3,"pageSize":5,"pageNumber":1},"meta":{"code":"000000","messages":["Request processed successfully"]}}');
        response.setStatusCode(200);
        return response; 
    }
}