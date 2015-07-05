// share facebook and twitter ... etc.

function fbs_click(u, t) {
window.open('http://www.facebook.com/sharer.php?u='+u+'&t='+encodeURIComponent(t),'share','toolbar=0,status=0,width=640,height=480');
return false;
}

function short_url(url) {
	$.shortenUrl.settings.login = "pythonbitly";
	$.shortenUrl.settings.apiKey = "R_06871db6b7fd31a4242709acaf1b6648";

	$.shortenUrl(url, function(shortUrl) {
		$("#shortUrl").attr('value', shortUrl);
	});
}

function getShortUrl() {
	var shortUrl = $("#shortUrl").attr('value');
	return shortUrl;
}

function tws_click(u, t) {

	
		window.open('http://twitter.com/home?status='+encodeURIComponent(t)+' '+encodeURIComponent(u),'share','toolbar=0,status=0,width=640,height=480');

	return false;
}