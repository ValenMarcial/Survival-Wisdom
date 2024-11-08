# frozen_string_literal: true

require 'rspec'
require 'rack/test'
require 'spec_helper'
require_relative '../server'


RSpec.describe 'Endpoints' do

    describe 'Unauthorized access' do
        rutas = [
        '/', '/home', '/skills', '/skills/shelter', '/skills/guideShelter.pdf', '/skills/fire',
        '/skills/guideFire.pdf', '/skills/food', '/skills/guideFood.pdf', '/skills/medicine',
        '/skills/guideMedicine.pdf', '/skills/water', '/skills/guideWater.pdf', '/keep_it_alive',
        '/keep_it_alive/init', '/about', '/account', 'leaderboard', '/keep_it_alive/playing'
        ]
        rutas.each do |ruta|
        describe "GET #{ruta}" do
            it 'redirects unauthorized users to login' do
            get ruta
            expect(last_response.status).to eq(302)
            expect(last_response.headers['Location']).to include('/login')
            end
        end
        end
    end


    describe 'Routes redirection tests' do
        before do
        # Simulate logging in for protected routes
        post '/login', first: 'testuser1', password: 'password'
        end
    
        it 'handles all GET routes correctly' do
        # Unauthenticated route
        get '/register'
        expect(last_request.path).to eq('/register')
    
        # Authenticated routes
        ['/skills', '/keep_it_alive', '/about', '/account', '/leaderboard'].each do |path|
            get path
            expect(last_request.path).to eq(path)
        end
        end
    
    end
    
    describe 'Index redirect' do 
        
        it 'redirects unlogged users from root to /login' do
            get '/'
            expect(last_response.status).to eq(302)
            follow_redirect!
            expect(last_request.path).to eq('/login')
            end
        
        it 'redirects logged users from root to /home' do
            post '/login', first: 'testuser1', password: 'password'
            get '/'
            expect(last_response.status).to eq(302)
            follow_redirect!
            expect(last_request.path).to eq('/home')
        end
    end
      

    describe 'Enter skills' do
        rutas2 = %w[
        shelter
        fire
        food
        medicine
        water
        ]

        rutas2.each do |ruta2|
        describe "GET #{ruta2}" do
            it 'visitar endpoint' do
            post '/login', first: 'testuser1', password: 'password'
            get "/skill/#{ruta2}"
            expect(last_response.status).to eq(200)
            expect(last_request.path).to eq("/skill/#{ruta2}")
            end
        end
        end

        guias = %w[
        Shelter
        Fire
        Food
        Medicine
        Water
        ]

        guias.each do |guia|
        describe 'pdfs' do
            it 'returns the PDF file' do
            post '/login', first: 'testuser1', password: 'password'
            get "/skill/guide#{guia}.pdf"
            expect(last_response.status).to eq(200)
            expect(last_response.headers['Content-Type']).to eq('application/pdf')
            end
        end
        end
    end

    
    # Si te deslogeas y queres entrar a una ruta no te tiene que dejar:
    describe 'User Logout' do
        it 'successfully logs out the user and redirects to login' do
        post '/login', first: 'testuser1', password: 'password'
        expect(last_response).to be_redirect
        follow_redirect!

        get '/logout'
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.path).to eq('/login')

        get '/skills'
        expect(last_response.status).to eq(302)
        follow_redirect!
        expect(last_request.path).to eq('/login')
        end
    end

    
  describe 'GET /back-to-home' do
    it 'redirects to the home page' do
      # logeo el usuario:
      post '/login', first: 'testuser1', password: 'password'
      # Realiza una solicitud GET a la ruta /back-to-home
      get '/back-to-home'

      # Verifica que la respuesta sea una redirección
      expect(last_response).to be_redirect

      # Sigue la redirección
      follow_redirect!

      # Verifica que después de la redirección la URL sea /home
      expect(last_request.path).to eq('/home')
    end
  end
end
