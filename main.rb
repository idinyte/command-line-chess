# frozen_string_literal: true

Dir.glob(File.join('./pieces', '*.rb'), &method(:require))

require_relative 'pieces'
require_relative 'board'
require_relative 'game'

Game.new
