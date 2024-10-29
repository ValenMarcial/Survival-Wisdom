# frozen_string_literal: true

# Clase de Question
class Question < ActiveRecord::Base
  has_many :options
  has_many :answers
  belongs_to :test
end
