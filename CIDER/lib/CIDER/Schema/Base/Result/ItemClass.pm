package CIDER::Schema::Base::Result::ItemClass;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

use Carp;
use String::CamelCase qw(decamelize);

=head1 NAME

CIDER::Schema::Base::Result::ItemClass

=head1 DESCRIPTION

Generic base class for item classes.

=cut


sub setup_item {
    my ( $class ) = @_;

    $class->load_components( 'UpdateFromXML' );

    $class->add_column(
        id =>
            { data_type => 'int', is_auto_increment => 1 },
    );
    $class->set_primary_key( 'id' );

    $class->add_column(
        item =>
            { data_type => 'int', is_foreign_key => 1 },
    );
    $class->belongs_to(
        item =>
            'CIDER::Schema::Result::Item',
    );
}



=head2 update_format_from_xml_hashref( $hr )

Update a Format authority list column from an XML element hashref.
The format will be added to the authority list if it doesn't already
exist.

=cut

# TO DO: refactor update_term_from_xml_hashref?

sub update_format_from_xml_hashref {
    my $self = shift;
    my ( $hr ) = @_;

    if ( exists( $hr->{ format } ) ) {
        my $rs = $self->result_source->related_source( 'format' )->resultset;
        my $obj = $rs->find_or_create( { name => $hr->{ format },
                                         class => $self->table } );
        $self->format( $obj );
    }
}

sub name_and_note {
    my $self = shift;

    return $self->location->barcode;
}

# type: Returns a descriptive, plain-English string describing what type of class this
#       is, based on a cleaned-up version of its Perl class name.
sub type {
    my $self = shift;

    my $class = ref $self ;
    my ( $type ) = $class =~ /::(\w+)$/;
    $type = decamelize( $type );
    $type =~ s/_/ /g;

    return $type;
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
