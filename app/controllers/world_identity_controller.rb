class WorldIdentityController < ApplicationController
  before_action :set_user, only: [:revoke_google, :revoke_dropbox]
  before_action :validate_user_acceptance, only: [:google, :dropbox]
  require 'dropbox_sdk'
  require 'net/http'
  require 'json'
  require 'google/api_client'

  include UsersHelper
  def identify

  end

  def google
    google_creds = request_access_token(params[:code], 'google')
    google_client = Google::APIClient.new(:application_name => "D2DSync", :application_version => '1.0.0')
    google_client.authorization.client_id = '925341752581-oeg0c5vqlkf63u68rclmf1odtcpcd24f.apps.googleusercontent.com'
    google_client.authorization.client_secret = 'i8D4IBvWzwxK3BhbeHyS-vv0'
    google_client.authorization.access_token = google_creds["access_token"]
    plus = google_client.discovered_api('plus')

    response = google_client.execute(:api_method => plus.people.get, :parameters => {'userId' => 'me'})
    google_user = response.data.to_hash

    user_params = {
      :user => {
        :email_address =>  google_user["emails"][0]["value"],
        :name => google_user["displayName"]
      },
      :linked_accounts => [
        {
          :linked_account => {
            :account_type => 'google',
            :access_token => google_creds["access_token"],
            :linked_user_id => google_user["id"],
            :additional_params => {
              :refresh_token => google_creds["refresh_token"]
            }.to_json
          }
        }
      ]
    }
    p user_params
    @user = create_user(user_params)
    session[:user_id] = @user.id
    redirect_to :controller => 'home', :action => 'index'
  end

  def revoke_google
    google_account = @user.linked_account.find {|account| account.account_type == 'google'}

    uri = URI.parse("https://accounts.google.com/o/oauth2/revoke?token=#{google_account['access_token']}")
    response = Net::HTTP.get_response(uri)

    if response.kind_of? Net::HTTPSuccess
      revoke_linked_account(@user, 'google')
    else
      raise "exception while trying to revoke google account - #{response.body}"
    end
    redirect_to "/home"
  end

  def revoke_dropbox
    dropbox_account = @user.linked_account.find {|account| account.account_type == 'dropbox'}    
    client = DropboxClient.new(dropbox_account["access_token"])
    response = client.disable_access_token  
    p response.inspect
    revoke_linked_account(@user, 'dropbox')

    redirect_to "/home"  
  end

  def dropbox
    dropbox_creds = request_access_token(params[:code], 'dropbox')
    client = DropboxClient.new(dropbox_creds["access_token"])
    dropbox_user = client.account_info().to_hash
    
    user_params = {
      :user => {
        :email_address =>  dropbox_user["email"],
        :name => dropbox_user["display_name"]
      },
      :linked_accounts => [
        {
          :linked_account => {
            :account_type => 'dropbox',
            :access_token => dropbox_creds["access_token"],
            :linked_user_id => dropbox_user["uid"]
          }
        }
      ]
    }

    @user = create_user(user_params)
    session[:user_id] = @user.id
    redirect_to :controller => 'home', :action => 'index'
  end

  private 
    def request_access_token(code, client)
      client_secrets = JSON.parse(File.read(File.join(File.dirname(__FILE__), "..", 'client_secrets.json')))
      client_secret = client_secrets[client]

      uri = URI.parse("#{client_secret['oauth_url']}token")
      response = Net::HTTP.post_form(uri, "code" => code, "grant_type" => "authorization_code", "client_id" => client_secret["client_id"], "client_secret" => client_secret["client_secret"], "redirect_uri" => "http://localhost:3000/identify/#{client}")
      
      if response.kind_of? Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "exception while trying to make oauth token request - #{response.body}" 
      end
    end

    def set_user
      if(session[:user_id])
        @user = User.find(session[:user_id])
      else
        redirect_to '/'
      end
    end

    def validate_user_acceptance
      if not params[:code]
        redirect_to "/home"
      end
    end
end