module UsersHelper
	def create_user(params)
    user = get_user(params[:user])
    user_linked_account_types = user.linked_account.map { |account| account.account_type}
    params[:linked_accounts].each_with_index do |linked_account, index|
      lparams = ActionController::Parameters.new(linked_account[:linked_account])
      acc = LinkedAccount.new(lparams.permit(:account_type, :access_token, :linked_user_id, :additional_params))
      acc.sequence = user.linked_account.count
      p acc
      user.linked_account << acc unless (user_linked_account_types.include? acc.account_type)
    end
    raise "Failed when trying to save user" unless user.save
    user
	end

  def revoke_linked_account(user, account_type)
    linked_account = user.linked_account.find { |account| account.account_type == account_type}
    user.linked_account.destroy(linked_account)

    user.linked_account.sort_by { |account| account.sequence}.each_with_index do |account, index|
      account.sequence = index
    end

    raise "Failed when trying to save user" unless user.save
  end

  def get_user(user_params)
    session_user = session[:user_id]? User.find(session[:user_id]) : nil;
    user = session_user || User.find_by(:email_address => user_params[:email_address])
    user || User.new(user_params)
  end
end
