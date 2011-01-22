#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::Moose;
use Test::Jackalope::REST::ResourceRepositoryTestSuite;

BEGIN {
    use_ok('Jackalope');
}

{
    package Simple::DataRepo;
    use Moose;

    with 'Jackalope::REST::Resource::Repository';

    my $ID_COUNTER = 0;

    has 'db' => (
        is      => 'ro',
        isa     => 'HashRef',
        default => sub { +{} },
    );

    sub list {
        my $self = shift;
        return [ map { [ $_, $self->db->{ $_ } ] } sort keys %{ $self->db } ]
    }

    sub create {
        my ($self, $data) = @_;
        my $id = ++$ID_COUNTER;
        $self->db->{ $id } = $data;
        return ( $id, $data );
    }

    sub get {
        my ($self, $id) = @_;
        return $self->db->{ $id };
    }

    sub update {
        my ($self, $id, $updated_data) = @_;
        $self->db->{ $id } = $updated_data;
    }

    sub delete {
        my ($self, $id) = @_;
        delete $self->db->{ $id };
    }
}

my $repo = Simple::DataRepo->new;
Test::Jackalope::REST::ResourceRepositoryTestSuite->new(
    fixtures => [
        { id => 1, body => { foo => 'bar'   } },
        { id => 2, body => { bar => 'baz'   } },
        { id => 3, body => { baz => 'gorch' } },
        { id => 4, body => { gorch => 'foo' } },
    ]
)->run_all_tests( $repo );

done_testing;




