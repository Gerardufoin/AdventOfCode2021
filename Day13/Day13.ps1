$folds = @()
$folded = New-Object 'System.Collections.Generic.HashSet[String]'
$dots = @()

Function Display-Dots {
	param($dots)
	$width = 0
	$dotLine = @()
	$dots | % {$width = [Math]::Max($width, $_[0])}
	$width++
	$dots | % {$dotLine += $_[0] + $_[1] * $width}
	$i = 0
	$line = ''
	$dotLine | Sort-Object | % {
		while ($i -le $_) {
			if ($i % $width -eq 0) {
				Write-Host $line
				$line = ''
			}
			if ($i -eq $_) {
				$line += '#'
			} else {
				$line += ' '
			}
			$i++
		}
	}
	Write-Host $line
}

Get-Content input.txt | % {
	if ($_ -match '(\d+),(\d+)') {
		$dots += ,@([int]$Matches[1], [int]$Matches[2])
	} elseif ($_ -match 'x=(\d+)') {
		$folds = $folds + ,@('x', [int]$Matches[1])
	} elseif ($_ -match 'y=(\d+)') {
		$folds = $folds + ,@('y', [int]$Matches[1])
	}
}
$part1 = 0
$folds | % {
	$f = $_
	$newDots = @()
	$dots | % {
		if ($f[0] -eq 'x' -and $_[0] -ge $f[1]) {
			$_[0] -= ($_[0] - $f[1]) * 2
		} elseif ($f[0] -eq 'y' -and $_[1] -ge $f[1]) {
			$_[1] -= ($_[1] - $f[1]) * 2
		}
		if ($folded.Add("$_")) {
			$newDots += ,$_
		}
	}
	if ($part1 -eq 0) {
		$part1 = $folded.Count
	}
	$dots = $newDots
	$folded.Clear()
}
$part1
Display-Dots $dots