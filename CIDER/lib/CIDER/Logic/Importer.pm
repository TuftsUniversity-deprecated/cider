package CIDER::Logic::Importer;

use strict;
use warnings;

use Moose;

use Text::CSV;
use Carp;

use CIDER::Schema;

has 'schema' => (
    is => 'rw',
    isa => 'DBIx::Class',
);

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my ( $connect_info ) = @_;

    my $schema = CIDER::Schema->connect( $connect_info );

    return $class->$orig( schema => $schema );
};

sub import_from_csv {
    my $self = shift;
    my ($handle) = @_;

    my $csv = Text::CSV->new;
    $csv->column_names( $csv->getline( $handle ) );

    my $schema = $self->schema;
    my $object_rs = $schema->resultset( 'Object' );

    # All rows are inserted at once, or none at all if there are errors.
    $schema->txn_begin;

    my $row_number = 0;
    while ( my $row = $csv->getline_hr( $handle ) ) {
        $row_number++;

        # If the 'id' field has no value, remove it completely, so that the
        # DB can properly assign a fresh one.
        unless ( $row->{ id } ) {
            delete $row->{ id };
        }

        # TO DO: do we need to handle parent specially?

        # TO DO: check cider_type?
        # Do we need cider_type, or can we always deduce it?

        # Perform the actual update-or-insertion.
        my $object;
        eval { $object = $object_rs->update_or_create( $row ); };
        if ( $@ ) {

            $schema->txn_rollback;

            croak "CSV import failed at data row $row_number:\n$@\n";
        }
    }

    $schema->txn_commit;

    return $row_number;
}
1;