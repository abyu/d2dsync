// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function () {
	
	$('.google-signin').bind('click', function() {
		window.location = "https://accounts.google.com/o/oauth2/auth?scope=https://www.googleapis.com/auth/plus.login https://www.googleapis.com/auth/plus.profile.emails.read https://www.googleapis.com/auth/drive.file&state=%2Fprofile&redirect_uri=http://localhost:3000/identify/google&response_type=code&client_id=925341752581-oeg0c5vqlkf63u68rclmf1odtcpcd24f.apps.googleusercontent.com&access_type=offline"
		
	});

	$('.dropbox-signin').bind('click', function(){
		window.location = "https://www.dropbox.com/1/oauth2/authorize?client_id=0bvytmw1toy1gve&redirect_uri=http://localhost:3000/identify/dropbox&response_type=code&state=oas_hxgzlztg_0.t4bitsk4hn09t3xr"
	});
	
});
