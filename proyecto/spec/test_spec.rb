ENV['APP_ENV'] = 'test'

require_relative '../server.rb'
require 'rspec'
require 'rack/test'
require './models/user'

RSpec.describe 'The Server' do
  include Rack::Test::Methods

  def app
    # Sinatra::Appplication
    App
  end


  describe 'POST /login' do
    user = User.new
    user.username = 'testuser'
    user.password = 'password'
    user.nickname = 'nickname'
    user.save

    it 'logs in the user with correct credentials' do
      post '/login', first: 'testuser', password: 'password'
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/home')
    end

    it 'renders login page with error on invalid credentials' do
      post '/login', first: 'testuser', password: 'wrongpassword'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Credenciales inválidas')
    end
  end

  describe 'POST /register' do
    it 'registers a new user' do
      post '/register', first: 'newusera', password: 'password', nickname: 'newnickname'
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
      expect(last_response.body).to include("El nombre de usuario ya está en uso. Por favor, elige otro nombre de usuario.")
    end
  end

  #Unauthorized User:
  #Simulate an unauthorized user by not setting any user session in the test.
  #Try to access a protected route, like /home.
  #Assert that the response redirects to the login page (/login).
  describe 'GET /home' do
    it 'redirects unauthorized users to login' do
      get '/home'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /users' do
    it 'redirects unauthorized users to login' do
      get '/users'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills' do
    it 'redirects unauthorized users to login' do
      get '/skills'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/shelter' do
    it 'redirects unauthorized users to login' do
      get '/skills/shelter'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/guideShelter.pdf' do
    it 'redirects unauthorized users to login' do
      get '/skills/guideShelter.pdf'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/fire' do
    it 'redirects unauthorized users to login' do
      get '/skills/fire'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/guideFire.pdf' do
    it 'redirects unauthorized users to login' do
      get '/skills/guideFire.pdf'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/food' do
    it 'redirects unauthorized users to login' do
      get '/skills/food'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/guideFood.pdf' do
    it 'redirects unauthorized users to login' do
      get '/skills/guideFood.pdf'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/medicine' do
    it 'redirects unauthorized users to login' do
      get '/skills/medicine'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/guideMedicine.pdf' do
    it 'redirects unauthorized users to login' do
      get '/skills/guideMedicine.pdf'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/water' do
    it 'redirects unauthorized users to login' do
      get '/skills/water'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /skills/guideWater.pdf' do
    it 'redirects unauthorized users to login' do
      get '/skills/guideWater.pdf'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /keep_it_alive' do
    it 'redirects unauthorized users to login' do
      get '/keep_it_alive'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /keep_it_alive/init' do
    it 'redirects unauthorized users to login' do
      get '/keep_it_alive/init'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /about' do
    it 'redirects unauthorized users to login' do
      get '/about'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  describe 'GET /account' do
    it 'redirects unauthorized users to login' do
      get '/account'
      expect(last_response.status).to eq(302) # Found (redirect)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  #Invalid Session:
  #You can create a test where you set an invalid session variable (e.g., non-existent user ID).
  #Access a protected route and assert a redirect to login.
  describe 'GET /home' do
    it 'redirects users with invalid session to login' do
      session[:user_id] = 100 # Non-existent user ID
      get '/home'
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to include('/login')
    end
  end

  #Logged-in User:
  #Create a user and log them in by setting the session[:user_id] with the user's ID.
  #Access a protected route and assert a successful response.
  describe 'GET /home' do
    it 'allows access to logged-in users' do
      user = User.create(username: 'testuser', password: 'password')
      session[:user_id] = user.id
      get '/home'
      expect(last_response.status).to eq(200) # OK
    end
  end

end