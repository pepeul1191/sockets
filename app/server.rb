# encoding: utf-8
require 'faye/websocket'
require 'querystring'
require 'mongolitedb'
require_relative 'database'

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    
    query_params = QueryString.parse(env['QUERY_STRING'])
    db = Database.new
    puts "1 +++++++++++++++++++++++++++++++++++++++++++"
    rs = db.connection().find({'id_sensor' => query_params['id_sensor'][0]})
    if rs.length >= 1
      puts " IF"
        temp = Array.new
        id_usuarios = rs[0]['id_usuario']
        puts id_usuarios.inspect
        puts id_usuarios.include?(query_params['id_usuario'][0])
        if id_usuarios.include?(query_params['id_usuario'][0]) != true 
            puts "no incluye"
            temp.push(id_usuarios, query_params['id_usuario'][0])
            puts temp
            doc = {'id_sensor' => query_params['id_sensor'][0], 'id_usuario' => temp}
            db.connection().update({'id_sensor' => query_params['id_sensor'][0]}, doc)
        else
            puts "incluye"
        end
    else
        puts " ELSE"
        doc = {'id_sensor' => query_params['id_sensor'][0], 'id_usuario' => [query_params['id_usuario'][0]]}
        db.connection().insert(doc)
    end
    puts "2 +++++++++++++++++++++++++++++++++++++++++++"
    ws.on :open do |event|
      p [:open]
      ws.send('Hello, world!')
    end

    ws.on :message do |event|
      ws.send(event.data)
    end

    ws.on :close do |event|
      p [:close, event.code, event.reason]
      ws = nil
    end

    # Return async Rack response
    ws.rack_response

  else
    # Normal HTTP request
    [200, {'Content-Type' => 'text/plain'}, ['Hello']]
  end
end