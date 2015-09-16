package CIDER::Schema::Result::ObjectWithDerivedFields;

use Moose;
use List::MoreUtils qw( uniq );

extends qw/DBIx::Class::Core/;
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('object_with_derived_fields');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->add_columns(
  'id' => {
    data_type => 'integer',
    is_auto_increment => 1,
  },
  'title' => {
    data_type => 'varchar',
  },
  'earliest' => {
    data_type => 'date',
  },
  'latest' => {
    data_type => 'date',
  },
  'accession_numbers' => {
    data_type => 'text',
  },
  'restrictions' => {
    data_type => 'text',
  },
);

around 'accession_numbers' => sub {
    my $orig = shift;
    my $self = shift;

    my $numbers_string = $self->$orig || q{};
    my @numbers = sort( uniq( split( /\s*,\s*/, $numbers_string ) ) );

    return join '; ', @numbers;
};

around 'restrictions' => sub {
    my $orig = shift;
    my $self = shift;

    # This trusts that the meaning of the numeric values of the restrictions column
    # won't change. But honestly they should have been an enum to begin with (and
    # not an fkey into item_restrictions), so we'll just treat them that way.

    my $restrictions = $self->$orig || q{};
    if ( $restrictions eq '1' ) {
        return "none";
    }
    elsif ( $restrictions =~ /1/ ) {
        return "some";
    }
    else {
        return "all";
    }
};


1;
