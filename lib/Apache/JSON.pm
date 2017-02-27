package Apache::JSON;

## Import Perl 5.24 features ##
use v5.24;

## Import Moo object-system for Perl ##
use Moo;

## Import useful CPAN Modules ##
use Carp;
use Scalar::Util;
use Mojo::JSON qw(encode_json decode_json);

## Public Instance Methods ##
sub encode {
  my ($self, $ref) = @_;
  my $encoded = encode_json $ref;

  return $encoded;
}

sub decode {
  my ($self, $json) = @_;
  my $decoded = decode_json $json;

  return $decoded;
}

1;
