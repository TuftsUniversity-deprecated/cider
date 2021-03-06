package CIDER::Controller::Location;
use Moose;
use namespace::autoclean;
use Locale::Language;

BEGIN {extends 'Catalyst::Controller::HTML::FormFu'; }

=head1 NAME

CIDER::Controller::Location - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for Location CRUD.

=head1 METHODS

=cut

=head2 index

Display a list of record contexts with links to their detail pages.

=cut

sub index :Path( '' ) :Args( 0 ) {
    my ( $self, $c ) = @_;

    my $model = $c->model( 'CIDERDB::Location' );
    my @locs = $model->search(
        undef,
        {
            prefetch => 'titles',
            order_by => 'barcode',
        }
    );
    $c->stash->{ locs } = \@locs;
}

=head2 create

Create a new location.  If successful, redirect to its detail page,
unless a return_uri was provided in the flash.

=cut

sub create :Local :Args( 0 ) :FormConfig( 'location' ) {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{ form };
    $form->get_field( 'submit' )->value( 'Create' );

    # Add contraint classes to required form fields
    $form->auto_constraint_class('constraint_%t');


    if ( not $form->submitted ) {
        if ( my $return_uri = $c->flash->{ return_uri } ) {
            # We just created a new item or updated an existing item
            # with a new location barcode.
            $form->default_values( { return_uri => $return_uri } );
        }
        if ( my $barcode = $c->flash->{ barcode } ) {
            $form->default_values( { barcode => $barcode } );
        }
    }
    elsif ( $form->submitted_and_valid ) {
        my $loc = $form->model->create;

        if ( my $return_uri = $form->param_value( 'return_uri' ) ) {
            $c->res->redirect( $return_uri );
            return;
        }

        $c->flash->{ we_just_created_this } = 1;

        $c->res->redirect(
            $c->uri_for( $self->action_for( 'detail' ), [ $loc->barcode ] ) );
    }
}

=head2 location

Chained action to look up a location by barcode and put it in the stash.

=cut

sub location :Chained('/') :CaptureArgs(1) {
    my ( $self, $c, $barcode ) = @_;

    my $loc = $c->model( 'CIDERDB' )->resultset( 'Location' )->find( {
        barcode => $barcode,
    } );

    $c->stash->{ barcode } = $barcode;
    $c->stash->{ location } = $loc;
}

=head2 detail

View and edit a location.

=cut

sub detail :Chained('location') :PathPart('') :Args(0) :FormConfig('location') {
    my ( $self, $c ) = @_;

    my $loc = $c->stash->{ location };
    unless ( defined( $loc ) ) {
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    $c->forward( $c->controller( 'Object' )
                     ->action_for( '_setup_export_templates' ) );

    my $form = $c->stash->{ form };
    $form->get_field( 'submit' )->value( 'Update location' );

    # Add contraint classes to required form fields
    $form->auto_constraint_class('constraint_%t');


    if ( $form->submitted_and_valid ) {
        $form->model->update( $loc );

        $c->flash->{ we_just_updated_this } = 1;

        $c->response->redirect(
            $c->uri_for( $self->action_for( 'detail' ), [ $loc->barcode ] ) );
    }
    elsif ( not $form->submitted ) {
        $form->model->default_values( $loc );
    }
}

=head2 delete

Delete a record context, then redirect to the index page.

=cut

sub delete :Chained( 'location' ) :Args( 0 ) {
    my ( $self, $c ) = @_;

    $c->stash->{ location }->delete;
    $c->response->redirect( $c->uri_for( $self->action_for( 'index' ) ) );
}

=head2 export

Export a location.

=cut

sub export :Chained( 'location' ) :Args( 0 ) {
    my ( $self, $c ) = @_;

    $c->stash->{ locations } = [ $c->stash->{ location } ];

    $c->forward( $self->action_for( '_export' ) );
}

# TO DO: refactor this vs. Object controller

sub _export :Private {
    my ( $self, $c ) = @_;

    my $template_directory = $c->config->{ export }->{ template_directory };

    my $template = $c->req->params->{ template };
    my ( undef, undef, $template_file ) = File::Spec->splitpath( $template );

    unless ( $template eq $template_file ) {
        $c->log->error( "Request to load template '$template', "
                        . "which is not a plain filename. " );
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }

    $template_file = File::Spec->catfile( $template_directory,
                                          $template_file );
    unless ( -f $template_file && -r $template_file ) {
        $c->log->error( "Request to load template '$template_file', but that "
                        . "doesn't look like a template file I can read." );
        $c->detach( $c->controller( 'Root' )->action_for( 'default' ) );
    }
    $c->stash->{ template } = $template_file;

    $c->stash->{ current_view } = 'NoWrapperTT';
}

=head1 AUTHOR

Doug Orleans

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

__PACKAGE__->meta->make_immutable;

1;
