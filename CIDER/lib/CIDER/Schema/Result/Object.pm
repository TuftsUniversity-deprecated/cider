package CIDER::Schema::Result::Object;

use Moose;

extends 'DBIx::Class::Core';
use Class::Method::Modifiers qw( around after );
use List::Util qw( minstr maxstr );
use Carp qw( croak );

use CIDER::Logic::Utils;

=head1 NAME

CIDER::Schema::Result::Object

=cut

__PACKAGE__->table( 'object' );

 __PACKAGE__->load_components( 'UpdateFromXML', );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    parent =>
        { data_type => 'int', is_foreign_key => 1, is_nullable => 1,
          accessor => '_parent',
        },
);

__PACKAGE__->belongs_to(
    parent =>
        'CIDER::Schema::Result::Object',
);

__PACKAGE__->has_many(
    objects =>
        'CIDER::Schema::Result::Object',
    'parent',
    { cascade_update => 0, cascade_delete => 0, join_type => 'left', }
);

__PACKAGE__->add_columns(
    number =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'number' ] );

__PACKAGE__->add_columns(
    title =>
        { data_type => 'varchar' },
);

__PACKAGE__->might_have(
    collection =>
        'CIDER::Schema::Result::Collection',
    undef,
    { cascade_update => 0, cascade_delete => 0 }
);

__PACKAGE__->might_have(
    series =>
        'CIDER::Schema::Result::Series',
    undef,
    { cascade_update => 0, cascade_delete => 0 }
);

__PACKAGE__->might_have(
    item =>
        'CIDER::Schema::Result::Item',
    undef,
    { cascade_update => 0, cascade_delete => 0 }
);


=head2 type_object

The type-specific object for this Object, i.e. either a Collection,
Series, or Item object.

=cut

sub type_object {
    my $self = shift;

    return $self->collection || $self->series || $self->item;
}

=head2 type

The type identifier for this Object, i.e. either 'collection',
'series', or 'item'.

=cut

sub type {
    my $self = shift;

    if ( $self->type_object ) {
        return $self->type_object->type;
    }
    else {
        return undef;
    }
}

__PACKAGE__->has_many(
    object_set_objects =>
        'CIDER::Schema::Result::ObjectSetObject',
);

__PACKAGE__->has_many(
    object_locations =>
        'CIDER::Schema::Result::ObjectLocation',
);

__PACKAGE__->many_to_many(
    sets =>
        'object_set_objects',
    'object_set');

__PACKAGE__->has_many(
  "enclosures",
  "CIDER::Schema::Result::Enclosure",
  { "foreign.ancestor" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
  "holders",
  "CIDER::Schema::Result::Enclosure",
  { "foreign.descendant" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->many_to_many(
    raw_ancestors =>
        'holders',
    'ancestor',
);

__PACKAGE__->many_to_many(
    raw_descendants =>
        'enclosures',
    'descendant',
);

__PACKAGE__->add_columns(
    audit_trail =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    audit_trail =>
        'CIDER::Schema::Result::AuditTrail',
    undef,
    { cascade_delete => 1 }
);

has derived_fields => (
    is => 'ro',
    isa => 'Maybe[CIDER::Schema::Result::ObjectWithDerivedFields]',
    lazy_build => 1,
    handles => {
        date_from => 'earliest',
        date_to   => 'latest',
        accession_numbers => 'accession_numbers',
        restriction_summary => 'restrictions',
    },
);

has ddate_from => (
    is => 'ro',
    isa => 'Str',
    default => 'foo',
);

has ddate_to => (
    is => 'ro',
    isa => 'Str',
    default => 'foo',
);

has daccession_numbers => (
    is => 'ro',
    isa => 'Str',
    default => 'foo',
);

has drestriction_summary => (
    is => 'ro',
    isa => 'Str',
    default => 'foo',
);

sub _build_derived_fields {
    my $self = shift;

    unless ( $self->in_storage ) {
        return undef;
    }

    my $view_rs = $self->result_source->schema
                 ->resultset( 'ObjectWithDerivedFields::IDBoundView' );

    my $result = $view_rs->search(
                       {},
                       { bind => [ $self->id ] },
                   )
                 ->single;

    unless ( defined $result ) {
        $result = $view_rs->new_result( { title => 'None' } );
    }

    return $result;
}


sub children {
    my $self = shift;

    return map { $_->type_object }
        $self->objects->search( undef, { order_by => 'number' } );
}

=head2 number_of_children

The number of child objects that this object contains. (Running this method is faster
than running children() and then counting the results yourself.)

=cut

sub number_of_children {
    my $self = shift;

    # If this object came as a result of children_sketch() or similar, than this object
    # will have a special 'number_of_children' pseudo-column available, populated with
    # the result of a COUNT(*) db query.
    # Otherwise, we'll just run a fresh query to get the number of children.
    my $number;
    eval { $number = $self->get_column( 'number_of_children' ) };

    if ( $@ ) {
        return $self->objects->count;
    }
    else {
        return $number;
    }
}

sub ancestors {
    my $self = shift;

    my $raw_ancestors = $self->raw_ancestors;
    return map { $_->type_object } $raw_ancestors->all;
}

# has_ancestor: Returns 1 if the given object is an ancestor of this object.
sub has_ancestor {
    my $self = shift;
    my ( $possible_ancestor ) = @_;

    for my $ancestor ( $self->ancestors ) {
        if ( $ancestor->id == $possible_ancestor->id ) {
            return 1;
        }
    }

    return 0;
}

=head2 descendants

Returns a list of all descendants, including self.

=cut

sub descendants {
    my $self = shift;
    return map { $_->type_object } $self->raw_descendants->all;
}

=head2 item_descendants

Returns a list of all descendants that are Items.

=cut

sub item_descendants {
    my $self = shift;

    return grep { $_->type eq 'item' } $self->descendants;
}

# Override the DBIC delete() method to work recursively on our related
# objects, rather than relying on the database to do cascading delete.
sub delete {
    my $self = shift;

    $self->type_object->delete if $self->type_object;

    $_->delete for ( $self->children,
                     $self->object_set_objects,
                     $self->object_locations,
                     $self->enclosures,
                     $self->holders,
                   );

    $self->next::method( @_ );

    $self->result_source->schema->indexer->remove( $self );

    return $self;
}

sub export {
    my $self = shift;

    $self->audit_trail->add_to_export_logs( {
        staff => $self->result_source->schema->user->staff
    } );
}

sub store_column {
    my $self = shift;
    my ( $column, $value ) = @_;

    # Convert all empty strings to nulls.
    $value = undef if defined( $value ) && $value eq '';

    return $self->next::method( $column, $value );
}

# parent: Custom user-facing accessor method for the 'parent' column.
#         On set, confirms that no circular graphs are in the making.
sub parent {
    my $self = shift;
    my ( $new_parent ) = @_;

    if ( @_ ) {
        if ( !$new_parent ) {
            $self->_parent( undef );
        }
        else {
            unless ( ref $new_parent ) {
                $new_parent =
                    $self->result_source->resultset->find( $new_parent );
            }

            if ( $self->in_storage ) {

                if ( $new_parent->id == $self->id ) {
                    croak( sprintf "Cannot set a CIDER object (ID %s) to be "
                               . "its own parent.",
                           $self->id,
                       );
                }

                if ( $new_parent->has_ancestor( $self ) ) {
                    croak( sprintf "Cannot set a CIDER object (ID %s) to be "
                               . "the parent of its ancestor (ID %s).",
                           $new_parent->id,
                           $self->id,
                       );
                }
            }

            # If we've made it this far, then this is a legal new parent.
            $self->_parent( $new_parent->id );
        }
    }

    return $self->_parent;
}

=head2 update_from_xml( $element, $hashref )

Update non-type-specific columns on this object from an XML element
and hashref.  The element is assumed to have been validated.  The
object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt, $hr ) = @_;

    if ( $elt->hasAttribute( 'parent' ) ) {
        my $parent_number = $elt->getAttribute( 'parent' );
        my $parent = undef;
        unless ( $parent_number eq '' ) {
            my $rs = $self->result_source->resultset;
            $parent = $rs->find( { number => $parent_number } );
            unless ( $parent ) {
                croak "Parent number '$parent_number' does not exist.";
            }
        }
        $self->parent( $parent );
    }

    $self->update_text_from_xml_hashref( $hr, 'title' );

    # If the object is already in storage, then we need to update it
    # here; otherwise we have to wait to insert it until after the
    # audit trail is set (when the type object is inserted).
    $self->update if $self->in_storage;

    return $self;
}

=head2 full_title

A concatenation of the object's number, title, and dates.

=cut

sub full_title {
    my $self = shift;

    my $number_title = join " ", $self->number, $self->title;
    if ( my $dates = $self->dates ) {
        return "$number_title, $dates";
    }
    return $number_title;
}

=head2 dates

The date or dates of an object, as a single string.

=cut

sub dates {
    my $self = shift;

    if ( my $from = $self->date_from ) {
        my $to = $self->date_to;
        if ( $to && $to ne $from ) {
            return "$from&ndash;$to";
        }
        else {
            return $from;
        }
    }
}

# Returns a DBIC resultset with one row per child object, but every such object will be
# enhanced with additional data suitable for rendering a detailed list without the need
# to run any further DB queries. See root/display_object.tt for usage example.
sub children_sketch {
    my $self = shift;

    my $children_rs = $self->result_source->schema
                    ->resultset( 'ObjectWithDerivedFields::ParentBoundView' )
                    ->search( {}, { bind => [ $self->id ] } )
                    ->objects_sketch;

    return $children_rs;
}

# next_object: Returns the next object in the whole CIDER object hierarchy.
sub next_object {
    my $self = shift;

    my $type = $self->type;

    # Return the first child that is the same type of object as this object, if
    # there is such a thing.
    if ( my $child = $self->objects->search(
            {
                "$type.id" => { '!=' => undef },
            },
            {
                rows     => 1,
                order_by => 'number',
                join     => $type,
            },
        )->single ) {
        return $child;
    }

    # Else, if I have a sibling with a later dictionary number than me, return it.
    if ( my $sibling = $self->next_sibling ) {
        return $sibling;
    }

    # Else, return my nearest "aunt" (ancestor's later-numbered sibling) that's the
    # same type of object as this object.
    for my $ancestor ( reverse $self->raw_ancestors ) {
        last if $ancestor->type ne $type;
        if ( my $aunt = $ancestor->next_sibling ) {
            return $aunt;
        }
    }

    # If we've come this far, we're all the way at the end of the browsable DB.
    return undef;
}

# previous_object: Returns the next object in the whole CIDER object hierarchy.
sub previous_object {
    my $self = shift;

    my $type = $self->type;

    # If I have a previous sibling, return its dictionary-latest descendant of the
    # same type as this object.
    # (This will be the sibling itself, if it has no descendants.)
    my $previous_sibling = $self->previous_sibling;
    if ( $previous_sibling ) {
        return $previous_sibling->raw_descendants->search(
            {
                "$type.id" => { '!=' => undef },
            },
            {
                rows     => 1,
                order_by => { -desc => 'descendant.number' },
                join     => $type,
            },
        )->single;
    }

    # If there's no previous sibling, then the previous object is the parent... but only
    # if the parent is of the same type as this object.
    if ( my $parent = $self->parent) {
        return $parent if $parent->type eq $type;
    }

    # If we've come this far, we're all the way at the start of the browsable DB.
    return undef;
}

# next_sibling: Return the object with my parent and the next-latest number (dictionary
#               sort), if there is one.
sub next_sibling {
    my $self = shift;

    return $self->siblings->search(
        { number => { '>', $self->number } },
        {
            rows  => 1,
            order_by => 'number',
        },
    )->single;
}

# previous_sibling: Return the object with my parent and the next-earliest number
#                   (dictionary sort), if there is one.
sub previous_sibling {
    my $self = shift;

    return $self->siblings->search(
        { number => { '<', $self->number } },
        {
            rows  => 1,
            order_by => { -desc => 'number' },
        },
    )->single;
}

# siblings: Return a resultset containing all objects sharing my parent, but not me.
sub siblings {
    my $self = shift;

    my $parent_id;
    if ( $self->parent ) {
        $parent_id = $self->parent->id;
    }

    return $self->result_source->schema->resultset( 'Object' )->search(
        {
            parent => $parent_id,
            id     => { '!=', $self->id },
        }
    );
}

# If an update caused values to change on an associated item,
# go ahead and update that item too.
after 'update' => sub {
    my $self = shift;
    if ( my $item = $self->item ) {
        if ( $item->get_dirty_columns ) {
            $item->update;
        }
    }
};

around 'update' => sub {
    my $original_method = shift;
    my $self = shift;

    my $parent_changed = $self->is_column_changed( 'parent' );

    my $result = $self->$original_method( @_ );

    if ( $parent_changed ) {
        $self->_remove_my_tree;
        $self->_add_my_tree_to_parent;
    }
};

after 'insert' => sub {
    my $self = shift;
    my $id = $self->id;

    $self->result_source->storage->dbh->do(
        "insert into enclosure( ancestor, descendant ) values ( $id, $id )"
    );

    $self->_add_my_tree_to_parent;
};

sub _remove_my_tree {
    my $self = shift;
    my $id = $self->id;
    $self->result_source->storage->dbh->do(
        "DELETE a FROM enclosure AS a
         JOIN enclosure AS d ON a.descendant = d.descendant
         LEFT JOIN enclosure AS x
         ON x.ancestor = d.ancestor AND x.descendant = a.ancestor
         WHERE d.ancestor = $id AND x.ancestor IS NULL"
    );
}

sub _add_my_tree_to_parent {
    my $self = shift;
    my $id = $self->id;
    if ( $self->parent ) {
        my $parent_id = $self->parent->id;
        $self->result_source->storage->dbh->do(
           "INSERT INTO enclosure (ancestor, descendant)
             SELECT supertree.ancestor, subtree.descendant
             FROM enclosure AS supertree JOIN enclosure AS subtree
             WHERE subtree.ancestor = $id
             AND supertree.descendant = $parent_id"
        );
    }
}


=head1 LICENSE

Copyright 2012 Tufts University

CIDER is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

CIDER is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public
License along with CIDER.  If not, see
<http://www.gnu.org/licenses/>.

=cut

1;
