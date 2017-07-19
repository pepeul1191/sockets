use Mojolicious::Lite;
use Mojo::Transaction::WebSocket;

hook(before_dispatch => sub {
	my $self = shift;

	$self->res->headers->header('Access-Control-Allow-Origin'=> '*');
	$self->res->headers->header('Access-Control-Allow-Credentials' => 'true');
	$self->res->headers->header('Access-Control-Allow-Methods' => 'GET, OPTIONS, POST, DELETE, PUT');
	$self->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type, X-CSRF-Token');
	$self->res->headers->header('x-powered-by' => 'Mojolicious (Perl)');
	$self->res->headers->header('Access-Control-Max-Age' => '1728000');
	#$self->respond_to(any => { data => '', status => 200 });
});

get '/' => sub{
		my $self = shift;
		$self->render(text => ('I ♥ Mojolicious!'));
};

my $clients = {};

websocket '/echo' => sub {
	 my $self = shift;

	 app->log->debug(sprintf 'Client connected: %s', $self->tx);
	 my $id = sprintf "%s", $self->tx;
	 $clients->{$id} = $self->tx;

	 $self->on(message => sub {
		  my ($self, $msg) = @_;
		  my $dt   = DateTime->now( time_zone => 'Asia/Tokyo');
		  for (keys %$clients) {
		    $clients->{$_}->send({json => {
        hms  => $dt->hms,
        text => $msg,
		    }});
		  }
	 });

	 $self->on(finish => sub {
			 app->log->debug('Client disconnected');
			 delete $clients->{$id};
		});
};

app->start;

#fuente : https://github.com/kraih/mojo/wiki/Writing-websocket-chat-using-Mojolicious-Lite