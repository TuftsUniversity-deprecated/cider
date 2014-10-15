package CIDER::HasLocation;

use Moose::Role;
use Carp qw( croak );

has 'old_location' => (
    is => 'rw',
    isa => 'Maybe[CIDER::Schema::Result::Location]',
    default => undef,
);

sub location {
    my $self = shift;
    if ( @_ ) {
        my %dirty_fields = $self->get_dirty_columns;
        unless ( $dirty_fields{ location } ) {
            $self->old_location( $self->location );
        }
    }

    $self->_location( @_ );

}

# update: If this item's location has changed, alter the object_location table
#         appropriately.
around 'update' => sub {
    my $orig = shift;
    my $self = shift;

    my $object_location_rs;
    if ( $self->old_location ) {
        $object_location_rs =
            $self->result_source->schema->resultset( 'ObjectLocation' );
        my @deletables = $object_location_rs->search( {
            object   => $self->item->id,
            location => $self->old_location->id,
        } );
        foreach ( @deletables ) {
            $_->delete;
        }
    }

    $self->$orig( @_ );

    if ( $self->old_location ) {
        $object_location_rs->create( {
            object   => $self->item->id,
            location => $self->location,
            referent_object => $self->item->id,
        } );
        $self->old_location( undef );
    }

    return $self;
};

# insert: On insert, update the object_location table appropriately as well, if
#         necessary.
after 'insert' => sub {
    my $self = shift;

    my $object_location_rs =
        $self->result_source->schema->resultset( 'ObjectLocation' );

    $object_location_rs->create( {
        object   => $self->item->id,
        location => $self->location,
        referent_object => $self->item->id,
    } );
};

# delete: On delete, clean up the object_location table appropriately as well, if
#         necessary.
after 'delete' => sub {
    my $self = shift;

    if ( not( $self->in_storage ) ) {
        $self->result_source->schema->resultset( 'ObjectLocation' )
             ->search( {
                object   => $self->item->id,
                location => $self->location->id,
               } )
             ->delete_all;
    }
};

=head2 update_location_from_xml_hashref( $hr )

Update a Location column from an XML element hashref.  Throws an error
if the locationID does not refer to an existent Location.

=cut

sub update_location_from_xml_hashref {
    my $self = shift;
    my ( $hr ) = @_;

    if ( exists( $hr->{ location } ) ) {
        my $barcode = $hr->{ location };
        my $rs = $self->result_source->related_source( 'location' )->resultset;
        my $loc = $rs->find( { barcode => $barcode } );
        unless ( $loc ) {
            croak "Location '$barcode' does not exist.";
        }

        $self->location( $loc );
    }
}

sub name_and_note {
    my $self = shift;

    return $self->location->barcode;
}

1;
