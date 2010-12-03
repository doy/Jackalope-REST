#!/usr/bin/perl

use strict;
use warnings;
use FindBin;

use Test::More;
use Test::Fatal;
use Test::Jackalope;
use Test::Jackalope::Fixtures;

BEGIN {
    use_ok('Jackalope');
}

my $repo = Jackalope->new->resolve( type => 'Jackalope::Schema::Repository' );
isa_ok($repo, 'Jackalope::Schema::Repository');

my $fixtures = Test::Jackalope::Fixtures->new(
    fixture_dir => [ $FindBin::Bin, '..', '..', 'fixtures' ],
    repo        => $repo
);

foreach my $type ( qw[ ref hyperlink ] ) {
    validation_pass(
        $repo->validate(
            { '$ref' => 'schema/types/object' },
            $repo->compiled_schemas->{'schema/core/' . $type},
        ),
        '... validate the ' . $type . ' type with the schema type'
    );
    $fixtures->run_fixtures_for_type( $type );
}




done_testing;