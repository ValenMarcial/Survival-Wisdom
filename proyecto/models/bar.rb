# frozen_string_literal: true

# Clase de las Barras
class Bar < ActiveRecord::Base
  has_many :test
  has_many :option
end
