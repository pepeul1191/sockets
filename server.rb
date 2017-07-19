require	 'websocket-eventmachine-server'

EM.run do
  WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => 4000) do |ws|
    ws.onopen do |msg, type|
      	puts "Client connected"
        puts "1 +++++++++++++++++++++++"
       puts "2 +++++++++++++++++++++++"
       ws.send "hola mundo", :type => type
    end

    ws.onmessage do |msg, type|
      	puts "Received message: #{msg}"
      	ws.send msg, :type => type
    end

    ws.onclose do
      puts "Client disconnected"
    end
  end
end