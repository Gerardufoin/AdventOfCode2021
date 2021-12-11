$SIZE = 10
$ROUNDS = 100

Function Debug-ShowGrid {
	param(
		$grid
	)
	$line = ''
	for ($i = 0; $i -lt $grid.Count; ++$i) {
		if ($i % 10 -eq 0) {
			Write-Host $line
			$line = ''
		}
		if ($grid[$i][0] -gt 9) {
			$line += '*'
		} else {
			$line += $grid[$i][0]
		}
	}
	Write-Host $line
}

$part1 = $part2 = $count = 0
$octo = @()
Get-Content input.txt | % {
	$_ -Split '' | % {
		if ($_ -Match '\d') {
			$octo += ,@([int]$_, 0)
		}
	}
}
$flashes = New-Object -TypeName "System.Collections.Queue"
$i = 1
while ($part2 -eq 0 -or $i -le $ROUNDS) {
	for ($j = 0; $j -lt $octo.Count; $j++) {
		$octo[$j][0] += 1
		if ($octo[$j][0] -gt 9) {
			$octo[$j][1] = $i
			$flashes.Enqueue($j)
		}
	}
	$tmpCount = $count
	while ($flashes.Count -gt 0) {
		$count += 1
		$pos = $flashes.Dequeue()
		$octo[$pos][0] = 0
		for ($step = 0; $step -lt 9; $step++) {
			$checkP = $pos + ([math]::floor($step / 3) - 1) * $SIZE + ($step % 3 - 1)
			if ($checkP -ge 0 -and $checkP -lt $octo.Count -and $octo[$checkP][1] -lt $i -and !($step % 3 -eq 0 -and $pos % $SIZE -eq 0) -and !($step % 3 -eq 2 -and $pos % $SIZE -eq $SIZE - 1)) {
				$octo[$checkP][0] += 1
				if ($octo[$checkP][0] -gt 9) {
					$octo[$checkP][1] = $i
					$flashes.Enqueue($checkP)
				}
			}
		}
	}
	if ($i -eq $ROUNDS) {
		$part1 = $count
	}
	if ($count - $octo.Count -eq $tmpCount) {
		$part2 = $i
	}
	$i++
}
$part1
$part2