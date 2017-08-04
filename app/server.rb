# encoding: utf-8
# app/server.rb
require 'faye/websocket'
require 'querystring'
require 'mongolitedb'
require 'json'
require_relative 'database'

@clients = []
@i = 0

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    db = Database.new
    query_params = QueryString.parse(env['QUERY_STRING'])

    ws.on :open do |event|
        rs = db.connection().find({'id_sensor' => query_params['id_sensor'][0]})
        if rs.length >= 1
            id_usuarios = rs[0]['id_usuario']
            if id_usuarios.include?(query_params['id_usuario'][0]) != true 
                id_usuarios.push(query_params['id_usuario'][0])
                doc = {'id_sensor' => query_params['id_sensor'][0], 'id_usuario' => id_usuarios}
                db.connection().update({'id_sensor' => query_params['id_sensor'][0]}, doc)
            end
        else
            doc = {'id_sensor' => query_params['id_sensor'][0], 'id_usuario' => [query_params['id_usuario'][0]]}
            db.connection().insert(doc)
        end

        @clients.push(ws)

        p [:open]
        ws.send('Hello, world!')
    end

    ws.on :message do |event|
        p [:on_message]
        @clients.each do |client|
            data_hash = JSON.parse(event.data)
            client.send(data_hash['mensaje'])
        end
    end

    ws.on :close do |event|
        p [:close, event.code, event.reason]
        @clients.delete(ws)
        ws = nil
    end
    # Return async Rack response
    ws.rack_response
  else
    # Normal HTTP request
    [200, {'Content-Type' => 'text/plain'}, ['Hello']]
  end
end

# https://stackoverflow.com/questions/36544766/rails-faye-websocket-client-just-to-send-one-message
# https://github.com/faye/faye-websocket-ruby