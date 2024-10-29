# frozen_string_literal: true

# Clase de Stats
class Stat < ActiveRecord::Base
  has_many :tests
  belongs_to :user
end
