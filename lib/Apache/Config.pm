package Apache::Config;

## Import Perl 5.24 features ##
use v5.24;

## Import Moo object-system for perl ##
use Moo;

## Import useful CPAN modules ##
use Carp;
use Scalar::Util;

## Instance Attributes ##
has 'config' => (
  is => 'ro',
  lazy => 1,
  isa => sub {
    croak "Invalid log file"
      unless defined $_[0] and ref $_[0] eq 'HASH',
  },
  default => sub { {} },
);

has 'logfile' => (
  is => 'ro',
  lazy => 1,
  default => sub {
    shift->config->{logfile}
  },
);

has 'reportfile' => (
  is => 'ro',
  lazy => 1,
  default => sub {
    shift->config->{reportfile}
  },
);

has 'api' => (
  is => 'ro',
  lazy => 1,
  default => sub {
    shift->config->{api}
  },
);

1;
