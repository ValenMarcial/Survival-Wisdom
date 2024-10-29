# frozen_string_literal: true

# Atributos de la Clase User
class CreateUsersTable < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :username
      t.string :nickname
      t.string :password
      t.integer :coins
      t.integer :admin
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
