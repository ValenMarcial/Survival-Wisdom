# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../server'
require 'rspec'
require 'rack/test'
require 'spec_helper'

RSpec.describe 'The Server' do
  include Rack::Test::Methods

  def app
    # Sinatra::Appplication
    App
  end

  # Checkea si el usuario se loguea correctamente
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


    it 'shows an error when the new password is invalid' do
      # Inicia sesión con un usuario de prueba
      post '/login', { first: 'testuser1', password: 'password' }, 'rack.session' => { user_id: 1 }

      # Intenta cambiar la contraseña a una vacía
      post '/change_password', { new_password: '' }, 'rack.session' => { user_id: 1 }

      # Verifica que la respuesta contiene el mensaje de error
      expect(last_response.body).to include('Contraseña no valida.')

      # Verifica que la respuesta es correcta (status 200 OK)
      expect(last_response).to be_ok
    end
  end


  # Checkea si se registra bien el usuario
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

  # Checkea que no se pueda acceder a ciertas direcciones de la web sin haber iniciado sesion
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

  describe 'GET /register' do
    it 'redirects normaly' do
      get '/register'
      expect(last_request.path).to eq('/register')
    end
  end

  describe 'GET /skills' do
    it 'redirects normaly' do
      post '/login', first: 'testuser1', password: 'password'
      get '/skills'
      expect(last_request.path).to eq('/skills')
    end
  end

  describe 'GET /keep_it_alive' do
    it 'redirects normaly' do
      post '/login', first: 'testuser1', password: 'password'
      get '/keep_it_alive'
      expect(last_request.path).to eq('/keep_it_alive')
    end
  end

  describe 'GET /about' do
    it 'redirects normaly' do
      post '/login', first: 'testuser1', password: 'password'
      get '/about'
      expect(last_request.path).to eq('/about')
    end
  end

  describe 'GET /account' do
    it 'redirects normaly' do
      post '/login', first: 'testuser1', password: 'password'
      get '/account'
      expect(last_request.path).to eq('/account')
    end
  end

  describe 'GET /account' do
    it 'redirects normaly' do
      post '/login', first: 'testuser1', password: 'password'
      get '/leaderboard'
      expect(last_request.path).to eq('/leaderboard')
    end
  end

  describe 'GET /' do
    it 'redirects unlogged' do
      get '/'
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_request.path).to eq('/login')
    end

    it 'redirects logged' do
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
  # Checkea que la partida se inicialice correctamente
  describe 'GET /keep_it_alive/init' do
    it 'initializes the game session' do
      post '/login', first: 'testuser1', password: 'password'

      env 'rack.session', {
        health: 5,
        hunger: 5,
        water: 5,
        temperature: 5,
        days: 0,
        question: nil,
        questions: nil
      }

      def session
        last_request.env['rack.session']
      end

      get '/keep_it_alive/init'

      expect(last_response).to be_ok
      expect(session[:health]).to eq(10)
      expect(session[:hunger]).to eq(10)
      expect(session[:water]).to eq(10)
      expect(session[:temperature]).to eq(10)
      expect(session[:days]).to eq(0)
      expect(session[:question]).to be_present
    end
  end


  describe 'POST /keep_it_alive/playing' do
    before do
      post '/login', first: 'testuser1', password: 'password'

      # Set up the session
      env 'rack.session', {
        question: 1,
        health: 5,
        hunger: 5,
        water: 5,
        temperature: 5,
        days: 1,
        user_id: 1,
        coins: 0
      }
    end
    let(:effects) { [1, -1, 2, -2] } # Simula los efectos de la opción elegida

    def session
      last_request.env['rack.session']
    end


    before do
      option_mock = double('Option', effects: effects)

      # Mock para la pregunta, asegurando que devuelva la lista de opciones
      @question_mock = double('Question', options: [option_mock, option_mock])

      # Inicializamos los contadores de clics
      @rightclicks = 0
      @leftclicks = 0

      # Simulamos la lectura de rightclicks y leftclicks
      allow(@question_mock).to receive(:rightclicks).and_return(@rightclicks)
      allow(@question_mock).to receive(:leftclicks).and_return(@leftclicks)

      # Simulamos la escritura de rightclicks y leftclicks
      allow(@question_mock).to receive(:rightclicks=) { |value| @rightclicks = value }
      allow(@question_mock).to receive(:leftclicks=) { |value| @leftclicks = value }

      # Simulamos el metodo save
      allow(@question_mock).to receive(:save)
      # Simulamos la llamada a `Question.find`
      allow(Question).to receive(:find).and_return(@question_mock)
    end

    it 'cuando se elige la opción derecha, incrementa el contador de rightclicks' do
      # Simula un clic en la opción correcta (opción 2)
      post '/keep_it_alive/playing', valor: 2

      # Verifica que el contador de rightclicks se haya incrementado
      expect(@rightclicks).to eq(1)
    end

    it 'cuando se elige la opción izquierda, incrementa el contador de leftclicks' do
      # Simula un clic en la opción incorrecta (opción 1)
      post '/keep_it_alive/playing', valor: 1

      # Verifica que el contador de leftclicks se haya incrementado
      expect(@leftclicks).to eq(1)
    end

    it 'updates session correctly when effects are positive and negative' do
      post '/keep_it_alive/playing', params: { valor: 1 }
      expect(session[:health]).to eq(6)
      expect(session[:hunger]).to eq(4)
      expect(session[:water]).to eq(7)
      expect(session[:temperature]).to eq(3)
    end

    it 'caps session values at 10' do
      allow(Question).to receive_message_chain(:find, :options).and_return([double(effects: [10, 10, 10, 10])])
      post '/keep_it_alive/playing', params: { valor: 1 }
      expect(session[:health]).to eq(10)
      expect(session[:hunger]).to eq(10)
      expect(session[:water]).to eq(10)
      expect(session[:temperature]).to eq(10)
    end

    it 'renders gameover when any session value is 0 or below' do
      allow(Question).to receive_message_chain(:find, :options).and_return([double(effects: [-10, -10, -10, -10])])
      post '/keep_it_alive/playing', params: { valor: 1 }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('GAME OVER')
    end
  end

  describe 'POST /keep_it_alive/comodin' do
    let(:question) { double('Question', id: 1) }
    let(:questions) { [question] }
    let(:question_class) { class_double('Question').as_stubbed_const }

    before do
      post '/login', first: 'testuser1', password: 'password'
      get '/keep_it_alive/init'
    end

    context 'when using comodin 1 (Skip de carta)' do
      it 'deducts 30 coins ' do
        post '/keep_it_alive/comodin', { comodin: 1 }, 'rack.session' => { coins: 50 }
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.path).to eq('/keep_it_alive/playing')
        expect(last_request.session[:coins]).to eq(20)
      end

      it 'does not deduct coins if there are not enough' do
        initial_coins = 10
        post '/keep_it_alive/comodin', { comodin: 1 }, 'rack.session' => { coins: initial_coins }

        # Comprobar que las monedas no cambian
        expect(last_request.session[:coins]).to eq(initial_coins)
        # Verificar que no se redirige a la ruta de playing
        expect(last_response).to be_ok
        expect(last_request.path).not_to eq('/keep_it_alive/playing')
      end

      it 'deducts 30 and refill cards' do
        # Simula que no hay preguntas en la sesión
        # Realiza la solicitud para usar el comodín
        post '/keep_it_alive/comodin', { comodin: 1 }, 'rack.session' => { coins: 50, '@questions' => [] }

        # Verifica que se dedujeron las monedas
        expect(last_request.session[:coins]).to eq(20)

        # Verifica que las preguntas se rellenaron correctamente
        expect(last_request.session[:@questions]).not_to eq([])
        # Asegúrate de que el ID de la pregunta coincida con el que has configurado
      end
    end

    context 'when using comodin 2 (Stat Boost)' do
      it 'deducts 10 coins and boosts stats' do
        post '/keep_it_alive/comodin', { comodin: 2 },
             'rack.session' => { coins: 20, health: 5, hunger: 5, water: 5, temperature: 5 }
        expect(last_response).to be_ok
        expect(last_request.session[:coins]).to eq(10)
        expect(last_request.session[:health]).to be_between(5, 8).inclusive
        expect(last_request.session[:hunger]).to be_between(5, 8).inclusive
        expect(last_request.session[:water]).to be_between(5, 8).inclusive
        expect(last_request.session[:temperature]).to be_between(5, 8).inclusive
      end

      it 'does not boost stats if there are not enough coins' do
        initial_stats = { health: 5, hunger: 5, water: 5, temperature: 5 }
        initial_coins = 5
        post '/keep_it_alive/comodin', { comodin: 2 }, 'rack.session' => { coins: initial_coins }.merge(initial_stats)

        # Verificar que las monedas no cambian
        expect(last_request.session[:coins]).to eq(initial_coins)
        # Verificar que las estadísticas no cambian
        expect(last_request.session[:health]).to eq(initial_stats[:health])
        expect(last_request.session[:hunger]).to eq(initial_stats[:hunger])
        expect(last_request.session[:water]).to eq(initial_stats[:water])
        expect(last_request.session[:temperature]).to eq(initial_stats[:temperature])
      end
    end

    context 'when using comodin 3 (Xray)' do
      it 'deducts 15 coins and activates Xray' do
        post '/keep_it_alive/comodin', { comodin: 3 }, 'rack.session' => { coins: 20 }
        expect(last_response).to be_ok
        expect(last_request.session[:coins]).to eq(5)
        expect(last_request.session[:xray]).to eq(1)
      end

      it 'does not activate Xray if there are not enough coins' do
        initial_coins = 10
        post '/keep_it_alive/comodin', { comodin: 3 }, 'rack.session' => { coins: initial_coins }

        # Verificar que las monedas no cambian
        expect(last_request.session[:coins]).to eq(initial_coins)
        # Verificar que el modo Xray no se activa
        expect(last_request.session[:xray]).to eq(0)
      end
    end
  end
  describe 'POST /keep_it_alive/end' do
    before do
      post '/login', first: 'testuser1', password: 'password'

      # Set up the session
      env 'rack.session', {
        question: 1,
        health: 5,
        hunger: 5,
        water: 5,
        temperature: 0,
        days: 5,
        user_id: 1,
        coins: 15
      }
    end

    it 'Ends a game and saves the files' do
      stat_count_before = Stat.count
      post '/keep_it_alive/end'
      stat_count_after = Stat.count

      expect(stat_count_after).to eq(stat_count_before + 1)
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_request.path).to eq('/home')
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

  # Verifica que la ruta raíz redirige correctamente
  describe 'GET /' do
    it 'redirects to /login' do
      get '/'
      expect(last_response.status).to eq(302)
      expect(last_response.headers['Location']).to include('/login')
    end
  end


  describe 'Game Restart' do
    it 'resets the game state and redirects to the game init page' do
      # logeo el usuario:
      post '/login', first: 'testuser1', password: 'password'
      # Realiza la solicitud POST para reiniciar el juego
      post '/jugar-de-nuevo'

      # Verifica la redirección
      expect(last_response).to be_redirect
      follow_redirect!

      # Verifica que la redirección lleve a la página de inicio del juego
      expect(last_request.path).to eq('/keep_it_alive/init')
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

  describe 'GET /keep_it_alive/init' do
    context 'cuando no hay preguntas disponibles' do
      before do
        # logeo el usuario:
        post '/login', first: 'testuser1', password: 'password'
        allow(Question).to receive(:all).and_return(double(order: [])) # Simula que no hay preguntas
        allow(Bar).to receive(:all).and_return([]) # Opcional: si también necesitas simular los bares
        get '/keep_it_alive/init'
      end

      it 'debe devolver un mensaje indicando que no hay preguntas disponibles' do
        expect(last_response.body.force_encoding('UTF-8')).to eq('No hay preguntas disponibles.')
      end
    end
  end


  describe 'GET /keep_it_alive/playing' do
    before do
      post '/login', first: 'testuser1', password: 'password'
    end

    it 'empty questions' do
      post '/login', first: 'testuser1', password: 'password'

      env 'rack.session', {
        health: 5,
        hunger: 5,
        water: 5,
        temperature: 5,
        days: 0,
        question: nil,
        questions: []
      }

      get '/keep_it_alive/playing'
      expect(last_request.session[:questions]).to_not eq(nil)
    end



    it 'asigna correctamente @questions con las preguntas de la sesión' do
      @questions = Question.all.order('RANDOM()').to_a.map(&:id)
      question1 = @questions.shift
      question2 = @questions.shift

      # Simular que las preguntas estan en la sesión
      get '/keep_it_alive/playing', {}, { 'rack.session' => { '@questions' => [question1, question2, question1] } }
      # Verificar que la sesión contiene las preguntas correctas
      expect(last_request.env['rack.session']['@questions']).to contain_exactly(question1, question2)
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

  describe 'Admin features' do
    it 'Question Successfully Added' do
      post '/login', first: 'testuser1', password: 'password'
      post '/add_question', statement: 'ABC', difficulty: 'Easy', descriptionL: 'Left',
                            descriptionR: 'Rigth', effectsL: '1,1,1,1', effectsR: '2,2,2,2'

      question = Question.last
      expect(question).not_to be_nil
      expect(question.statement).to eq('ABC')
      expect(question.typeCard).to eq('Easy')
      expect(question.options[0].description).to eq('Left')
      expect(question.options[1].description).to eq('Rigth')
      expect(question.options[0].effects).to eq([1, 1, 1, 1])
      expect(question.options[1].effects).to eq([2, 2, 2, 2])
    end
    it 'Add_question Endpoint' do
      post '/login', first: 'testuser1', password: 'password'
      get '/add_question'
      expect(last_request.path).to eq('/add_question')
    end
    it 'card-stats Endpoint' do
      post '/login', first: 'testuser1', password: 'password'
      get '/card-stats'
      expect(last_request.path).to eq('/card-stats')
    end
  end
end
