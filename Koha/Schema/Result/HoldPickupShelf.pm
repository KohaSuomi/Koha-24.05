use utf8;
package Koha::Schema::Result::HoldPickupShelf;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Koha::Schema::Result::HoldPickupShelve

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<hold_pickup_shelves>

=cut

__PACKAGE__->table("hold_pickup_shelves");

=head1 ACCESSORS

=head2 hold_pickup_shelf_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 library_id

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

=head2 shelf_name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 items_limit

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "hold_pickup_shelf_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "library_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "shelf_name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "items_limit",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</hold_pickup_shelf_id>

=back

=cut

__PACKAGE__->set_primary_key("hold_pickup_shelf_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<library_id>

=over 4

=item * L</library_id>

=item * L</shelf_name>

=back

=cut

__PACKAGE__->add_unique_constraint("library_id", ["library_id", "shelf_name"]);

=head1 RELATIONS

=head2 library

Type: belongs_to

Related object: L<Koha::Schema::Result::Branch>

=cut

__PACKAGE__->belongs_to(
  "library",
  "Koha::Schema::Result::Branch",
  { branchcode => "library_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 reserves

Type: has_many

Related object: L<Koha::Schema::Result::Reserve>

=cut

__PACKAGE__->has_many(
  "reserves",
  "Koha::Schema::Result::Reserve",
  { "foreign.hold_pickup_shelf_id" => "self.hold_pickup_shelf_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-03-13 09:20:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ren2j1Peg/q3KXZ/6H5CRQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
