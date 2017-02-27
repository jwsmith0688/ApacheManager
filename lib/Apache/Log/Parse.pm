package Apache::Log::Parse;

## Import Perl 5.24 features ##
use v5.24;

## Import Moo object-sytem for Perl ##
use Moo;

## Import useful CPAN modules ##
use Carp;
use Scalar::Util 'blessed';

## Instance Attributes ##
has 'config' => (
  is => 'ro',
  isa => sub {
    croak "Configuration attribute must be an 'Apache::Config' object."
      unless blessed $_[0] and $_[0]->isa('Apache::Config')
  },
);

## Public instance methods ##
sub linecount {
  my $self = shift;
  my $lines;

  ## Open filehandle ##
  croak "Unable to open logfile for reading: $self->config->logfile",
    unless open my $fh, "<", $self->config->logfile;

  ## Count lines in file ##
  $lines++ while (<$fh>);

  close($fh);
  return $lines;
}

sub getline {
  my ($self, $line) = @_;

  ## Open filehandle ##
  croak "Unable to open logfile for reading: $self->config->logfile",
    unless open my $fh, "<", $self->config->logfile;

  ## Make array of lines in file ##
  my @lines = <$fh>;

  close($fh);
  return $lines[$line];
}

sub parseline {
  my ($self, $line) = @_;
  my %parsed;

  my $log_pattern = qr {
    ^ ## Start at the beginning of the line
    (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) ## match the IP Address
    \s-\s-\s\[  ## ignore this stuff
    (.+?)       ## match the timestamp
    \]\s"       ## ignore this stuff
    (.+?)       ## match the request
    "\s         ## ignore this stuff
    (.+?)       ## match HTTP Response code
    \s          ## ignore
    (.+?)       ## match response returned in bytes
    \s"-"\s"    ## ignore
    (.+?)"      ## User-Agent string

  }x;

  ## This is ugly as hell -- don't do this -- use Apache::ParseLog
  if ($self->getline($line) =~ /$log_pattern/) {
    $parsed{client_ip} = $1;
    $parsed{timestamp} = $2;
    $parsed{request} = $3;
    $parsed{response} = $4;
    $parsed{reponse_bytes} = $5;
    $parsed{useragent} = $6;
  }

  return \%parsed;
}

1;
