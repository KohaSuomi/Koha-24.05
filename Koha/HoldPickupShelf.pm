package Koha::HoldPickupShelf;

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

use base qw(Koha::Object);
use Koha::Library;

=head1 NAME

Koha::HoldPickupShelf - Koha HoldPickupShelf Object class

=head1 API

=head3 library

Returns the related library object.

=cut

sub library {
    my ($self) = @_;
    my $rs = $self->_result->library;
    return Koha::Library->_new_from_dbic($rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'HoldPickupShelf';
}

1;
