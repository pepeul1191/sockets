# Run using your favourite server:
#
#     thin start -R examples/config.ru -p 7000
#     rainbows -c examples/rainbows.conf -E production examples/config.ru -p 7000

require 'rubygems'
require 'bundler/setup'
Dir.glob('./app/*.rb').each { |file| require file }

Faye::WebSocket.load_adapter('thin')
Faye::WebSocket.load_adapter('rainbows')

run App

#thin start -R config.ru -p 9292