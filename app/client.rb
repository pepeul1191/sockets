# encoding: utf-8
# app.rb
require 'rubygems'
require 'em-websocket-client'

EM.run do
  conn = EventMachine::WebSocketClient.connect("ws://127.0.0.1:9292/?id_sensor=1&id_usuario=1")

  EM.add_periodic_timer( 1 ) do
	puts "Executing timer event: " + Time.now.to_s
	  conn.callback do
		conn.send_msg '{"mensaje": "hola desde ruby client ' + Time.now.to_s + '"}'
	  end
  end

  conn.callback do
    conn.send_msg '{"mensaje": "hola desde ruby client"}'
  end

  conn.errback do |e|
    puts "Got error: #{e}"
  end

  conn.stream do |msg|
    puts "<#{msg}>"
    if msg.data == "done"
      conn.close_connection
    end
  end

  conn.disconnect do
    puts "gone"
    EM::stop_event_loop
  end
end