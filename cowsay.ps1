##
## Cowsay 3.03
##
## Original cowsay (c) 1999-2000 Tony Monroe.
## http://www.nog.net/~tony/warez/cowsay-3.03.tar.gz
##
## Powershell port by Luke Sampson 2013
##

. "$psscriptroot\lib\opts.ps1"

function display_usage {
    "
cow{say,think} version $version, (c) 1999 Tony Monroe
Usage: $progname [-bdgpstwy] [-h] [-e eyes] [-f cowfile] 
          [-l] [-n] [-T tongue] [-W wrapcolumn] [message]
    "
}

function list_cowfiles($path) {
    echo "Cow files in $($path -replace [regex]::escape($home), "~") `:"
    gci $path -filter "*.cow" |
        sort name |
        % { "    $($_.name -replace '\.cow$', '')" }
}

function slurp_input($in, $ar) {
    if(!$ar) {
        $in
    } else {
        if($opts.n) { display_usage; exit 1 }
        [string]::join(' ', ($ar | % {
            if($_ -is [array]) { [string]::join(', ', $_ ) }
            else { $_ }
        }) )
    }
}
function maxlength($msg) {
    $l, $m = -1
    $msg | % { 
        $l = $_.length
        if($l -gt $m) { $m = $l }
    }
    return $m
}

function construct_balloon($msg, $think) {
    $balloon_lines = @()
    $thoughts = ""

    $max = maxlength $msg
    $max2 = $max + 2 # border space fudge
    $format = "{0} {1,-$max} {2}"
    $border = @() # up-left, up-right, down-left, down-right, left, right
    if($think) {
        $thoughts = 'o'
        $border = '()()()'.tochararray()
    } elseif ($msg.length -lt 2) {
        $thoughts = '\'
        $border = '<>'.tochararray()
    } else {
        $thoughts = '\'
        $border = '/\\/||'.tochararray()
    }

    $middle, $last = if($msg.length -lt 2) { $null, $null } else {
        $msg[1..($msg.length-2)] | % { [string]::format($format, $border[4], $_, $border[5]) }
        [string]::format($format, $border[2], $msg[-1], $border[3])
    }

    $balloon_lines += 
        " $('-'*$max2) ",
        [string]::format($format, $border[0], $msg[0], $border[1]),
        $middle,
        $last,
        " $('-'*$max2) "

    ($balloon_lines | ? { $_ -ne $null }), $thoughts
}

$version = "3.03";
$progname = $myInvocation.myCommand.name -replace '\.[^\.]+$', ''
$eyes = "oo";
$tongue = "  ";
$cowpath = "$psscriptroot\cows"
$message = @();
$thoughts = "";

$opts = @{
    'e'     =  'oo'
    'f'     =  'default.cow'
    'n'     =  0
    'T'     =  '  '
    'W'     =  40
}

try {
    $opts, $args = getopts $args 'bde:f:ghlLnNpstT:wW:y' $opts
} catch {
    "$progname`: $_"; display_usage; exit 1;
}

if($opts.h) { display_usage; exit 0 }
if($opts.l) { list_cowfiles $cowpath; exit 0 }

$borg = $opts.b
$dead = $opts.d
$greedy = $opts.g
$paranoid = $opts.p
$stoned = $opts.s
$tired = $opts.t
$wired = $opts.w
$young = $opts.y
$eyes = $opts.e.substring(0, 2)
$tongue = $opts.T.substring(0, 2)
$the_cow = "";

$message = @(slurp_input $input $args)

# todo: ensure message is array of strings, wrapped as required
#       use format-list?

$balloon_lines, $thoughts = construct_balloon $message

echo ([string]::join("`n", $balloon_lines))
