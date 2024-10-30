//called from ExternalInterface, airbadge swf: addDownloadCount()
function count_airbadge_click(obj){
	if(obj.siteurl!=null){
		ajaxUrl 	= obj.siteurl;
		clickType 	= obj.clicktype;
	}
	//alert("ajaxUrl: "+ajaxUrl+", clicktype: "+clickType);
	if(ajaxUrl!="" && clickType!=""){
		//alert("get url to increase count - clicktype: "+clickType+");
		jQuery.get( ajaxUrl, {airbadge_clicktype:clickType},
				   function(data){
				   		//alert('js getting return data: '+data);
					}, 'text' );
	}
}