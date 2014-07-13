// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function () {
	$('.copy').bind('click', function(){
		
		$('#initiate_sync').hide();
		$('#sync_status').show();
		$('#sync_status').html("File copy from your dropbox account to google drive has been initiated, please wait...");
		$.ajax({
			type: 'GET',
	    url: '/home/sync',
		  success: function(result) {
	         	$('#sync_status').html('File has been copied over to your google drive home page.');
	         	$('#initiate_sync').show();
	    },
			error: function(result){
				$('#initiate_sync').show();
			}       
		});
	});

  $('.google-unlink').bind('click', function(){
    window.location = "/revoke/google"
  });

  $('.dropbox-unlink').bind('click', function(){
    window.location = "/revoke/dropbox"
  });

  $('.logout').bind('click', function() {
    window.location = "/logout"
  });

});