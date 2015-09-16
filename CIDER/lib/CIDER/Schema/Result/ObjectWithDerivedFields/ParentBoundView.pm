package CIDER::Schema::Result::ObjectWithDerivedFields::ParentBoundView;

use base qw/CIDER::Schema::Result::ObjectWithDerivedFields/;
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('object_with_derived_fields');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition("select
                  object.*,
                  min(item_date_from) as earliest,
                  max(item_date_to) as latest,
                  group_concat(distinct accession_number) as accession_numbers,
                  group_concat(distinct restrictions) as restrictions
                  from object, item, enclosure
                  where object.id = ancestor and item.id = descendant
                  and object.parent = ?
                  group by object.id
                  "
);
1;
