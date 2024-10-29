# frozen_string_literal: true

# Clase de Usuario
class User < ActiveRecord::Base
  # Otros métodos y definiciones de la clase...
  has_many :stats
  has_many :tests
  has_many :answers
  has_many :skills


  validates :username, presence: true, uniqueness: true
  validates :password, presence: true

  def self.authenticate(username, password)
    user = find_by(username: username)
    return nil unless user

    BCrypt::Password.new(user.password) == password ? user : nil
  end

  def name
    self[:username]
  end
end
