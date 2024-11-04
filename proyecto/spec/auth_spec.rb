# frozen_string_literal: true

require 'rspec'
require 'rack/test'
require 'spec_helper'
require_relative '../server'

RSpec.describe 'Authentication' do

    describe 'POST /login' do
        user = User.new
        user.username = 'testuser1'
        user.password = 'password'
        user.nickname = 'nickname'
        user.save
    
        it 'logs in the user with correct credentials' do
          post '/login', first: 'testuser1', password: 'password'
          expect(last_response).to be_redirect
          follow_redirect!
          expect(last_request.path).to eq('/home')
        end
    
        it 'renders login page with error on invalid credentials' do
          post '/login', first: 'testuser1', password: 'wrongpassword'
          expect(last_response).to be_ok
          expect(last_response.body).to include('Credenciales inválidas')
        end
      end

      describe 'POST /register' do
        it 'registers a new user' do
          post '/register', first: 'newuser1', password: 'password', nickname: 'newnickname'
          expect(last_response).to be_redirect
          follow_redirect!
          expect(last_request.path).to eq('/login')
        end
    
        it 'renders register page with error if username already taken' do
          user = User.new
          user.username = 'existinguser'
          user.password = 'password'
          user.nickname = 'nickname'
          user.save
    
          post '/register', first: 'existinguser', password: 'password', nickname: 'nickname'
          expect(last_response).to be_ok
          expect(last_response.body).to include('El nombre de usuario ya está en uso.')
        end
      end

      describe '.authenticate' do
        it 'authenticate a valid account' do
          username = 'testuser1'
          password = 'password'
          user = User.find_by(username: username)
    
          expect(User.authenticate(username, password)).to eq(user)
        end
    
        it 'Wrong credentials' do
          username = 'notuser'
          password = 'notpassword'
          User.find_by(username: username)
    
          expect(User.authenticate(username, password)).to eq(nil)
        end
      end

end
