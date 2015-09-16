package CIDER::Schema::Result::Item;

use strict;
use warnings;

use base 'CIDER::Schema::Base::Result::TypeObject';

use String::CamelCase qw( camelize decamelize );
use Class::Method::Modifiers qw( before after around );

=head1 NAME

CIDER::Schema::Result::Item

=cut

__PACKAGE__->load_components( 'UpdateFromXML' );

__PACKAGE__->table( 'item' );

__PACKAGE__->resultset_class( 'CIDER::Schema::Base::ResultSet::TypeObject' );

__PACKAGE__->setup_object;

__PACKAGE__->has_many(
    item_creators =>
        'CIDER::Schema::Result::ItemAuthorityName',
    undef,
    { where => { role => 'creator' } }
);
__PACKAGE__->many_to_many(
    creators =>
        'item_creators',
    'name',
);

__PACKAGE__->add_columns(
    circa =>
        { data_type => 'boolean', default_value => 0 },
    is_group =>
        { data_type => 'boolean', default_value => 0 },
    embargo_end_date =>
        { data_type => 'varchar', size => 10,
          is_nullable => 1,
        },
);

__PACKAGE__->add_columns(
    restrictions =>
        { data_type => 'tinyint', is_foreign_key => 1, is_nullable => 1,
          default_value => 1,   # 1 = 'none'
        },
);
__PACKAGE__->belongs_to(
    restrictions =>
        'CIDER::Schema::Result::ItemRestrictions',
);

__PACKAGE__->add_columns(
    accession_number =>
        { data_type => 'varchar', is_nullable => 1 },
);

__PACKAGE__->add_columns(
    dc_type =>
        { data_type => 'tinyint', is_foreign_key => 1 },
    item_date_from =>
        { data_type => 'varchar', size => 10,
          is_nullable => 1,
        },
    item_date_to =>
        { data_type => 'varchar', size => 10,
          is_nullable => 1,
        },
);

__PACKAGE__->belongs_to(
    dc_type =>
        'CIDER::Schema::Result::DCType',
);

__PACKAGE__->has_many(
    item_personal_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
    undef,
    { where => { role => 'personal_name' } }
);
__PACKAGE__->many_to_many(
    personal_names =>
        'item_personal_names',
    'name',
);

__PACKAGE__->has_many(
    item_corporate_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
    undef,
    { where => { role => 'corporate_name' } }
);
__PACKAGE__->many_to_many(
    corporate_names =>
        'item_corporate_names',
    'name',
);

__PACKAGE__->has_many(
    item_topic_terms =>
        'CIDER::Schema::Result::ItemTopicTerm',
);
__PACKAGE__->many_to_many(
    topic_terms =>
        'item_topic_terms',
    'term',
);

__PACKAGE__->has_many(
    item_geographic_terms =>
        'CIDER::Schema::Result::ItemGeographicTerm',
);
__PACKAGE__->many_to_many(
    geographic_terms =>
        'item_geographic_terms',
    'term',
);

__PACKAGE__->add_columns(
    description =>
        { data_type => 'text', is_nullable => 1 },
    volume =>
        { data_type => 'varchar', is_nullable => 1 },
    issue =>
        { data_type => 'varchar', is_nullable => 1 },
    abstract =>
        { data_type => 'text', is_nullable => 1 },
    citation =>
        { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->has_many(
    file_folders =>
        'CIDER::Schema::Result::FileFolder',
);

__PACKAGE__->has_many(
    containers =>
        'CIDER::Schema::Result::Container',
);

__PACKAGE__->has_many(
    bound_volumes =>
        'CIDER::Schema::Result::BoundVolume',
);

__PACKAGE__->has_many(
    three_dimensional_objects =>
        'CIDER::Schema::Result::ThreeDimensionalObject',
);

__PACKAGE__->has_many(
    audio_visual_media =>
        'CIDER::Schema::Result::AudioVisualMedia',
);

__PACKAGE__->has_many(
    documents =>
        'CIDER::Schema::Result::Document',
);

__PACKAGE__->has_many(
    physical_images =>
        'CIDER::Schema::Result::PhysicalImage',
);

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
);

__PACKAGE__->has_many(
    browsing_objects =>
        'CIDER::Schema::Result::BrowsingObject',
);


__PACKAGE__->has_many(
    item_authority_names =>
        'CIDER::Schema::Result::ItemAuthorityName',
);
__PACKAGE__->many_to_many(
    authority_names =>
        'item_authority_names',
    'name',
);

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

=head1 METHODS

=head2 type

The type identifier for this class.

=cut

sub type {
    return 'item';
}

=head2 classes

The list of ItemClass objects associated with this item.

=cut

sub classes {
    my $self = shift;

    my @classes = (
        $self->file_folders,
        $self->containers,
        $self->bound_volumes,
        $self->three_dimensional_objects,
        $self->audio_visual_media,
        $self->documents,
        $self->physical_images,
        $self->digital_objects,
        $self->browsing_objects,
    );
    return @classes;
}

=head2 locations

A list of locations of the item's classes.  This list may include
duplicates, if multiple classes have the same location.

=cut

sub locations {
    my $self = shift;

    return map { $_->location } grep { $_->can( 'location' ) } $self->classes;
}

=head2 insert

Override TypeObject->insert to set default values.

=cut

sub insert {
    my $self = shift;

    $self->dc_type( undef ) unless defined $self->dc_type;

    return $self->next::method( @_ );
}

=head2 store_column( $column, $value )

Override store_column to set default values.

=cut

sub store_column {
    my $self = shift;
    my ( $column, $value ) = @_;

    if ( !defined( $value ) || $value eq '' ) {
        if ( $column eq 'circa' ) {
            $value = 0;
        }
        elsif ( $column eq 'dc_type' ) {
            my $rs = $self->result_source->related_source( $column )->resultset;
            $value = $rs->find( { name => 'Text' } )->id;
        }
    }

    return $self->next::method( $column, $value );
}

=head2 delete

Override delete to work recursively on our related objects, rather
than relying on the database to do cascading delete.

=cut

sub delete {
    my $self = shift;

    $_->delete for (
        $self->item_authority_names,
        $self->item_topic_terms,
        $self->item_geographic_terms,
        $self->classes,
    );

    return $self->next::method( @_ );
}

=head2 update_from_xml( $element )

Update (or insert) this object from an XML element.  The element is
assumed to have been validated.  The object is returned.

=cut

sub update_from_xml {
    my $self = shift;
    my ( $elt ) = @_;

    my $hr = $self->xml_to_hashref( $elt );

    $self->object->update_from_xml( $elt, $hr );

    # Text elements
    $self->update_boolean_from_xml_hashref(
        $hr, 'circa' );
    $self->update_dates_from_xml_hashref(
        $hr, 'item_date', 'date' );
    $self->update_text_from_xml_hashref(
        $hr, 'accession_number' );
    $self->update_text_from_xml_hashref(
        $hr, 'description' );
    $self->update_text_from_xml_hashref(
        $hr, 'volume' );
    $self->update_text_from_xml_hashref(
        $hr, 'issue' );
    $self->update_text_from_xml_hashref(
        $hr, 'abstract' );
    $self->update_text_from_xml_hashref(
        $hr, 'citation' );

    # Controlled vocabulary elements

    $self->update_cv_from_xml_hashref(
        $hr, 'restrictions' );
    $self->update_cv_from_xml_hashref(
        $hr, 'dc_type' );

    $self->update_or_insert;

    # Repeatables - These have to be done after the row is inserted,
    # so that its id can be used as a foreign key.

    $self->update_terms_from_xml_hashref(
        $hr, creators => 'name' );
    $self->update_terms_from_xml_hashref(
        $hr, personal_names => 'name' );
    $self->update_terms_from_xml_hashref(
        $hr, corporate_names => 'name' );
    $self->update_terms_from_xml_hashref(
        $hr, topic_terms => 'term' );
    $self->update_terms_from_xml_hashref(
        $hr, geographic_terms => 'term' );

    if ( exists $hr->{ classes } ) {
        # If <classes> doesn't contain a <group/> sub-element, this item will
        # lose its group flag. So let's zero that out preemptively.
        $self->is_group( 0 );
        for my $class_elt ( @{ $hr->{ classes } } ) {
            if ( $class_elt->tagName eq 'group' ) {
                # OK, so it is a group. Put the group-flag back up and continue
                # to the next <classes> sub-element.
                $self->is_group( 1 );
                next;
            }
            # Look at the "action" attribute of each element under <classes>.
            # If it's "create" (or absent), create a new class as described.
            # If it's "update", update all same-type classes of this item.
            my $action = $class_elt->getAttribute( 'action' );
            my $rel = decamelize( $class_elt->tagName );
            $rel = "${rel}s" unless $rel eq 'audio_visual_media';
            if ( !$action or $action eq 'create' ) {
                my $class = $self->new_related( $rel, { } );
                $class->update_from_xml( $class_elt );
            }
            elsif ( $action eq 'update' ) {
                my @classes = $self->$rel;
                for my $class ( @classes ) {
                    $class->update_from_xml( $class_elt );
                }
            }
            else {
                die "Don't know how to handle class action attribute '$action'.";
            }
        }
    }

    $self->update;
    $self->update_audit_trail_from_xml_hashref( $hr );

    return $self;
}

=head2 update_terms_from_xml_hashref( $hr, $relname, $proxy )

Update an authority term many-to-many relationship from an XML element
hashref.  $relname converted to mixed case is the tagname of the child
element on $hr.  Its children have 'name' and (optional) 'note'
elements, which are used to lookup/create/update the appropriate
authority term.  $proxy is the name of the column on the link class
that points to the authority term class.

=cut

sub update_terms_from_xml_hashref {
    my $self = shift;
    my ( $hr, $relname, $proxy ) = @_;

    my $tag = lcfirst( camelize( $relname ) );
    $relname = "item_$relname";
    my $irs = $self->result_source->related_source( $relname );
    my $rs = $irs->related_source( $proxy )->resultset;
    if ( exists( $hr->{ $tag } ) ) {
        $self->delete_related( $relname );
        for my $term_elt ( @{ $hr->{ $tag } } ) {
            my $term_hr = $self->xml_to_hashref( $term_elt );
            my $term = $rs->find( { name => $term_hr->{ name } } );
            if ( $term ) {
                if ( exists $term_hr->{ note } ) {
                    $term->update( { note => $term_hr->{ note } } );
                }
            }
            else {
                $term = $rs->create( $term_hr );
            }
            $self->create_related( $relname, { $proxy => $term } );
        }
    }
}

sub accession_numbers {
    my $self = shift;
    return $self->accession_number( @_ );
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
