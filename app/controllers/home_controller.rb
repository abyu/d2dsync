class HomeController < ApplicationController
	require 'dropbox_sdk'
  require 'google/api_client'
	before_action :set_user

  DEFAULT_FILE = "no_file.txt"

	def index
	
	end

  def logout
    session[:user_id] = nil
    redirect_to "/"
  end


	def sync
    dropbox_account = @user.linked_account.find { |account| account.account_type == 'dropbox'}

		dropbox_client = DropboxClient.new(dropbox_account[:access_token])
    file_metadata = find_file(dropbox_client.metadata('/'), dropbox_client)
    file_path = file_metadata ? download_file(file_metadata, dropbox_client) : default_file
    file_metadata = default_file_metadata unless file_metadata
      
    upload_file_to_drive(file_metadata, file_path)
    render json: {:status => "success", :message => "#{file_metadata['path']}"}

	end

  private

  def default_file
    p "No file was found, defaulting to #{DEFAULT_FILE}"
    DEFAULT_FILE
  end

  def default_file_metadata
    {
      "path" => "#{DEFAULT_FILE}",
      "mime_type" => "text/plain"
    }
  end
  
  def find_file(folder_metadata, client)
    folder_metadata['contents'].each do |content|
      if content['is_dir']
        p "#{content['path']} is a directory, searching in..."
        file = find_file(client.metadata(content['path']), client)
        return file if file
      else
        return content
      end
    end
    nil
  end

  def download_file(file_metadata, client)
    contents, metadata = client.get_file_and_metadata(file_metadata["path"])
    local_file_path = metadata["path"].split("/").last

    open("#{local_file_path}", 'w') {|f| f.puts contents }

    local_file_path
  end


	def set_user
    if(session[:user_id])
      @user = User.find(session[:user_id])
    else
      redirect_to '/'
    end
  end

  def upload_file_to_drive(file_metadata, file_path)
    google_account = @user.linked_account.find { |account| account.account_type == 'google'}
    google_client = HomeHelper::GoogleApiClient.get_for(google_account)

    google_client.upload_file(file_metadata, file_path)
  end

end
