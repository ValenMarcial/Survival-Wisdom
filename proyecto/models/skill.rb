# frozen_string_literal: true

# Clase Skill
class Skill < ActiveRecord::Base
  belongs_to :user
  has_many :guides
end
