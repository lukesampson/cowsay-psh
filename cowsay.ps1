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
    Write-Output "Cow files in $($path -replace [regex]::escape($home), "~") `:"
    Get-ChildItem $path -filter "*.cow" |
        Sort-Object name |
        ForEach-Object { "    $($_.name -replace '\.cow$', '')" }
}

function slurp_input($in, $ar) {
    if(!$ar) {
        $in
    } else {
        if($opts.n) { display_usage; exit 1 }
        [string]::join(' ', ($ar | ForEach-Object {
            if($_ -is [array]) { [string]::join(', ', $_ ) }
            else { $_ }
        }) )
    }
}
function maxlength($msg) {
    $l= 0; $m = -1
    $msg | ForEach-Object { 
        $l = $_.length
        if($l -gt $m) { $m = $l }
    }
    return $m
}

function construct_balloon($msg, $think) {
    $balloon_lines = @()
    $thoughts = " "
    if(!$msg) { return $balloon_lines, $thoughts }

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

    $middle = if($msg.length -lt 3) { $null } else {
        $msg[1..($msg.length-2)] | ForEach-Object { [string]::format($format, $border[4], $_, $border[5]) }
    }
    $last = if($msg.length -lt 2) { $null } else {
        [string]::format($format, $border[2], $msg[-1], $border[3])
    }

    $balloon_lines += 
        " $('-'*$max2) ",
        [string]::format($format, $border[0], $msg[0], $border[1])
    
    if($middle) { $balloon_lines += $middle }
    
    $balloon_lines +=
        $last,
        " $('-'*$max2) "

    ($balloon_lines | Where-Object { $_ -ne $null }), $thoughts
}

function get_cow($f, $path, $vars) {
    if(!$f.endsWith('.cow')) { $f += ".cow" }

    $fpath = "$path\$f"
    if(!(test-path $fpath)) { "$script:progname: could not find $f cowfile!"; exit 1 }
    $script = Get-Content -raw $fpath 

    $the_cow = ""
    Invoke-Expression $script
    $the_cow
}

$version = "3.03";
$progname = $myInvocation.myCommand.name
if($myInvocation.pscommandpath) {
    $progname = (split-path $myInvocation.pscommandpath -leaf)
}
$progname = $progname -replace '\.[^\.]+$', ''
$eyes = "oo";
$tongue = "  ";
$cowpath = "$psscriptroot\cows"

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

$message = slurp_input $input $args
if($message -is [string]) {
    $message = $message.split("`n")
}

# todo: wrap

$balloon_lines, $thoughts = construct_balloon $message ($progname -eq 'cowthink')

# construct_face (original sub uses vars from parent scope)
if ($borg) { $eyes = "==" }
if ($dead) { $eyes = "xx"; $tongue = "U " }
if ($greedy) { $eyes = '$$' }
if ($paranoid) { $eyes = "@@" }
if ($stoned) { $eyes = "**"; $tongue = "U " }
if ($tired) { $eyes = "--" } 
if ($wired) { $eyes = "OO" } 
if ($young) { $eyes = ".." }

$the_cow = get_cow $opts.f $cowpath

Write-Output ([string]::join("`n", $balloon_lines))
Write-Output $the_cow
