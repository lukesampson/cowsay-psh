$cowsay = "$psscriptroot\cowsay.ps1"
if($myinvocation.expectingInput) { $input | & $cowsay @args } else { & $cowsay @args }