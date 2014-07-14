module HomeHelper
	class GoogleApiClient

    class << self
      def get_for(linked_account)
        client = GoogleApiClient.new
        client_secret = ClientSecrets.get_client('google')
        access_token = linked_account["access_token"]
        refresh_token = JSON.parse(linked_account["additional_params"])["refresh_token"] if linked_account["additional_params"]
        client.authorization(:client_id => client_secret.client_id ,:client_secret => client_secret.client_secret, :access_token => access_token, :refresh_token => refresh_token)

        client
      end
    end

    def upload_file(file_metadata, file_path)
      drive = @client.discovered_api('drive', 'v2')

      file = drive.files.insert.request_schema.new({
        'title' => file_metadata['path'].split('/').last,
        'description' => 'A file from dropbox',
        'mimeType' => file_metadata['mime_type']
      })

      media = Google::APIClient::UploadIO.new(file_path, file_metadata['mime_type'])

      result = retry_with(Proc.new {@client.authorization.fetch_access_token!}, 1) do
          @client.execute(:api_method => drive.files.insert, :body_object => file, :media => media, :parameters => {'uploadType' => 'multipart'})
        end

      raise "Exception while trying to upload file to google drive - #{result.data}" unless result.success?
    end


    def get_user_info
      plus = @client.discovered_api('plus')

      result = @client.execute(:api_method => plus.people.get, :parameters => {'userId' => 'me'})
      
      raise "Exception while trying to fetch user info - #{result.data}" unless result.success?
      result.data.to_hash 
    end

    def authorization(auth_params)
      @client.authorization.client_id = auth_params[:client_id]
      @client.authorization.client_secret = auth_params[:client_secret]
      @client.authorization.access_token = auth_params[:access_token]
      @client.authorization.refresh_token = auth_params[:refresh_token]
    end

    def access_token=(access_token)
      @client.authorization.access_token = access_token
    end

    def refresh_token=(refresh_token)
      @client.authorization.refresh_token = refresh_token
    end

    private
      def initialize
        @client = Google::APIClient.new(:application_name => "D2DSync", :application_version => '1.0.0')
      end 

      def retry_with(before_retry, times, &block)
        reponse = yield
        times.times do
          before_retry.call
          reponse = yield
        end unless reponse.success?
        reponse
      end
  end
end
