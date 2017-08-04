# encoding: utf-8
# app/server.rb
require 'faye/websocket'
require 'querystring'
require 'mongolitedb'
require 'json'
require_relative 'database'

@clients = [] #[ws faye, id_usuario, id_sensor] ...
@i = 0

App = lambda do |env|
  if Faye::WebSocket.websocket?(env)
    ws = Faye::WebSocket.new(env)
    db = Database.new
    query_params = QueryString.parse(env['QUERY_STRING'])
    id_usuario = nil
    id_sensor = nil

    ws.on :open do |event|
        rs = Array.new
        docs_temp = db.connection()[:sockets].find({'id_sensor' => query_params['id_sensor'][0]})
        docs_temp.each { |doc| rs.push(doc)}

        if rs.length >= 1 # el sensor ya se encuentra registrado en la base de datos
            id_usuarios = rs[0]['id_usuario']
            if id_usuarios.include?(query_params['id_usuario'][0]) != true # actualizar hash que relaciona un sensor con uno o muchos usuarios
                id_usuarios.push(query_params['id_usuario'][0])
                doc = {'id_sensor' => query_params['id_sensor'][0], 'id_usuario' => id_usuarios}
                db.connection()[:sockets].update_one({'id_sensor' => query_params['id_sensor'][0]}, '$set' => doc)
            end 
            # si el usuario ya se encunetra al sensor, no hace ya ningua operacion contra la base de datos que asocia ambos datos
            id_usuario = query_params['id_usuario'][0]
            id_sensor = query_params['id_sensor'][0]
        else # dado que es un nuevo sensor, hay que inicializar un hash que relacione a este sensor con este primer usuario
            doc = {'id_sensor' => query_params['id_sensor'][0], 'id_usuario' => [query_params['id_usuario'][0]]}
            db.connection()[:sockets].insert_one doc
            id_usuario = query_params['id_usuario'][0]
            id_sensor = query_params['id_sensor'][0]
        end

        @clients.push([ws, id_usuario, id_sensor])#[ws faye, id_usuario, id_sensor] ...

        p [:open]
        ws.send('Hello, world!')
    end

    ws.on :message do |event|
        p [:on_message]
        db = Database.new
        rs = Array.new
        docs_temp = db.connection()[:sockets].find({'id_sensor' => query_params['id_sensor'][0]})
        docs_temp.each { |doc| rs.push(doc)} 
        id_usuarios = rs[0]['id_usuario'] # son los ids de usuarios suscritos al sensor a los que hay que enviar el mensaje

        @clients.each do |client| # todos los clientes ws registrados
            ws_faye = client[0]
            id_usuario = client[1]
            id_sensor = client[2]
            #puts "id_sensor_param - " +query_params['id_sensor'][0].to_s
            if id_usuarios.include?(id_usuario) == true && id_sensor == query_params['id_sensor'][0]
                data_hash = JSON.parse(event.data)
                ws_faye.send(data_hash['mensaje']) # sólo envía mensajes a las instacias de sockets que tienen asociado el usuario que se quiere conectar al sensor
            end
        end
    end

    ws.on :close do |event|
        p [:close, event.code, event.reason]
        db = Database.new
        if query_params['tipo'][0] == 'publicador'
            db.connection()[:sockets].delete_one({'id_sensor' => query_params['id_sensor'][0]})
        end

        if query_params['tipo'][0] == 'subscritor'
            id_usuarios = Array.new
            docs_temp = db.connection()[:sockets].find({'id_sensor' => query_params['id_sensor'][0]})

            docs_temp.each do |d|
                d[:id_usuario].each do|id_usuario|
                    if id_usuario != query_params['id_usuario'][0]
                        id_usuarios.push(id_usuario)
                    end
                end
            end

            doc = {'id_sensor' => query_params['id_sensor'][0], 'id_usuario' => id_usuarios}
            db.connection()[:sockets].update_one({'id_sensor' => query_params['id_sensor'][0]}, '$set' => doc)
        end

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
# http://zetcode.com/db/mongodbruby/