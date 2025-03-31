use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39140",
    description => "Add a feature to define hold pickup shelves",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT INTO systempreferences (variable,value,options,explanation,type) VALUES
            ('HoldPickupShelves','0','0=No|1=Yes','Define hold pickup shelves', 'YesNo')
        });

        say_success( $out, "Added new system preference 'HoldPickupShelves'");

        unless ( TableExists('hold_pickup_shelves') ) {
            $dbh->do(q{
                CREATE TABLE hold_pickup_shelves (
                    hold_pickup_shelf_id INT AUTO_INCREMENT PRIMARY KEY,
                    library_id VARCHAR(10) NOT NULL,
                    shelf_name VARCHAR(100) NOT NULL,
                    max_limit INT NOT NULL,
                    UNIQUE KEY (library_id, shelf_name),
                    FOREIGN KEY (library_id) REFERENCES branches(branchcode) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });

            say_success( $out, "Added new table 'hold_pickup_shelves'" );
        }

        $dbh->do(q{
            ALTER TABLE reserves
            ADD COLUMN hold_pickup_shelf_id INT,
            ADD FOREIGN KEY (hold_pickup_shelf_id) REFERENCES hold_pickup_shelves(hold_pickup_shelf_id)
        });

        say_success( $out, "Added column 'reserves.hold_pickup_shelf_id'" );

        $dbh->do(q{
            ALTER TABLE old_reserves
            ADD COLUMN hold_pickup_shelf_id INT,
            ADD FOREIGN KEY (hold_pickup_shelf_id) REFERENCES hold_pickup_shelves(hold_pickup_shelf_id)
        });

        say_success( $out, "Added column 'old_reserves.hold_pickup_shelf_id'" );

    },
};
