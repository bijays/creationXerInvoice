@RestResource(urlMapping='/BlockList/*')
global without sharing class BlockRestService  {

    public class NodeJsResponseWrapper {
        //public String title;    //name
        //public String subtitle; //Would you like to view this
        //public String image_url;    //
        public ButtonsArray[] buttons;
        
    }
    public class ButtonsArray {
        public String type; //postback
        public String title;    //View Exhibitors
        public String payload;  //view_contacts,
    }


    @HttpGet
    global static string getBlockDetails() {

        String response = '';
        String keyWord = RestContext.request.params.get('keyWord');
        Block__c block = [Select Id,
                                Name,
                                Title__c,
                                Type__c 
                                From Block__c limit 1];

        BlockRestService.NodeJsResponseWrapper resp = new BlockRestService.NodeJsResponseWrapper();
        //resp.title = block.Name;
        //resp.subtitle = 'Would you like to view this';//This neesds to be put in custom seetings
        //resp.image_url = 'www.google.com';

        BlockRestService.ButtonsArray buttonObj = new BlockRestService.ButtonsArray();
        //resp.ButtonsArray buttonObj = new resp.ButtonsArray();
        buttonObj.type = 'postback';
        buttonObj.title = block.Title__c;
        buttonObj.payload = 'view_contacts';
        
        //resp.buttons respButton = new resp.buttons();
        //resp.buttons buttonList = new resp.buttons();
        List<ButtonsArray> buttnArray = new List<ButtonsArray>();
        buttnArray.add(buttonObj);
        resp.buttons = buttnArray;
        
        response = String.valueOf(JSON.serializePretty(resp));
        String formatStartResponse = response.removeStart('{');
        String formatEndResponse = formatStartResponse.removeEnd('}');
        
        System.debug('$$$$$responseformatted'+formatEndResponse);
        System.debug('$$$$$'+String.valueOf(JSON.serializePretty(formatEndResponse)));
        
        return formatEndResponse;

    }

}