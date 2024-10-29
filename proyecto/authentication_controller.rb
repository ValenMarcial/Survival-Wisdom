# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/activerecord'
require 'bcrypt'
require './models/user'
require './models/stat'


# Para autenticar usuario
module Authentication
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end

# class to manage user login/logout and register & change nickname or password
class AuthController < Sinatra::Base
  include Authentication

  set :public_folder, 'assets'
  # Restringe el ingreso a ciertas rutas de la web sin estar logeado
  before do
    redirect '/login' unless ['/login', '/register', '/'].include?(request.path_info) || current_user
  end

  get '/login' do
    erb :'login/index', locals: { error: '' }
  end

  # Inicio de sesion para los usuarios
  post '/login' do
    username = params[:first]
    password = params[:password]

    user = User.authenticate(username, password)

    if user
      session[:user_id] = user.id # Almacena el ID de usuario en la sesión
      redirect '/home'
    else
      # Credenciales inválidas, renderiza nuevamente el formulario de inicio de sesión con un mensaje de error
      erb :'login/index', locals: { error: 'Credenciales inválidas. Por favor, inténtalo de nuevo.' }
    end
  end

  get '/register' do
    erb :'login/register', locals: { error: ' ' }
  end

  # Registra un nuevo usuario en la web
  post '/register' do
    username = params[:first]
    password = params[:password]
    nickname = params[:nickname]
    # Verifica si ya existe un usuario con el mismo nombre de usuario en la base de datos
    existing_user = User.find_by(username: username)

    if existing_user
      # Si ya existe un usuario con el mismo nombre de usuario,
      # puedes renderizar nuevamente el formulario de registro con un mensaje de error
      erb :'login/register',
          locals: { error: 'El nombre de usuario ya está en uso. Por favor, elige otro nombre de usuario.' }
    else
      # Si no existe un usuario con el mismo nombre de usuario,
      # procede a crear uno nuevo y guardarlo en la base de datos
      new_password_digest = BCrypt::Password.create(password)
      user = User.new
      user.username = username
      user.password = new_password_digest
      user.nickname = nickname
      user.coins = 0
      user.admin = 0
      user.save

      session[:user_id] = user.id
      stat = Stat.new
      stat.user_id = session[:user_id] # Asigna el ID del usuario
      stat.days = 0
      stat.save
      redirect '/login'

    end
  end

  # cierra la sesion
  get '/logout' do
    session.clear
    redirect '/login'
  end

  post '/change_nickname' do
    new_nickname = params[:new_nickname]
    current_user = User.find(session[:user_id])
    # Actualiza el nickname del usuario actual
    current_user.update(nickname: new_nickname)
    # Guarda los cambios en la base de datos
    current_user.save
    # Redirige a la página de cuenta o a donde prefieras
    redirect '/account'
  end

  post '/change_password' do
    new_password = params[:new_password]
    current_user = User.find(session[:user_id])
    if new_password != ' ' && new_password != '' && new_password != BCrypt::Password.new(current_user.password)
      # Actualiza el pasword del usuario actual
      new_password_digest = BCrypt::Password.create(new_password)
      current_user.update(password: new_password_digest)
      # Guarda los cambios en la base de datos
      current_user.save
      # Redirige a la página de cuenta o a donde prefieras
      redirect '/logout'
    else
      erb :'home/account', locals: { error: 'Contraseña no valida.' }
    end
  end
end
