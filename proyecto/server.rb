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

class App < Sinatra::Application
  def initialize(app = nil)
    super()
  end

  # Restringe el ingreso a ciertas rutas de la web sin estar logeado
  before do
    redirect '/login' unless ['/login', '/register','/'].include?(request.path_info) || current_user
  end

  get '/home' do
    erb :'home/home', locals: { user: current_user }
  end


  get '/login' do
    erb :'login/index', locals: { error: "" }
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
      erb :'login/index', locals: { error: "Credenciales inválidas. Por favor, inténtalo de nuevo." }
    end
  end

  # Para acceder al usuario guardado en la session
  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      nil
    end
  end




  get '/register' do
    erb :'login/register', locals: { error: " " }
  end

  # Registra un nuevo usuario en la web
  post '/register' do
    username = params[:first]
    password = params[:password]
    nickname = params[:nickname]
    # Verifica si ya existe un usuario con el mismo nombre de usuario en la base de datos
    existing_user = User.find_by(username: username)

    if existing_user
      # Si ya existe un usuario con el mismo nombre de usuario, puedes renderizar nuevamente el formulario de registro con un mensaje de error
      erb :'login/register', locals: { error: "El nombre de usuario ya está en uso. Por favor, elige otro nombre de usuario." }
    else
      # Si no existe un usuario con el mismo nombre de usuario, procede a crear uno nuevo y guardarlo en la base de datos
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
    if new_password != " " && new_password != "" && new_password != BCrypt::Password.new(current_user.password)
      # Actualiza el pasword del usuario actual
      new_password_digest = BCrypt::Password.create(new_password)
      current_user.update(password: new_password_digest)
      # Guarda los cambios en la base de datos
      current_user.save
      # Redirige a la página de cuenta o a donde prefieras
      redirect '/logout'
    else
      erb :'home/account', locals: { error: "Contraseña no valida." }
    end
  end

  get '/' do
    if current_user == nil
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
    send_file file_path, :type => :pdf

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

  # Inicializa la partida
  get '/keep_it_alive/init' do
    # Recuperar todas las preguntas y opciones de la base de datos

    @questions = Question.all.order("RANDOM()").to_a.map(&:id)
    bars = Bar.all
    @current_user = current_user # Asegúrate de que current_user esté definido en algún lugar de tu código

    session[:xray] = 0
    bars.each do |bar|
      if bar.name_bar == 'health'
      session[:health] = bar.value
      end
      if bar.name_bar == 'hunger'
        session[:hunger] = bar.value
      end
      if bar.name_bar == 'water'
        session[:water] = bar.value
      end
      if bar.name_bar == 'temperature'
        session[:temperature] = bar.value
      end
    end


    # Si no hay preguntas en la base de datos, mostrar un mensaje
    if @questions.empty?
      return "No hay preguntas disponibles."
    end
    session[:question] = @questions.shift
    session[:@questions]= @questions
    session[:days] = 0
    session[:coins] = @current_user.coins
    erb :'home/game'
  end

  get '/keep_it_alive/playing' do
    if session[:@questions].nil? || session[:@questions].empty?
      # Si no quedan preguntas en la sesión, vuelve a asignar todas las preguntas de manera aleatoria
      @questions = Question.all.order("RANDOM()")
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

    opcionelegida = params[:valor].to_i
    effects = Question.find(session[:question]).options[opcionelegida-1].effects
    question = Question.find(session[:question])
    if opcionelegida == 2 then
      question.rightclicks = question.rightclicks + 1
    else
      question.leftclicks = question.leftclicks + 1
    end
    question.save

     if session[:health] + effects[0] >= 10
      session[:health] = 10
     else
      session[:health] += effects[0]
     end
     if session[:hunger] + effects[1] >= 10
      session[:hunger] = 10
     else
      session[:hunger] += effects[1]
     end
     if session[:water] + effects[2] >= 10
      session[:water] = 10
     else
      session[:water] += effects[2]
     end
     if session[:temperature] + effects[3] >= 10
      session[:temperature] = 10
     else
      session[:temperature] += effects[3]
     end
     session[:xray] = 0

    if session[:health] <= 0 || session[:hunger] <= 0 || session[:water] <= 0 || session[:temperature] <= 0
      stat = Stat.new
      stat.user_id = session[:user_id] # Asigna el ID del usuario
      stat.days = session[:days]
      @current_user.coins = session[:coins]
      @current_user.save
      stat.save


      erb :'home/gameover'
    else
      session[:days] += 1
      session[:coins] += 1
      redirect '/keep_it_alive/playing'
    end
  end
end
post '/keep_it_alive/comodin' do
  comodinElegido = params[:comodin].to_i
  monedas = session[:coins]

  if comodinElegido == 1
    if monedas >= 30
      # Comodin de Skip de carta
      session[:coins] -= 30

      if session[:@questions].nil? || session[:@questions].empty?
        # Si no quedan preguntas en la sesión, vuelve a asignar todas las preguntas de manera aleatoria
        @questions = Question.all.order("RANDOM()")
        session[:@questions] = @questions.map(&:id)
      else
        # Si quedan preguntas en la sesión, sigue utilizando esas preguntas
        @questions = Question.where(id: session[:@questions])
      end

      redirect '/keep_it_alive/playing'
    else
      # No hay suficientes monedas
      @error_message = "No tienes suficientes monedas para usar este comodín."
    end

  elsif comodinElegido == 2
    # Comodin de Stat Boost
    if monedas >= 10
      session[:coins] -= 10
      session[:health] += rand(0..3)
      session[:hunger] += rand(0..3)
      session[:water] += rand(0..3)
      session[:temperature] += rand(0..3)
    else
      # No hay suficientes monedas
      @error_message = "No tienes suficientes monedas para usar este comodín."
    end

  elsif comodinElegido == 3
    # Comodin de Xray
    if monedas >= 15
      session[:coins] -= 15
      session[:xray] = 1
    else
      # No hay suficientes monedas
      @error_message = "No tienes suficientes monedas para usar este comodín."
    end
  end

  erb :'home/game'
end

#Fin de la partida con el back-button:
post '/keep_it_alive/end' do
  stat = Stat.new
  stat.user_id = session[:user_id]
  stat.days = session[:days]
  @current_user.coins = session[:coins]
  @current_user.save
  stat.save

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

# cierra la sesion
get '/logout' do
  session.clear
  redirect '/login'
end


get '/add_question' do
  erb :'home/add_question'
end

post '/add_question' do

  statement = params[:statement]
  difficulty = params[:difficulty]

  descriptionL = params[:descriptionL]
  effectsL =  params[:effectsL].split(',').map(&:strip).map(&:to_i)

  descriptionR = params[:descriptionR]
  effectsR =  params[:effectsR].split(',').map(&:strip).map(&:to_i)

  question = Question.new

  question.statement = statement
  question.typeCard = difficulty

  question.save

  question_id = question.id



  optionL = Option.new
  optionL.question_id = question_id
  optionL.description = descriptionL
  optionL.effects = effectsL


  optionR = Option.new
  optionR.question_id = question_id
  optionR.description = descriptionR
  optionR.effects = effectsR

  optionL.save
  optionR.save

  @success_message = "The question was successfully added!"

  erb :'home/add_question'
end

get '/card-stats' do
  erb :'home/card-stats'
end