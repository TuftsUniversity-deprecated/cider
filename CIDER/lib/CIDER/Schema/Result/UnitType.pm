package CIDER::Schema::Result::UnitType;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::UnitType;

=cut

__PACKAGE__->table( 'unit_type' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'tinyint', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    locations =>
        'CIDER::Schema::Result::Location',
    'unit_type',
    { cascade_copy => 0, cascade_delete => 0 }
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
__PACKAGE__->add_unique_constraint( [ 'name' ] );
use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->add_columns(
    volume =>
        { data_type => 'decimal', is_nullable => 1, size => [5, 2] },
);

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
