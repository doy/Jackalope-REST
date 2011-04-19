#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use JSON ();

use Jackalope::REST::Util::HashExpander 'expand_hash';

# perl's escaping rules make this basically illegible, oh well
my @tests = (
    [ { foo => 'bar'   }
       => { foo => 'bar' } ],
    [ { foo => '$true' }
       => { foo => JSON::true } ],
    [ { foo => '$false' }
       => { foo => JSON::false } ],
    [ { foo => '\\$true' }
       => { foo => '$true' } ],
    [ { foo => '\\\\$true' }
       => { foo => '\$true' } ],
    [ { foo => '\\\\\\$true' }
       => { foo => '\\\$true' } ],
    [ { foo => '\\\\\\$true\\\\\\$' }
       => { foo => '\\\$true\\\$' } ],
    [ { foo => ['bar', '$true', '$false', '\\$true'] }
       => { foo => ['bar', JSON::true, JSON::false, '$true'] } ],
    [ { 'foo:bar' => ['baz', '$true', 'foo\\\\$bar'], 'foo:quux' => '$false', 'baz:baaz:baaaz' => 'abcd\$' }
       => { foo => { bar => ['baz', JSON::true, 'foo\$bar'], quux => JSON::false }, baz => { baaz => { baaaz => 'abcd$' } } } ],
);

is_deeply(expand_hash($_->[0]), $_->[1]) for @tests;

done_testing;
