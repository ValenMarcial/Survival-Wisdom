# frozen_string_literal: true

require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'

enable :sessions

set :database_file, './config/database.yml'
set :public_folder, 'assets'

require './models/user'
require './models/question'
require './models/option'
require './models/skill'
require './models/guide'
require './models/bar'
require './models/stat'
require './authentication_controller'
require './game_controller'

# para manejar la autenticación de usuario
module Authentication
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end

# Clase Principal
class App < Sinatra::Application
  include Authentication

  use AuthController # para manejar el login/register

  use GameController # para la lógica del juego

  def initialize(_app = nil)
    super()
  end

  get '/home' do
    erb :'home/home', locals: { user: current_user }
  end

  get '/' do
    if current_user.nil?
      redirect '/login'
    else
      redirect '/home'
    end
  end

  get '/skills' do
    erb :'home/skills', locals: { user: current_user }
  end

  # Muestra los pdf de las guias
  get '/skill/:guide.pdf' do
    file_path = "views\\skill\\#{params[:guide].capitalize}.pdf"
    send_file file_path, type: :pdf
  end

  # Ingresa a la guia que el usuario desee
  get '/skill/:id' do
    erb :"skill/#{params[:id]}"
  end


  get '/keep_it_alive' do
    erb :'home/keep_it_alive', locals: { user: current_user }
  end

  get '/about' do
    erb :'home/about', locals: { user: current_user }
  end

  get '/account' do
    erb :'home/account', locals: { user: current_user }
  end

  get '/leaderboard' do
    erb :'home/leaderboard', locals: { user: current_user }
  end

  get '/add_question' do
    erb :'home/add_question', { user: current_user }
  end

  post '/add_question' do
    statement = params[:statement]
    difficulty = params[:difficulty]

    description_l = params[:descriptionL]
    effects_l = params[:effectsL].split(',').map(&:strip).map(&:to_i)

    description_r = params[:descriptionR]
    effects_r = params[:effectsR].split(',').map(&:strip).map(&:to_i)

    question = Question.new

    question.statement = statement
    question.typeCard = difficulty

    question.save

    question_id = question.id



    option_l = Option.new
    option_l.question_id = question_id
    option_l.description = description_l
    option_l.effects = effects_l


    option_r = Option.new
    option_r.question_id = question_id
    option_r.description = description_r
    option_r.effects = effects_r

    option_l.save
    option_r.save

    @success_message = 'The question was successfully added!'

    erb :'home/add_question', { user: current_user }
  end

  get '/card-stats' do
    erb :'home/card-stats', { user: current_user }
  end
end
