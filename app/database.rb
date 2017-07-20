# encoding: utf-8
# app/database.rb
require 'mongolitedb'

class Database
	def initialize
		file_name = 'db/sockets.mglite' 
		@connection = MongoLiteDB.new file_name
	end

	def connection
		@connection
	end
end