module ClientSecrets

  class << self
  	def get_client(client_name, client_secrets_file="client_secrets.json")
      client_json = clients_json(client_secrets_file)[client_name] 
      raise "client #{client_name} not found in #{client_secrets_file}" unless client_json

      ClientSecret.new(client_json)
  	end

    def clients_json(client_secrets_file)
      client_secrets = JSON.parse(File.read(client_secrets_file))
    end
  end
end

class ClientSecret
  attr_accessor :client_id, :client_secret, :uri

  def initialize(params)
    @client_id = get_param(params, "client_id")
    @client_secret = get_param(params, "client_secret")
    @uri = get_param(params, "oauth_url")
  end

  def get_param(params, key)
    params[key] or raise InvalidClientJSONError
  end

  def request_token_uri

  end
end

class InvalidClientJSONError < Exception
end