# frozen_string_literal: true

ENV['APP_ENV'] = 'test'

require_relative '../server'
require_relative 'game_spec'
require_relative 'auth_spec'
require_relative 'admin_spec'
require_relative 'account_spec'
require_relative 'endpoints_spec'
require 'rspec'
require 'rack/test'
require 'spec_helper'
