function openDoc(url){
	 window.open(url);
}

function getOffersNameSpace(){
	var namespace = '';
	var url = window.location.href;
	var basicUrl = url.split('/')[2];
	if (basicUrl.indexOf('offers') > -1){
		namespace = 'Offers__';
	}
	return namespace;
}