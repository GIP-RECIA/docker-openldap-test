BEGIN {
    RS = ""
    FS = "\n"
    count = 0
}
{
    has_uai = 0
    has_sacoche = 0
    has_given_name = 0

    for (i = 1; i <= NF; i++) {
        if ($i == "ESCOUAI: " uai) has_uai = 1
        if ($i ~ /^ESCOPersonExternalIds: SACOCHE\$/) has_sacoche = 1
        if ($i ~ /^givenName:/) has_given_name = 1
    }

    if (has_uai && !has_sacoche && has_given_name) {
        "uuidgen" | getline new_uuid
        close("uuidgen")

        for (i = 1; i <= NF; i++) {
            print $i
            if ($i ~ /^givenName:/) {
                print "ESCOPersonExternalIds: SACOCHE$" new_uuid
            }
        }
        count++
    } else {
        for (i = 1; i <= NF; i++) {
            print $i
        }
    }

    print ""
}
END {
    printf "Added SACOCHE external id to %d entries for UAI %s\n", count, uai > "/dev/stderr"
}