require 'rails_helper'

RSpec.describe ClientSecrets, :type => :helper do
  
  describe "get client secret for given client name" do
  	before (:each) do
  		@client_secret = ClientSecrets.get_client('google', File.join(File.dirname(__FILE__), 'client_secrets_test.json'))
  	end

  	it "reads secrets from client_secrets.json" do
  		expect(@client_secret).not_to be_nil
  	end

  	it "has client_id from the json file" do
  		expect(@client_secret.client_id).to eq("925341752581-oodtcpcd24f.apps.googleusercontent.com")
  	end
   

	  it "has client_secret from the json file" do
  		expect(@client_secret.client_secret).to eq("i8xK3BhbeHyS-vv0")
  	end
   
   	it "has url from the json file" do
  		expect(@client_secret.uri).to eq("https://accounts.google.com/o/oauth2/")
  	end
  end


	describe "get client secret for unknown client name" do
		it "fails with an exception" do
			expect{ClientSecrets.get_client('faulty_client', File.join(File.dirname(__FILE__), 'client_secrets_test.json'))}.to raise_error("client faulty_client not found in #{File.join(File.dirname(__FILE__), 'client_secrets_test.json')}")
		end   	
 	end

 	describe "get client secret for client name with missing json data" do
	 	it "fails with an InvalidClientJSON exception" do
	 		expect{ClientSecrets.get_client('missing_client', File.join(File.dirname(__FILE__), 'client_secrets_test.json'))}.to raise_error(InvalidClientJSONError)
	 	end
 	end

 	describe "error cases" do

 		it "fails for file not present" do	
 			expect{ClientSecrets.get_client('google', File.join(File.dirname(__FILE__), 'random_file.json'))}.to raise_error
 		end

 		it "fails for invalid json data" do
 			expect{ClientSecrets.get_client('missing_client', File.join(File.dirname(__FILE__), 'client_secrets_invalid.json'))}.to raise_error
 		end
 	end

end
