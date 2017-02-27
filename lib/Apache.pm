package Apache;

## Import Perl 5.24 features ##
use v5.24;

## Import Moo object-system for Perl ##
use Moo;

## Import useful CPAN modules ##
use Carp;
use Scalar::Util 'blessed';
use Data::Dumper;

## Import Model classes ##
use Apache::JSON;
use Apache::GeoIP;
use Apache::Log::Parse;
use Apache::Log::Report;

## Instance Attributes ##
has 'config' => (
  is => 'ro',
  isa => sub {
    croak "Configuration parameter must be an 'Apache::Config' object."
      unless blessed $_[0] and $_[0]->isa('Apache::Config'),
  },
);

has 'parser' => (
  is => 'lazy',
  init_arg => undef,
  clearer => 1,
);

has 'json' => (
  is => 'lazy',
  init_arg => undef,
  clearer => 1,
);

has 'geoip' => (
  is => 'lazy',
  init_arg => undef,
  clearer => 1,
);

has 'report' => (
  is => 'lazy',
  init_arg => undef,
  clearer => 1,
);

## Private class methods ##
sub _build_parser {
  my $self = shift;
  my $parser = Apache::Log::Parse->new(
    config => $self->config,
  );

  return $parser;
}

sub _build_json {
  my $self = shift;
  my $json = Apache::JSON->new;

  return $json;
}

sub _build_geoip {
  my $self = shift;
  my $geoip = Apache::GeoIP->new(
   config => $self->config,
  );

  return $geoip;
}

sub _build_report {
  my $self = shift;
  my $report = Apache::Log::Report->new(
    config => $self->config,
  );

  return $report;
}

## Public Instance Methods ##
sub gen_log_report {
  my $self = shift;
  my $parser = $self->parser;
  my @logs;

  say "Building Log Report from Apache log file: " . $self->config->logfile;

  for (1 .. $parser->linecount) {
    ## This is mad intensive. Maybe an XS module to parse the log file quicker
    my $ref = $parser->parseline($_);

    ## Also mad intensive.
    $ref->{geolocation} = $self->geoip->locate($ref->{client_ip});

    my $encoded =$self->json->encode($ref);
    say $encoded;
    $self->report->write($encoded, $self->config->reportfile);
  }
}

1;
