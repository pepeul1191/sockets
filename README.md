# SOCKETS

Arrancar el servidor de websockets:

	$ thin start -R config.ru -p 9292

Para visualizar el cliente web, basta con abrir el archivo index.html en un explorardor web como un archivo estático html.

Para arrancar el cliente ruby:

	$ ruby app/client.rb