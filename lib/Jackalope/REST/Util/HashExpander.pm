package Jackalope::REST::Util::HashExpander;
use Moose;
use MooseX::NonMoose;

use JSON ();

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

extends 'CGI::Expand';

sub separator { ':' }

# XXX ugh ugh ugh this is so gross, but it seems to work, so...
around expand_hash => sub {
    my $orig = shift;
    my $self = shift;
    my ($flat) = @_;

    # superclass version only messes with escaping stuff on keys, and we only
    # care about escaping things on values, so we don't really need to handle
    # anything special
    my $hash = $self->$orig($flat);

    $hash = Jackalope::REST::Util::HashExpander::Visitor->new(
        cb => sub {
            my ($v, $data) = @_;
            if ($data eq '$true') {
                return JSON::true;
            }
            elsif ($data eq '$false') {
                return JSON::false;
            }
            else {
                $data =~ s/\\\$/\$/g;
                return $data;
            }
        },
    )->visit($hash);

    return $hash;
};

__PACKAGE__->meta->make_immutable;

no Moose; 1;

# need to only visit hash values, which D::V::Callback doesn't seem to support
package
    Jackalope::REST::Util::HashExpander::Visitor;
use Moose;

extends 'Data::Visitor';

has cb => (
    traits    => ['Code'],
    isa       => 'CodeRef',
    required  => 1,
    handles   => {
        cb => 'execute_method',
    },
);

around visit_array_entry => sub {
    my $orig = shift;
    my $self = shift;
    my ($value) = @_;
    return $self->$orig($value) if ref($value);
    return $self->$orig($self->cb($value));
};

around visit_hash_value => sub {
    my $orig = shift;
    my $self = shift;
    my ($value) = @_;
    return $self->$orig($value) if ref($value);
    return $self->$orig($self->cb($value));
};

no Moose; 1;

__END__

=pod

=head1 NAME

Jackalope::REST::Util::HashExpander - A Moosey solution to this problem

=head1 SYNOPSIS

  use Jackalope::REST::Util::HashExpander;

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2011 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
