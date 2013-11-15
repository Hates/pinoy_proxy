ENV["GEM_HOME"]=%x{"rvm --create use 1.9.3@pinoy-proxy ; rvm gemdir"}.strip

require 'rubygems'
require 'sinatra'

require './pinoy'
run Sinatra::Application
