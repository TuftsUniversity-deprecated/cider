package CIDER::Schema::Result::DigitalObjectApplication;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::DigitalObjectApplication

=cut

__PACKAGE__->table( 'digital_object_application' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'int', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->add_columns(
    digital_object =>
        { data_type => 'int', is_foreign_key => 1 },
);
__PACKAGE__->belongs_to(
    digital_object =>
        'CIDER::Schema::Result::DigitalObject',
    undef,
    { proxy => 'item' }
);

__PACKAGE__->add_columns(
    application =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->application() }, fallback => 1;

sub insert {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->item->object );

    return $self;
}

sub update {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->item->object );

    return $self;
}

sub delete {
    my $self = shift;

    $self->next::method( @_ );

    $self->result_source->schema->indexer->update( $self->item->object );

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
