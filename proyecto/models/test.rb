# frozen_string_literal: true

# Clase de Test
class Test < ActiveRecord::Base
  belongs_to :user
  has_many :bars
  has_one :stat
  has_many :questions
end
