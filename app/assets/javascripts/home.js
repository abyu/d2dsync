// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).ready(function () {
	$('.copy').bind('click', function(){
		
		$('.copy').attr('disabled','disabled');
		$('#sync_status').show();
		$('#sync_status').html("File copy from your dropbox account to google drive has been initiated, please wait...");
		$.ajax({
			type: 'GET',
	    url: '/home/sync',
		  success: function(result) {
	         	$('#sync_status').html('File has been copied over to your google drive home page.');
	         	$('#initiate_sync').show();
            $('.copy').removeAttr('disabled');
	    },
			error: function(result){
          $('#sync_status').html('There was an error when trying to sync, please try again.');
				$('#initiate_sync').show();
        $('.copy').removeAttr('disabled');
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