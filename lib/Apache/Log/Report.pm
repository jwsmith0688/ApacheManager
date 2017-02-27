package Apache::Log::Report;

## Import Perl 5.24 features ##
use v5.24;

## Import Moo object-system for Perl ##
use Moo;

## Import useful CPAN modules ##
use Carp;
use Scalar::Util 'blessed';

## Instance Attributes ##
has 'config' => (
  is => 'ro',
  isa => sub {
    croak "Configuration attribute must be an 'Apache::Config' object",
      unless blessed $_[0] and $_[0]->isa('Apache::Config')
  },
);

## Public Instance Methods ##
sub write {
  my ($self, $data, $reportfile) = @_;

  croak "Unable to open reportfile for writing: $self->config->reportfile",
    unless open my $fh, ">>", $self->config->reportfile;

  say $fh $data;
  close($fh);
}
1;
