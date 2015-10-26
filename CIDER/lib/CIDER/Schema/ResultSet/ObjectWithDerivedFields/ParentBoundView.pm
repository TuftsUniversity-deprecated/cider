package CIDER::Schema::ResultSet::ObjectWithDerivedFields::ParentBoundView;
use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use CIDER::Logic::Utils;

sub objects_sketch {
    my $self = shift;

    my $attributes = $OBJECT_SKETCH_SEARCH_ATTRIBUTES;
    push @{ $attributes->{ columns } },
        'me.earliest', 'me.latest';

    my $resultset = $self->search(
        { },
        $attributes,
    );

    if ( wantarray ) {
        return $resultset->all;
    }
    else {
        return $resultset;
    }
}

1;
