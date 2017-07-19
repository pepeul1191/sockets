use Mojolicious::Lite;

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

get '/' => sub {
	my $c = shift;
  	$c->render(text => 'Hello World!');
};

app->start;