#!/usr/bin/env perl

# Copyright 2023 Theke Solutions
#
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

use Test::More tests => 5;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::HoldPickupShelves;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $hold_pickup_shelf = $builder->build_object( { class => 'Koha::HoldPickupShelves' } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );

    for ( 1 .. 10 ) {
        $builder->build_object( { class => 'Koha::HoldPickupShelves' } );
    }

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $nonprivilegedpatron->userid;

    $t->get_ok("//$userid:$password@/api/v1/holds/pickup_shelves")->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    $t->get_ok("//$userid:$password@/api/v1/holds/pickup_shelves?_per_page=10")->status_is( 200, 'REST3.2.2' );

    my $response_count = scalar @{ $t->tx->res->json };

    is( $response_count, 10, 'The API returns 10 sources' );

    my $id = $hold_pickup_shelf->hold_pickup_shelf_id;
    $t->get_ok("//$userid:$password@/api/v1/holds/pickup_shelves?q={\"hold_pickup_shelf_id\": $id}")->status_is(200)
        ->json_is( '' => [ $hold_pickup_shelf->to_api ], 'REST3.3.2' );

    $hold_pickup_shelf->delete;

    $t->get_ok("//$userid:$password@/api/v1/holds/pickup_shelves?q={\"hold_pickup_shelf_id\": $id}")->status_is(200)
        ->json_is( '' => [] );

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $hold_pickup_shelf = $builder->build_object( { class => 'Koha::HoldPickupShelves' } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $nonprivilegedpatron->userid;

    my $id = $hold_pickup_shelf->hold_pickup_shelf_id;

    $t->get_ok("//$userid:$password@/api/v1/holds/pickup_shelves/$id")->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    $t->get_ok("//$userid:$password@/api/v1/holds/pickup_shelves/$id")->status_is( 200, 'REST3.2.2' )
        ->json_is( '' => $hold_pickup_shelf->to_api, 'REST3.3.2' );

    $hold_pickup_shelf->delete;

    $t->get_ok("//$userid:$password@/api/v1/holds/pickup_shelves/$id")->status_is(404)
        ->json_is( '/error' => 'Record source not found' );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $hold_pickup_shelf = $builder->build_object( { class => 'Koha::HoldPickupShelves' } );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $nonprivilegedpatron->userid;

    my $id = $hold_pickup_shelf->hold_pickup_shelf_id;

    $t->delete_ok("//$userid:$password@/api/v1/holds/pickup_shelves/$id")->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    $hold_pickup_shelf->delete();
    $t->delete_ok("//$userid:$password@/api/v1/holds/pickup_shelves/$id")->status_is( 404, 'REST4.3' )
        ->json_is( { error => q{Record source not found}, error_code => q{not_found} } );

    $hold_pickup_shelf = $builder->build_object( { class => 'Koha::HoldPickupShelves' } );
    $id     = $hold_pickup_shelf->id;

    my $biblio   = $builder->build_sample_biblio();
    my $metadata = $biblio->metadata;
    $metadata->hold_pickup_shelf_id( $hold_pickup_shelf->id )->store();

    $t->delete_ok("//$userid:$password@/api/v1/holds/pickup_shelves/$id")->status_is( 409, 'REST3.2.4.1' );

    $biblio->delete();

    $t->delete_ok("//$userid:$password@/api/v1/holds/pickup_shelves/$id")->status_is( 204, 'REST3.2.4' )
        ->content_is( q{}, 'REST3.3.4' );

    my $deleted_source = Koha::HoldPickupShelves->search( { hold_pickup_shelf_id => $id } );

    is( $deleted_source->count, 0, 'No record source found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 3 }
        }
    );

    my $nonprivilegedpatron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    my $password = 'thePassword123';

    $nonprivilegedpatron->set_password( { password => $password, skip_validation => 1 } );
    my $userid    = $nonprivilegedpatron->userid;
    my $patron_id = $nonprivilegedpatron->borrowernumber;

    $t->post_ok( "//$userid:$password@/api/v1/holds/pickup_shelves" => json => { name => 'test1' } )->status_is(403)
        ->json_is( '/error' => 'Authorization failure. Missing required permission(s).' );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    $userid = $patron->userid;

    my $hold_pickup_shelf_id =
        $t->post_ok( "//$userid:$password@/api/v1/holds/pickup_shelves" => json => { name => 'test1' } )
        ->status_is( 201, 'REST3.2.2' )->json_is( '/name', 'test1' )->json_is( '/can_be_edited', 0 )
        ->tx->res->json->{hold_pickup_shelf_id};

    my $created_source = Koha::HoldPickupShelves->find($hold_pickup_shelf_id);

    is( $created_source->name, 'test1', 'Record source found' );

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {

    plan tests => 15;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**3 }    # parameters flag = 2
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    my $hold_pickup_shelf    = Koha::RecordSource->new( { name => 'old_name' } )->store;
    my $hold_pickup_shelf_id = $hold_pickup_shelf->id;

    # Unauthorized attempt to update
    $t->put_ok( "//$unauth_userid:$password@/api/v1/holds/pickup_shelves/$hold_pickup_shelf_id" => json =>
            { name => 'New unauthorized name change' } )->status_is(403);

    # Attempt partial update on a PUT
    my $hold_pickup_shelf_with_missing_field = {};

    $t->put_ok( "//$userid:$password@/api/v1/holds/pickup_shelves/$hold_pickup_shelf_id" => json => $hold_pickup_shelf_with_missing_field )
        ->status_is(400)->json_is( "/errors" => [ { message => "Missing property.", path => "/body/name" } ] );

    # Full object update on PUT
    my $hold_pickup_shelf_with_updated_field = {
        name => "new_name",
    };

    $t->put_ok( "//$userid:$password@/api/v1/holds/pickup_shelves/$hold_pickup_shelf_id" => json => $hold_pickup_shelf_with_updated_field )
        ->status_is(200)->json_is( '/name' => $hold_pickup_shelf_with_updated_field->{name} );

    # Authorized attempt to write invalid data
    my $hold_pickup_shelf_with_invalid_field = {
        name   => "blah",
        potato => "yeah",
    };

    $t->put_ok( "//$userid:$password@/api/v1/holds/pickup_shelves/$hold_pickup_shelf_id" => json => $hold_pickup_shelf_with_invalid_field )
        ->status_is(400)->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: potato.",
                path    => "/body"
            }
        ]
        );

    my $hold_pickup_shelf_to_delete = $builder->build_object( { class => 'Koha::HoldPickupShelves' } );
    my $non_existent_id  = $hold_pickup_shelf_to_delete->id;
    $hold_pickup_shelf_to_delete->delete;

    $t->put_ok( "//$userid:$password@/api/v1/holds/pickup_shelves/$non_existent_id" => json => $hold_pickup_shelf_with_updated_field )
        ->status_is(404);

    # Wrong method (POST)
    $hold_pickup_shelf_with_updated_field->{hold_pickup_shelf_id} = 2;

    $t->post_ok( "//$userid:$password@/api/v1/holds/pickup_shelves/$hold_pickup_shelf_id" => json => $hold_pickup_shelf_with_updated_field )
        ->status_is(404);

    $schema->storage->txn_rollback;
};
