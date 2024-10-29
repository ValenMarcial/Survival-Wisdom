# frozen_string_literal: true

# CLase de Opciones
class Option < ActiveRecord::Base
  has_many :bars
  has_one :answer
  belongs_to :question
end
