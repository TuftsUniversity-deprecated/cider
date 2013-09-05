#!/usr/bin/perl

# Tests of basic CIDER objects.

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
use Test::Exception;
use DateTime;

my @collections = $schema->resultset('Object')->root_objects;

is (scalar @collections, 2, 'There are two collections.');

my $collection_1 = $collections[0];
is ($collection_1->title, 'Test Collection with kids',
    'Collection\'s name is correct.'
);
isa_ok ($collection_1, 'CIDER::Schema::Result::Collection',
     'Collection'
 );
is( $collection_1->type, 'collection', 'type is collection.' );


my @series = $collection_1->children;
is (scalar @series, 1, 'There is one child series.');

my $series_1 = $series[0];
is ( $series_1->title, 'Test Series 1',
     "The series' name is correct."
 );
isa_ok ($series_1, 'CIDER::Schema::Result::Series',
     'Series'
 );
is( $series_1->type, 'series', 'type is series.' );

my @items = $series_1->children;
is (scalar @items, 2, 'There are two child item.');

my ( $item_1, $item_2 ) = @items;

is ( $item_1->title, 'Test Item 1',
     "The item's name is correct."
 );
isa_ok ($item_1, 'CIDER::Schema::Result::Item',
     'Item'
 );
is( $item_1->type, 'item', 'type is item.' );

is( $item_1->parent->id, $series_1->id,
    "The series is the parent of the item."
);

# TO DO: re-implement date ranges on collections and series.

# is( $collection_1->date_from, $item_1->date_from,
#     "The collection's date_from is the earliest date_from of its subitems.");

# is( $collection_1->date_to, $item_2->date_to,
#     "The collection's date_to is the latest date_to of its subitems.");

my $collection_2 = $collections[1];

is( $series_1->has_ancestor( $collection_2 ), 0,
    'Before moving, the series does not see the collection as ancestor.' );
is( $series_1->audit_trail->modification_logs, 0,
    'Before moving, the series has no update logs.' );

$series_1->parent( $collection_2 );
$series_1->update;

is( $collection_2->children, 1,
    'After moving, there is one child series in the second collection.');
is( $collection_1->children, 0,
    'After moving, there are no child series in the first collection.');
is( $series_1->has_ancestor( $collection_2 ), 1,
    'After moving, the series claims the collection as ancestor.' );
is( $series_1->audit_trail->modification_logs, 1,
    'After moving, the series has one update log.' );

throws_ok { $collection_2->parent( $series_1 ) } qr/ancestor/,
    "The series refuses to become its ancestor's parent.";

throws_ok { $collection_2->parent( $collection_2 ) } qr/its own/,
    "The series refuses to become its own parent.";

my $elt = elt <<END
<foo>
  <bar>Blah</bar>
  <!-- Comment is ignored. -->
  <baz>
    <garply />
  </baz>
</foo>
END
;
is_deeply( DBIx::Class::UpdateFromXML->xml_to_hashref( $elt ), {
    bar => 'Blah',
    baz => [ $elt->getElementsByTagName( 'garply' ) ],
}, 'xml_to_hashref works' );

my $rs = $schema->resultset( 'Series' );

my $series_2 = $rs->create_from_xml( elt <<END
<series number='s2' parent='n3'>
  <title>New sub-series</title>
</series>
END
);

isa_ok( $series_2, 'CIDER::Schema::Result::Series',
        'Imported series' );

is( $series_1->number_of_children, 3,
    'After import create, ' . $series_1->title . ' has 3 children.' );

my $trail = $series_2->audit_trail;
is( $trail->created_by->user->id, 1,
    'Created by user 1.' );

$series_2->update_from_xml( elt <<END
<series parent="n1">
  <title>Updated sub-series</title>
</series>
END
);

is( $collection_1->number_of_children, 1,
    'After import update, ' . $collection_1->title . ' has 1 child.' );
is( $series_2->title, 'Updated sub-series',
    'Import update changed the title.' );

$series_2->update_from_xml( elt '<series parent="" />' );

is( scalar $schema->resultset( 'Object' )->root_objects, 3,
    'After import update, there are 3 root objects.' );

throws_ok {
    $series_2->update_from_xml( elt '<series parent="foo" />' );
} qr/does not exist/,
    'Import updating parent to nonexistent parent is an error.';


$series_2->export;
is( $trail->date_available, DateTime->today,
    'Date available is today.' );

$series_2->delete;
is( $schema->resultset( 'AuditTrail' )->find( $trail->id ), undef,
    'Audit trail was deleted.' );

##################
# Testing derived-field updates
##################

# Reset the database.
$schema = CIDERTest->init_schema;
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

my $series = $schema->resultset( 'Series' )->find( 3 );
is( $series->date_from, '2000-01-01', "Parent object has expected date-from." );
is( $series->date_to, '2010-01-01', "Parent object has expected date-to." );

my $older_item = $schema->resultset( 'Item' )->find( 4 );
my $newer_item = $schema->resultset( 'Item' )->find( 5 );

$older_item->date_from( '1999-01-01' );
$older_item->update;
$older_item->discard_changes;
$series->discard_changes;
is ( $series->date_from, '1999-01-01', 'Parent object lowered its date-from floor.');

$newer_item->date_to( '2012-01-01' );
$newer_item->update;
$series->discard_changes;
is ( $series->date_to, '2012-01-01', 'Parent object raised its date-to ceiling.');

$older_item->date_from( '2001-01-01' );
$older_item->update;
$series->discard_changes;
is ( $series->date_from, '2001-01-01', 'Parent object raised its date-from floor.');

$newer_item->date_to( '2011-01-01' );
$newer_item->update;
$newer_item->discard_changes;
$series->discard_changes;
is ( $series->date_to, '2011-01-01', 'Parent object lowered its date-to ceiling.');

#foreach ( $newer_item, $older_item ) {
#    $_->date_to( undef );
#    $_->update;
#}
#$series->discard_changes;
#is ( $series->date_to, '2002-01-01',
#                       'Parent object with date_to-less children does the right thing.');

$newer_item->delete;
$older_item->delete;
$series->discard_changes;
is ( $series->date_from, undef, 'Childless parent object removed its date_from.');
is ( $series->date_to, undef, 'Childless parent object removed its date_to.');

# Test exceptional date-derivation behavior for items, first resetting the DB.
$schema = CIDERTest->init_schema;
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

$older_item = $schema->resultset( 'Item' )->find( 4 );
$schema->resultset( 'Object' )->create( {
                                                id => 6,
                                                number => 'n5.1',
                                                title => 'A subitem',
                                                audit_trail => 6,
                                                parent => $older_item->id,
                                            } );
$schema->resultset( 'Item' )->create( {
                                            id => 6,
                                            dc_type => 1,
                                            accession_number => '2011.004',
                                            volume => undef,
                                            item_date_from => '1900',
                                            item_date_to   => '1901',
                                        } );

$older_item->discard_changes;
is ( $older_item->date_from, '1900',
     'The parent item rolled its own from_date back to match an older subitem.'
);
is ( $older_item->date_to,   '2008-01-01',
     'The parent item maintained its to_date despite an older subitem.'
);

my $subitem = $schema->resultset( 'Item' )->find( 6 );
$subitem->item_date_from( '2005' );
$subitem->update;
$older_item->discard_changes;
is ( $older_item->date_from, '2000-01-01',
     'The parent item remembered its old from-date.'
);

#########################
# Testing next/prev stuff
#########################
# Reset the database.
$schema = CIDERTest->init_schema;
$schema->user( $schema->resultset( 'User' )->find( 1 ) );

# Stick in a new sub-item.
$schema->resultset( 'Object' )->create( {
                                            id => 6,
                                            number => 'n5.1',
                                            title => 'A subitem',
                                            audit_trail => 1,
                                            parent => '5', } );
$schema->resultset( 'Item' )->create( {
                                            id => 6,
                                            dc_type => 1,
                                            accession_number => '2011.004',
                                            volume => undef,
                                        } );

$series = $schema->resultset( 'Series' )->find( 3 );
is ( $series->previous_object, undef, 'Series knows it has no previous object.' );
is ( $series->next_object, undef, 'Series knows it has next object.' );

my $item = $schema->resultset( 'Item' )->find( 4 );
is ( $item->next_object->id, '5', 'Item4 knows its next object.' );
is ( $item->next_object->next_object->id, '6',
    'Item5 knows its next object (investigating its descendants).' );
is ( $item->next_object->previous_object->id, '4',
    'Item5 knows its previous object.' );
is ( $item->next_object->next_object->previous_object->id, '5',
    'Item6 knows its next object (investigating its ancestors).' );

done_testing;
