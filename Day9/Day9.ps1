$map = @{}
$y = 0
Get-Content input.txt | % {
	$x = 0
	$_ -Split '' | % {
		if ($_ -match '\d') {
			$map.Add("$x $y", [int]$_)
			$v = $map["$x $y"]
			$x++
		}
	}
	$y++
}
$part1 = 0
$part2 = 1
$bassins = @()
for ($i = 0; $i -lt $y; $i++) {
	for ($j = 0; $j -lt $x; $j++) {
		$v = $map["$j $i"]
		if (($i -eq 0 -or $map["$j $($i - 1)"] -gt $v) -and
			($j -eq 0 -or $map["$($j - 1) $i"] -gt $v) -and
			($i -eq $y - 1 -or $map["$j $($i + 1)"] -gt $v) -and
			($j -eq $x - 1 -or $map["$($j + 1) $i"] -gt $v)) {
			$part1 += $v + 1
			
			$size = 0
			$toCheck = New-Object -TypeName "System.Collections.Queue"
			$toCheck.Enqueue(@($j,$i))
			$checked = @("$j $i")
			while ($toCheck.Count -gt 0) {
				$tile = $toCheck.Dequeue()
				$val = $map["$tile"]
				if ($val -eq 9) {
					continue;
				}
				$size++
				$testTile = @(($tile[0] - 1), $tile[1])
				if ($testTile[0] -ge 0 -and $map["$testTile"] -ge $val -and !($checked -Contains "$testTile")) {
					$toCheck.Enqueue($testTile)
					$checked += "$testTile"
				}
				$testTile = @($tile[0], ($tile[1] - 1))
				if ($testTile[1] -ge 0 -and $map["$testTile"] -ge $val -and !($checked -Contains "$testTile")) {
					$toCheck.Enqueue($testTile)
					$checked += "$testTile"
				}
				$testTile = @(($tile[0] + 1), $tile[1])
				if ($testTile[0] -lt $x -and $map["$testTile"] -ge $val -and !($checked -Contains "$testTile")) {
					$toCheck.Enqueue($testTile)
					$checked += "$testTile"
				}
				$testTile = @($tile[0], ($tile[1] + 1))
				if ($testTile[1] -lt $y -and $map["$testTile"] -ge $val -and !($checked -Contains "$testTile")) {
					$toCheck.Enqueue($testTile)
					$checked += "$testTile"
				}
			}
			$bassins += $size
		}
	}
}
$bassins | Sort-Object | Select -Last 3 | % { $part2 *= $_ }
$part1
$part2