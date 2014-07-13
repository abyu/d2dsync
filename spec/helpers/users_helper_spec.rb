require 'rails_helper'

RSpec.describe UsersHelper, :type => :helper do 
	describe "create user" do
    before(:each) do
      User.stub(:save) { true }
    end

    it "with given params" do
      user_params = {
      :user => {
        :email_address => "myemail@domain.com",
        :name => "Iam King"
      }}
      user = create_user(user_params)

      expect(user).not_to be_nil  
      expect(user.email_address).to eq("myemail@domain.com")
      expect(user.name).to eq("Iam King")
    end

    it "with given linked accounts" do
      user_params = {
        :user => {
          :email_address => "myemail@domain.com",
          :name => "Iam King"
        },
        :linked_accounts => [
          {
            :linked_account => {
              :account_type => "google",
              :access_token => "blajclasld",
              :linked_user_id => "3kja734lf"
            }
          }
        ]
      }

      user = create_user(user_params)

      expect(user.linked_account.count).to eq(1)    
      linked_account = user.linked_account.first

      expect(linked_account.account_type).to eq("google")
    end

    describe "create user multiple linked account" do
      before(:each) do
         user_params = {
          :user => {
            :email_address => "myemail@domain.com",
            :name => "Iam King"
          },
          :linked_accounts => [
            {
              :linked_account => {
                :account_type => "google",
                :access_token => "blajclasld",
                :linked_user_id => "3kja734lf"
              }
            },
            {
              :linked_account => {
                :account_type => "dropbox",
                :access_token => "blajclasld",
                :linked_user_id => "3kja734lf"
              }
            }
          ]
        }

        @user = create_user(user_params)
      end

      it "has first linked account with sequence 0" do
        expect(@user.linked_account.first.sequence).to eq(0)
      end

      it "had second linked account with sequence 1" do
        expect(@user.linked_account.second.sequence).to eq(1)
      end
    end

    describe "add linked account to existing user with same email_address" do
      before(:each) do

         user_params = {
          :user => {
            :email_address => "myemail@domain.com",
            :name => "Iam King"
          },
          :linked_accounts => [
            {
              :linked_account => {
                :account_type => "google",
                :access_token => "blajclasld",
                :linked_user_id => "3kja734lf"
              }
            }
          ]
        }
        @user = create_user(user_params)
        User.stub :find_by => @user
      end

      it "update the user with the new linked_account" do
        user_params = {
          :user => {
            :email_address => "myemail@domain.com",
            :name => "Iam King"
          },
          :linked_accounts => [
            {
              :linked_account => {
                :account_type => "facebook",
                :access_token => "blajclasld",
                :linked_user_id => "3kja734lf"
              }
            }
          ]
        }

        @user = create_user(user_params)
        new_account = @user.linked_account.find { |acc| acc.account_type == 'facebook'}
        
        expect(@user.linked_account.count).to eq(2)
        expect(new_account).not_to be_nil
      end
    end

    describe "add linked account to existing user in the session" do
      before(:each) do
         user_params = {
          :user => {
            :email_address => "myemail@domain.com",
            :name => "Iam King"
          },
          :linked_accounts => [
            {
              :linked_account => {
                :account_type => "google",
                :access_token => "blajclasld",
                :linked_user_id => "3kja734lf"
              }
            }
          ]
        }
        @user = create_user(user_params)

        session[:user_id] = 1
        User.stub(:find).with(1) { @user }

      end

      it "update the user with the new linked_account" do
        user_params = {
          :user => {
            :email_address => "myemail@domain.com",
            :name => "Iam King"
          },
          :linked_accounts => [
            {
              :linked_account => {
                :account_type => "facebook",
                :access_token => "blajclasld",
                :linked_user_id => "3kja734lf"
              }
            }
          ]
        }

        @user = create_user(user_params)
        new_account = @user.linked_account.find { |acc| acc.account_type == 'facebook'}
        
        expect(@user.linked_account.count).to eq(2)
        expect(new_account).not_to be_nil
      end
    end
  end

  describe "revoke user linked_account" do
    before(:each) do
      User.stub :save => true
      user_params = {
        :user => {
          :email_address => "myemail@domain.com",
          :name => "Iam King"
        },
        :linked_accounts => [
          {
            :linked_account => {
              :account_type => "google",
              :access_token => "blajclasld",
              :linked_user_id => "3kja734lf"
            }
          },
          {
            :linked_account => {
              :account_type => "facebook",
              :access_token => "blajclasld",
              :linked_user_id => "3kja734lf"
            }
          }

        ]
      }
      @user = create_user(user_params)
      revoke_linked_account(@user, 'google')
    end

    it "delete linked_account for given account type" do
      expect(@user.linked_account.count).to eq(1)
    end

    it "update sequence number for existing linked_account" do
      expect(@user.linked_account.first.sequence).to eq(0)
    end
  end
end
