# frozen_string_literal: true

Rspec.describe 'Game Logic' do

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

end
