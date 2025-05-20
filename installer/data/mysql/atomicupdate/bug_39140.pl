use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39140",
    description => "Add a feature to define hold pickup shelves",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
            ('HoldPickupShelves','0','0=No|1=Yes','Define hold pickup shelves', 'YesNo')
        });

        say_success( $out, "Added new system preference 'HoldPickupShelves'");

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
            ('HoldPickupShelvesBiblioLevelItemTypeParameter','','','URL for biblio level item type API fetch', 'FreeText')
        });

        say_success( $out, "Added new system preference 'HoldPickupShelvesBiblioLevelItemTypeParameter'");

        unless ( TableExists('hold_pickup_shelves') ) {
            $dbh->do(q{
                CREATE TABLE hold_pickup_shelves (
                    hold_pickup_shelf_id INT AUTO_INCREMENT PRIMARY KEY,
                    library_id VARCHAR(10) NOT NULL,
                    shelf_name VARCHAR(100) NOT NULL,
                    max_items INT NOT NULL,
                    UNIQUE KEY (library_id, shelf_name),
                    FOREIGN KEY (library_id) REFERENCES branches(branchcode) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });

            say_success( $out, "Added new table 'hold_pickup_shelves'" );
        }

        if ( !column_exists( 'reserves', 'hold_pickup_shelf_id' ) ) {
            $dbh->do(q{
                ALTER TABLE reserves
                ADD COLUMN hold_pickup_shelf_id INT,
                ADD FOREIGN KEY (hold_pickup_shelf_id) REFERENCES hold_pickup_shelves(hold_pickup_shelf_id)
            });

            say_success( $out, "Added column 'reserves.hold_pickup_shelf_id'" );
        }
        if ( !column_exists( 'old_reserves', 'hold_pickup_shelf_id' ) ) {
            $dbh->do(q{
                ALTER TABLE old_reserves
                ADD COLUMN hold_pickup_shelf_id INT,
                ADD FOREIGN KEY (hold_pickup_shelf_id) REFERENCES hold_pickup_shelves(hold_pickup_shelf_id)
            });

            say_success( $out, "Added column 'old_reserves.hold_pickup_shelf_id'" );
        }

        if (!column_exists( 'hold_pickup_shelves', 'overflow_shelf' ) ) {
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                ADD COLUMN overflow_shelf TINYINT(1) DEFAULT 0
            });

            say_success( $out, "Added column 'hold_pickup_shelves.overflow_shelf'" );
        }
        if (!column_exists( 'hold_pickup_shelves', 'locked' ) ) {
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                ADD COLUMN locked TINYINT(1) DEFAULT 0
            });

            say_success( $out, "Added column 'hold_pickup_shelves.locked'" );
        }
        if (!column_exists( 'hold_pickup_shelves', 'locked_date' ) ) {
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                ADD COLUMN locked_date DATETIME DEFAULT NULL
            });

            say_success( $out, "Added column 'hold_pickup_shelves.locked_date'" );
        }
        if (!column_exists( 'hold_pickup_shelves', 'biblio_itemtype' ) ) {
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                ADD COLUMN biblio_itemtype VARCHAR(10) DEFAULT NULL
            });

            say_success( $out, "Added column 'hold_pickup_shelves.biblio_itemtype'" );
        }
        if (!column_exists( 'hold_pickup_shelves', 'patron_category_id' ) ) {
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                ADD COLUMN patron_category_id VARCHAR(10) DEFAULT NULL
            });

            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                ADD FOREIGN KEY (patron_category_id) REFERENCES categories(categorycode) ON DELETE CASCADE
            });

            say_success( $out, "Added column 'hold_pickup_shelves.patron_category_id'" );
        }
        if (!column_exists( 'hold_pickup_shelves', 'weekday' ) ) {
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                ADD COLUMN weekday ENUM ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') DEFAULT NULL
            });

            say_success( $out, "Added column 'hold_pickup_shelves.weekday'" );
        }

        if (!unique_key_exists('hold_pickup_shelves','hold_pickup_shelves_uniq_idx')) {
            # Remove the old index
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                DROP FOREIGN KEY hold_pickup_shelves_ibfk_1
            });
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                DROP INDEX library_id
            });
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                ADD FOREIGN KEY `hold_pickup_shelves_ibfk_1` (library_id) REFERENCES branches(branchcode) ON DELETE CASCADE
            });
            # Add the new index
            $dbh->do(q{
                ALTER TABLE hold_pickup_shelves
                ADD UNIQUE KEY `hold_pickup_shelves_uniq_idx` (library_id, shelf_name, biblio_itemtype, patron_category_id, weekday)
            });
            say_success( $out, "Added unique index to 'hold_pickup_shelves'" );
        }

    },
};
