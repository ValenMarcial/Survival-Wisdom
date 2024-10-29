# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/activerecord'
require './models/user'
require './models/question'
require './models/option'
require './models/skill'
require './models/guide'
require './models/bar'
require './models/stat'

# para manejar la autenticación de usuario
module Authentication
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end

# module for all keep-it-alive methods
module GameMethods
  def init_questions
    session[:question] = @questions.shift
    session[:@questions] = @questions
    session[:days] = 0
    session[:coins] = @current_user.coins
  end

  def save_data
    stat = Stat.new
    stat.user_id = session[:user_id]
    stat.days = session[:days]
    current_user.coins = session[:coins]
    current_user.save
    stat.save
  end

  def random_improvement
    session[:coins] -= 10
    session[:health] += rand(0..3)
    session[:hunger] += rand(0..3)
    session[:water] += rand(0..3)
    session[:temperature] += rand(0..3)
  end

  def update_clicks
    opcionelegida = params[:valor].to_i
    question = Question.find(session[:question])
    if opcionelegida == 2
      question.rightclicks = question.rightclicks + 1
    else
      question.leftclicks = question.leftclicks + 1
    end
    question.save
  end

  def apply_effects(opcionelegida)
    effects = Question.find(session[:question]).options[opcionelegida - 1].effects
    bars = %i[health hunger water temperature]

    bars.each_with_index do |bar, index|
      session[bar] = [session[bar] + effects[index], 10].min
    end
  end
end

# para controlar la logica del juego keep-it-alive:
class GameController < Sinatra::Base
  include Authentication

  include GameMethods

  # Inicializa la partida
  get '/keep_it_alive/init' do
    # Recuperar todas las preguntas y opciones de la base de datos

    @questions = Question.all.order('RANDOM()').to_a.map(&:id)
    bars = Bar.all
    @current_user = current_user # Asegúrate de que current_user esté definido en algún lugar de tu código

    session[:xray] = 0
    bars.each do |bar|
      session[:health] = bar.value if bar.name_bar == 'health'
      session[:hunger] = bar.value if bar.name_bar == 'hunger'
      session[:water] = bar.value if bar.name_bar == 'water'
      session[:temperature] = bar.value if bar.name_bar == 'temperature'
    end


    # Si no hay preguntas en la base de datos, mostrar un mensaje
    return 'No hay preguntas disponibles.' if @questions.empty?

    init_questions
    erb :'home/game'
  end

  get '/keep_it_alive/playing' do
    if session[:@questions].nil? || session[:@questions].empty?
      # Si no quedan preguntas en la sesión, vuelve a asignar todas las preguntas de manera aleatoria
      @questions = Question.all.order('RANDOM()')
      session[:@questions] = @questions.map(&:id)
    else
      # Si quedan preguntas en la sesión, sigue utilizando esas preguntas
      @questions = Question.where(id: session[:@questions])
    end
    session[:xray] = 0
    session[:question] = session[:@questions].shift
    @current_user = current_user
    erb :'home/game'
  end


  # Es la partida a medida que va avanzando el usuario
  post '/keep_it_alive/playing' do
    update_clicks
    apply_effects(params[:valor].to_i)
    session[:xray] = 0

    if session[:health] <= 0 || session[:hunger] <= 0 || session[:water] <= 0 || session[:temperature] <= 0
      stat = Stat.new
      stat.user_id = session[:user_id] # Asigna el ID del usuario
      stat.days = session[:days]
      current_user.coins = session[:coins]
      current_user.save
      stat.save

      erb :'home/gameover'
    else
      session[:days] += 1
      session[:coins] += 1
      redirect '/keep_it_alive/playing'
    end
  end
  post '/keep_it_alive/comodin' do
    comodin_elegido = params[:comodin].to_i
    monedas = session[:coins]

    case comodin_elegido
    when 1
      if monedas >= 30
        # Comodin de Skip de carta
        session[:coins] -= 30

        if session[:@questions].nil? || session[:@questions].empty?
          # Si no quedan preguntas en la sesión, vuelve a asignar todas las preguntas de manera aleatoria
          @questions = Question.all.order('RANDOM()')
          session[:@questions] = @questions.map(&:id)
        else
          # Si quedan preguntas en la sesión, sigue utilizando esas preguntas
          @questions = Question.where(id: session[:@questions])
        end

        redirect '/keep_it_alive/playing'
      else
        # No hay suficientes monedas
        @error_message = 'No tienes suficientes monedas para usar este comodín.'
      end

    when 2
      # Comodin de Stat Boost
      if monedas >= 10
        random_improvement
      else
        # No hay suficientes monedas
        @error_message = 'No tienes suficientes monedas para usar este comodín.'
      end

    when 3
      # Comodin de Xray
      if monedas >= 15
        session[:coins] -= 15
        session[:xray] = 1
      else
        # No hay suficientes monedas
        @error_message = 'No tienes suficientes monedas para usar este comodín.'
      end
    end
    erb :'home/game'
  end

  # Fin de la partida con el back-button:
  post '/keep_it_alive/end' do
    save_data
    redirect '/home'
  end

  # Maneja la solicitud POST para jugar de nuevo
  post '/jugar-de-nuevo' do
    # Aquí puedes agregar la lógica para reiniciar el juego o redirigir a la página de inicio del juego
    # Por ejemplo, puedes reiniciar las variables de sesión y redirigir al usuario a la página de inicio
    session[:game_state] = nil # Reiniciar el estado del juego
    redirect to('/keep_it_alive/init') # Redirigir a la página de inicio del juego
  end

  # Maneja la solicitud GET para redirigir a /home cuando se hace clic en "Volver a Home"
  get '/back-to-home' do
    redirect '/home' # Redirige al usuario a la página de inicio
  end
end
