# frozen_string_literal: true

require 'rspec'
require 'rack/test'
require 'spec_helper'
require_relative '../server'
RSpec.describe 'Admin Features' do
  describe 'Admin features' do
    it 'Question Successfully Added' do
      post '/login', first: 'ADMIN', password: 'ADMIN'
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
      post '/login', first: 'ADMIN', password: 'ADMIN'
      get '/add_question'
      expect(last_request.path).to eq('/add_question')
    end
    it 'card-stats Endpoint' do
      post '/login', first: 'ADMIN', password: 'ADMIN'
      get '/card-stats'
      expect(last_request.path).to eq('/card-stats')
    end
  end
end
