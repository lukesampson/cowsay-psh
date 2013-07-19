# returns ($opts, $remaining_args)
function getopts($a, $str, $defaults) {
    # make a case-sensitive hash, put defaults in there
    $opts = new-object collections.hashtable
    if($defaults) { $defaults.keys | % { $opts[$_] = $defaults[$_] } }

    $flags = @()  # boolean switches
    $aflags = @() # flags with arguments

    # parse $str to get flags
    $str | sls '.:?' -all | % {
        $_.matches | % {
            $f = $_.value
            if($f.endsWith(':')) { $aflags += $f[0] }
            else { $flags += $f }
        }
    }

    # parse arguments from $a
    $i = 0;
    for(; $i -lt $a.length; $i++) {
        $arg = $a[$i]
        if($arg -is [array]) { $arg = [string]::join(', ', $arg)}
        if($arg.startsWith('-')) {
            $flag = $arg[1]
            if(($aflags -ccontains $flag)) {
                # flag with an argument
                if($arg.length -eq 2) { # argument after space
                    if($i -eq $a.length - 1) {
                        throw "$flag requires an argument"
                    }
                    $opts[[string]$arg[1]] = [string]$a[++$i]
                } else { # argument follows immediately (no space)
                    $opts[[string]$arg[1]] = $arg.substring(2, ($arg.length-2))
                }
            } elseif($flags -ccontains $flag) {
                # boolean switches (may be grouped together e.g. -amc)
                $opts[[string]$flag] = $true
                for($j = 2; $j -lt $arg.length; $j++) {
                    $flag = $arg[$j]
                    if($flags -ccontains $flag) { $opts[[string]$flag] = $true }
                    else {
                        throw "illegal option -- $flag"
                    }
                }
            } else {
                throw "illegal option $($arg[1..($arg.length - 1)])"
            }
        } else {
            # everything after first non-flag will be returned 
            break
        }
    }

    $rem = @()
    if($i -lt $a.length) {
        $rem = $a[$i..($a.length-1)]
    }

    $opts, $rem
}