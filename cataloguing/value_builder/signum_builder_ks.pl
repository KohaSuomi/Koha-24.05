#!/usr/bin/perl

use Modern::Perl;
use utf8;

my $builder = sub {
    my ($params) = @_;
    my $function_name = $params->{id};

    my $js = <<ENDJS;
<script type="text/javascript">
//<![CDATA[
    var bn = \$('input[name="biblionumber"]').val();
    if  (!bn) {
            var infoElem = \$('<span id="signum_warning" style="color:red; margin-left:10px; margin-right:10px;" data-toggle="tooltip" data-delay="0" data-trigger="hover" data-placement="right" title="Jotta signumin generointi toimii, pitää niteet tuoda erämuokkaukseen tietueen Perustiedot-näytön Muokkaa valittuja niteitä -toiminnolla."><i class="fa fa-info-circle fa-2" aria-hidden="true"></i> Signumin luonti ei onnistu </span>');
            \$('#' + '$function_name').after(infoElem);
        }


function Click$function_name(event) {

    var bn = \$('input[name="biblionumber"]').val();
    \$('#' + event.data.id).prop('disabled', true);
    if (!bn) {
        alert("Signum builder: Biblionumber not available");
        \$('#' + event.data.id).prop('disabled', false);
        return false;
    }

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

        // Jos pääsana alkaa numerolla, ota numero ja seuraava sana (esim. "3 pientä autoa" -> "3 p")
        var match = mainHeading.match(/^(\d+)\s*(\S)?/);
        if (match) {
            mainHeading = match[1] + (match[2] ? " " + match[2] : "");
        }

        // Kirjoita pääsana isoilla kirjaimilla
        mainHeading = mainHeading.toUpperCase();

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