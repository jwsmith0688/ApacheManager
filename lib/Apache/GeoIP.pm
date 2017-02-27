package Apache::GeoIP;

## Import Perl 5.24 features ##
use v5.24;

## Import Moo object-system for Perl ##
use Moo;

## Import useful CPAN modules ##
use Carp;
use Scalar::Util 'blessed';
use Data::Dumper;
use Mojo::UserAgent;

## Instance Attributes ##
has 'config' => (
  is => 'ro',
  isa => sub {
    croak "Configuration parameter must be an 'Apache::Config' object."
      unless blessed $_[0] and $_[0]->isa('Apache::Config'),
  },
);

has 'json' => (
  is => 'ro',
  lazy => 1,
  isa => sub {
    croak "Invalid json object"
      unless blessed $_[0] and $_[0]->isa('Apache::JSON'),
  },
);

has 'api_url' => (
  is => 'ro',
  lazy => 1,
  default => sub {
    shift->config->api->{url}
  },
);

has 'data_format' => (
  is => 'ro',
  lazy => 1,
  default => sub {
    shift->config->api->{data_format}
  },
);


## Public Instance Methods ##
sub locate {
  my ($self, $hostname) = @_;
  my $url = $self->api_url;
  my $data_format = $self->data_format;

  ## Create a useragent object ##
  my $ua = Mojo::UserAgent->new->max_redirects(3);

  ##Fixme: Issues a blocking get request from API
  ## could, re-factor to do non-blocking requests to 
  ## increase speed and efficiency.
  my $query ="$url/$data_format/$hostname";
  my $tx = $ua->get($query);


  return $tx->res->json;
}

1;
