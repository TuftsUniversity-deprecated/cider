#!/usr/bin/perl

use warnings;
use strict;

use FindBin;
use lib (
    "$FindBin::Bin/../lib",
    "$FindBin::Bin/lib",
);

use CIDERTest;
my $schema = CIDERTest->init_schema;
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

use Test::More;
use DateTime;

my $item = $schema->resultset( 'Item' )->find( 4 );
my $do = ( $item->digital_objects )[ 0 ];

is ($item->locations, 1,
    'Before changing location, item reports being in one location' );

is ( $schema->resultset( 'ObjectLocation' )->search( { object => $item->id } )->count,
     1,
     'Only one link in the object_location table'
);

$do->location( 2 );
$do->update;

is ($item->locations, 1,
    'After changing location, item reports being in one location' );

my $count = $schema->resultset( 'ObjectLocation' )->search( { object => $item->id } )->count;
diag( $count );

is ( $schema->resultset( 'ObjectLocation' )->search( { object => $item->id } )->count,
     1,
     'Still only one link in the object_location table'
);


done_testing;
