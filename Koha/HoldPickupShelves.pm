package Koha::HoldPickupShelves;

# This file is part of Koha.
#
# Copyright 2025 Koha-Suomi Oy
#
# Koha is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General
# Public License along with Koha; if not, see
# <http://www.gnu.org/licenses>

use Modern::Perl;

use base qw(Koha::Objects);

use Koha::HoldPickupShelf;

=head1 NAME

Koha::HoldPickupShelves - Koha HoldPickupShelves Object class

=head1 API

=head2 Public methods

=head3 available_shelves
Returns the list of shelves for a given library.
=cut
sub available_shelves {
    my ($self, $library_id, $biblio_id, $patron_id) = @_;

    $self->open_locked_shelves($library_id);

    my $primary_shelves = $self->primary_shelves($library_id, $biblio_id, $patron_id);
    return $primary_shelves if @$primary_shelves;

    my $overflow_shelves = $self->overflow_shelves($library_id, $biblio_id, $patron_id);
    return $overflow_shelves if @$overflow_shelves;

    return [];
}


=head3 primary_shelves
Returns the list of primary shelves for a given library.
=cut

sub primary_shelves {
    my ($self, $library_id, $biblio_id, $patron_id) = @_;
    my $shelves = $self->search(
        { library_id => $library_id, overflow_shelf => 0, locked => 0 },
        { order_by => { -asc => 'priority' } }
    )->as_list;
    my $response = [];
    for my $shelf (@$shelves) {
        if ($shelf->available_shelf($biblio_id, $patron_id)) {
            push @{$response}, $shelf;
        }
    }
    

    return $response;
}

=head3 overflow_shelves
Returns the list of overflow shelves for a given library.
=cut
sub overflow_shelves {
    my ($self, $library_id, $biblio_id, $patron_id) = @_;
    my $shelves = $self->search(
        { library_id => $library_id, overflow_shelf => 1, locked => 0 },
        { order_by => { -asc => 'priority' } }
    )->as_list;
    my $response = [];
    for my $shelf (@$shelves) {
        if ($shelf->available_shelf($biblio_id, $patron_id)) {
            push @{$response}, $shelf;
        }
    }
    return $response;
}

=head3 open_locked_shelves
Opens all locked shelves for a given library.
This method is used to unlock shelves that are not locked today.
=cut
sub open_locked_shelves {
    my ($self, $library_id) = @_;
    my $today = DateTime->today->ymd;
    my $shelves = $self->search({library_id => $library_id, locked => 1, locked_date => { '<' => $today }})->as_list;
    for my $shelf (@$shelves) {
        $shelf->update({locked => 0, locked_date => undef});
    }
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'HoldPickupShelve';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::HoldPickupShelf';
}

1;
