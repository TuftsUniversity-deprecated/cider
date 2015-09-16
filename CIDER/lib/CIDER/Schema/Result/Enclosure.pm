use utf8;
package CIDER::Schema::Result::Enclosure;

=head1 NAME

CIDER::Schema::Result::Contaneddescendant

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=descendant * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<contaned_descendant>

=cut

__PACKAGE__->table("enclosure");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 ancestor

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 descendant

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "ancestor",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "descendant",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=descendant * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<ancestor>

=over 4

=descendant * L</ancestor>

=descendant * L</descendant>

=back

=cut

__PACKAGE__->add_unique_constraint("ancestor", ["ancestor", "descendant"]);

=head1 RELATIONS

=head2 descendant

Type: belongs_to

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->belongs_to(
  "descendant",
  "CIDER::Schema::Result::Object",
  { id => "descendant" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 ancestor

Type: belongs_to

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->belongs_to(
  "ancestor",
  "CIDER::Schema::Result::Object",
  { id => "ancestor" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

#__PACKAGE__->belongs_to(
#  "item_descendant",
#  "CIDER::Schema::Result::Item",
#  { id => "descendant" },
#  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
#);


__PACKAGE__->meta->make_immutable;
1;
