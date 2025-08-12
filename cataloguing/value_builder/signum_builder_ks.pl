#!/usr/bin/perl

use Modern::Perl;

my $builder = sub {
    my ($params) = @_;
    my $function_name = $params->{id};

    my $js = <<ENDJS;
<script type="text/javascript">
//<![CDATA[

function Click$function_name(event) {
    var bn = \$('input[name="biblionumber"]').val();
    \$('#' + event.data.id).prop('disabled', true);
    if (!bn) return false;

    var url = '../cataloguing/plugin_launcher.pl?plugin_name=fi_JSON_084a_signum_builder_subfields.pl&biblionumber=' + bn;
    var req = \$.get(url);

    req.fail(function(jqxhr, text, error){
        alert(error);
        \$('#' + event.data.id).prop('disabled', false);
    });

    req.done(function(resp){
        // Luokka kentästä 084\$a
        var marc084a = resp.f084a ? resp.f084a : "";

        // Pääsana: tarkista kentät järjestyksessä
        var mainHeading = "";
        if (resp.f942m) {
            mainHeading = resp.f942m;
        } else if (resp.f100a) {
            mainHeading = resp.f100a;
        } else if (resp.f110a) {
            mainHeading = resp.f110a;
        } else if (resp.f111a) {
            mainHeading = resp.f111a;
        } else if (resp.f245a) {
            // 2. indikaattori kertoo ohitettavien merkkien määrän
            var skip = parseInt(resp.f245ind2) || 0;
            mainHeading = resp.f245a.substring(skip);
        } else if (resp.f130a) {
            // 1. indikaattori kertoo ohitettavien merkkien määrän
            var skip = parseInt(resp.f130ind1) || 0;
            mainHeading = resp.f130a.substring(skip);
        }

        // Ota pääsanasta vain ensimmäiset 3 merkkiä, huomioi mahdolliset välilyönnit
        mainHeading = mainHeading.trim().substring(0, 3);

        // Kirjoita pääsana isoilla kirjaimilla
        mainHeading = mainHeading.toUpperCase();

        // Jos pääsana alkaa numerolla, ota numero ja seuraava sana (esim. "3 pientä autoa" -> "3 p")
        var match = mainHeading.match(/^(\d+)\s*(\S)?/);
        if (match) {
            mainHeading = match[1] + (match[2] ? " " + match[2] : "");
        }

        // Muodosta signum: luokka + pääsana
        var signum = marc084a + " " + mainHeading;

        \$('#' + event.data.id).val(signum.trim());
        \$('#' + event.data.id).prop('disabled', false);
    });

    return false;
}

//]]>
</script>
ENDJS

    return $js;
};

return { builder => $builder };