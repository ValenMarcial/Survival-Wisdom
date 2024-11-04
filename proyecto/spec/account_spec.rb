# frozen_string_literal: true


require 'rspec'
require 'rack/test'
require 'spec_helper'
require_relative '../server'

RSpec.describe 'Account Management' do
    before(:all) do
      @user = User.create(username: 'testuser1', password: 'password', nickname: 'nickname')
    end
  
    describe 'POST /change_nickname' do
      it 'updates the users nickname' do
        post '/login', first: 'testuser1', password: 'password'
        post '/change_nickname', new_nickname: 'NewNickname'
        user = User.find_by(username: 'testuser1')
        expect(user.nickname).to eq('NewNickname')
      end
    end
  
    describe 'POST /change_password' do
      it 'updates the users password' do
        post '/login', first: 'testuser1', password: 'password'
        post '/change_password', password: 'Newpassword'
  
        post '/login', first: 'testuser1', password: 'Newpassword'
        expect(last_response).to be_ok
      end

      it 'Wrong password' do
        post '/login', first: 'testuser1', password: 'password'
        post '/change_password', password: ''

        expect(last_request.path).to eq('/change_password')
      end

    end
  end
  