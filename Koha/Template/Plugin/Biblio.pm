package Koha::Template::Plugin::Biblio;

# Copyright ByWater Solutions 2015

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use DateTime;

use Template::Plugin;
use base qw( Template::Plugin );

use Koha::Holds;
use Koha::Database;
use Koha::Recalls;
use Koha::DateUtils qw( dt_from_string );

# Do not use HoldsCount, it is deprecated and will be removed in a future release.
sub HoldsCount {
    my ( $self, $biblionumber ) = @_;

    warn "HoldsCount is deprecated, you should use biblio.holds.count instead";

    my $holds = Koha::Holds->search( { biblionumber => $biblionumber } );

    return $holds->count();
}

sub ActiveHoldsCount {
    my ( $self, $biblionumber ) = @_;

    my $holds = Koha::Holds->search( { biblionumber => $biblionumber } );
    my $count = 0;
    my $now = dt_from_string;
    while ( my $hold = $holds->next ) {
	$count++ if $hold->is_suspended == 0 and DateTime->compare($now, dt_from_string( $hold->reservedate )) > 0;
    }
    return $count;
}

sub SuspendedHoldsCount {
    my ( $self, $biblionumber ) = @_;

    my $holds = Koha::Holds->search( { biblionumber => $biblionumber } );
    my $count = 0;
    while ( my $hold = $holds->next ) {
	$count++ if $hold->is_suspended == 1;
    }
    return $count;
}

sub UpcomingHoldsCount {
    my ( $self, $biblionumber ) = @_;

    my $holds = Koha::Holds->search( { biblionumber => $biblionumber } );
    my $count = 0;
    my $now = dt_from_string;
    while ( my $hold = $holds->next ) {
	$count++ if DateTime->compare(dt_from_string( $hold->reservedate ), $now) > 0 and $hold->is_suspended == 0;
    }
    return $count;
}

sub ArticleRequestsActiveCount {
    my ( $self, $biblionumber ) = @_;

    my $ar = Koha::ArticleRequests->search(
        {
            biblionumber => $biblionumber
        }
    )->filter_by_current;

    return $ar->count();
}

sub CanArticleRequest {
    my ( $self, $biblionumber, $borrowernumber ) = @_;

    my $biblio = Koha::Biblios->find( $biblionumber );
    my $borrower = Koha::Patrons->find( $borrowernumber );

    return $biblio ? $biblio->can_article_request( $borrower ) : 0;
}

# Do not use RecallsCount, it is deprecated and will be removed in a future release.
sub RecallsCount {
    my ( $self, $biblionumber ) = @_;

    my $recalls = Koha::Recalls->search({ biblio_id => $biblionumber, completed => 0 });

    return $recalls->count;
}

1;
