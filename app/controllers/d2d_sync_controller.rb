class D2dSyncController < ApplicationController
	:before_action 

	require 'dropbox_sdk'
	def index
		redirect_to '/home' if session[:user_id]	
	end

	def sync
    
	end
end
