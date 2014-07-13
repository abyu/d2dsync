class HomeController < ApplicationController
	require 'dropbox_sdk'
  require 'google/api_client'
	before_action :set_user

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
    file_path = download_file(file_metadata, dropbox_client)
    upload_file_to_drive(file_metadata, file_path)
    render json: {:status => "success"}

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
    google_client = Google::APIClient.new(:application_name => "D2DSync", :application_version => '1.0.0')
    google_client.authorization.client_id = '925341752581-oeg0c5vqlkf63u68rclmf1odtcpcd24f.apps.googleusercontent.com'
    google_client.authorization.client_secret = 'i8D4IBvWzwxK3BhbeHyS-vv0'
    google_client.authorization.access_token = google_account["access_token"]
    google_client.authorization.refresh_token = JSON.parse(google_account["additional_params"])["refresh_token"]

    drive = google_client.discovered_api('drive', 'v2')

    file = drive.files.insert.request_schema.new({
      'title' => file_metadata['path'].split('/').last,
      'description' => 'A file from dropbox',
      'mimeType' => file_metadata['mime_type']
    })

    media = Google::APIClient::UploadIO.new('magnum-opus.txt', file_metadata['mime_type'])
    result = google_client.execute(:api_method => drive.files.insert, :body_object => file, :media => media, :parameters => {'uploadType' => 'multipart', 'alt' => 'json'})

    raise "Exception while trying to upload file to google drive - #{result.data}" unless result.success?
  end

end
