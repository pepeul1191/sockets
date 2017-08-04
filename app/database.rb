# encoding: utf-8
# app/database.rb
require 'mongo'

class Database
	def initialize
		@connection = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'sockets')
	end

	def connection
		@connection
	end

	def find_to_json(docs)
		rpta = Array.new
		docs.each do |d|
		   rpta.push(d.to_json)
		end
		rpta
	end
end