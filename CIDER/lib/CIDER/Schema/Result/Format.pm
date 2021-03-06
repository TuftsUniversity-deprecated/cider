package CIDER::Schema::Result::Format;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::Format

=cut

__PACKAGE__->table( 'format' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    class =>
        { data_type => 'enum',
          extra => { list => [ qw(
                                     container
                                     bound_volume
                                     three_dimensional_object
                                     audio_visual_media
                                     document
                                     physical_image
                                     digital_object
                                     browsing_object
                             ) ] } },
);

__PACKAGE__->has_many(
    containers =>
        'CIDER::Schema::Result::Container',
    'format',
);

__PACKAGE__->many_to_many(
    container_items =>
        'containers',
    'item'
);

__PACKAGE__->has_many(
    bound_volumes =>
        'CIDER::Schema::Result::BoundVolume',
    'format',
);

__PACKAGE__->many_to_many(
    bound_volume_items =>
        'bound_volumes',
    'item'
);

__PACKAGE__->has_many(
    three_dimensional_objects =>
        'CIDER::Schema::Result::ThreeDimensionalObject',
    'format',
);

__PACKAGE__->many_to_many(
    three_dimensional_object_items =>
        'three_dimensional_objects',
    'item'
);

__PACKAGE__->has_many(
    audio_visual_media =>
        'CIDER::Schema::Result::AudioVisualMedia',
    'format',
);

__PACKAGE__->many_to_many(
    audio_visual_media_items =>
        'audio_visual_media',
    'item'
);

__PACKAGE__->has_many(
    documents =>
        'CIDER::Schema::Result::Document',
    'format',
);

__PACKAGE__->many_to_many(
    document_items =>
        'documents',
    'item'
);

__PACKAGE__->has_many(
    physical_images =>
        'CIDER::Schema::Result::PhysicalImage',
    'format',
);

__PACKAGE__->many_to_many(
    physical_object_items =>
        'physical_objects',
    'item'
);

__PACKAGE__->has_many(
    digital_objects =>
        'CIDER::Schema::Result::DigitalObject',
    # TO DO: why can't we just say 'format' here?
    { 'foreign.format' => 'self.id' },
);

__PACKAGE__->many_to_many(
    digital_object_items =>
        'digital_objects',
    'item'
);

__PACKAGE__->has_many(
    browsing_objects =>
        'CIDER::Schema::Result::BrowsingObject',
    'format',
);

__PACKAGE__->many_to_many(
    browsing_object_items =>
        'browsing_objects',
    'item'
);

sub items {
    my $self = shift;

    my $class = $self->class;
    my $rel = "${class}_items";
    return $self->$rel;
}

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->add_unique_constraint( [ qw(class name) ] );

sub update {
    my $self = shift;

    $self->next::method( @_ );

    for my $item ( $self->items ) {
        $self->result_source->schema->indexer->update( $item->object );
    }

    return $self;
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
