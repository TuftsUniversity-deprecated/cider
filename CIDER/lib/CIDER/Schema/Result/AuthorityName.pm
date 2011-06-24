package CIDER::Schema::Result::AuthorityName;

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 NAME

CIDER::Schema::Result::AuthorityName

=cut

__PACKAGE__->table("authority_name");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 note

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "note",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 object_personal_names

Type: has_many

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->has_many(
  "object_personal_names",
  "CIDER::Schema::Result::Object",
  { "foreign.personal_name" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 object_corporate_names

Type: has_many

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->has_many(
  "object_corporate_names",
  "CIDER::Schema::Result::Object",
  { "foreign.corporate_name" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 object_creator

Type: has_many

Related object: L<CIDER::Schema::Result::Object>

=cut

__PACKAGE__->has_many(
  "object_creators",
  "CIDER::Schema::Result::Object",
  { "foreign.creator" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

1;
