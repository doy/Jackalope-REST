package Jackalope::REST::Error;
use Moose::Role;

use Plack::Util;

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

sub body_headers { [] }
sub as_string    { (shift)->status_line }
sub body         { (shift)->pack }

sub pack {
    my $self = shift;
    {
        status_code => $self->status_code,
        reason      => $self->reason,
        message     => $self->message,
    }
}

around 'as_psgi' => sub {
    my $next = shift;
    my $self = shift;
    my $psgi = $self->$next();

    my $serializer = shift;
    my $body       = $serializer->serialize( $self->pack );

    Plack::Util::header_set( $psgi->[1], 'Content-Type'   => $serializer->content_type );
    Plack::Util::header_set( $psgi->[1], 'Content-Length' => length $body );

    $psgi->[2] = [ $body ];

    $psgi;
};

no Moose::Role; 1;

__END__

=pod

=head1 NAME

Jackalope::REST::Error - A Moosey solution to this problem

=head1 SYNOPSIS

  use Jackalope::REST::Error;

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

Copyright 2010 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
