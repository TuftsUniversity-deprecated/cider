package CIDER::Schema::Result::ItemRestrictions;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::ItemRestrictions

=cut

__PACKAGE__->table( 'item_restrictions' );

__PACKAGE__->add_columns(
    id =>
        { data_type => 'tinyint', is_auto_increment => 1 },
);
__PACKAGE__->set_primary_key( 'id' );

__PACKAGE__->has_many(
    items =>
        'CIDER::Schema::Result::Item',
    'restrictions',
    { cascade_copy => 0, cascade_delete => 0 },
);

__PACKAGE__->add_columns(
    name =>
        { data_type => 'varchar' },
);
use overload '""' => sub { shift->name() }, fallback => 1;

__PACKAGE__->add_columns(
    description =>
        { data_type => 'varchar' },
);

1;
