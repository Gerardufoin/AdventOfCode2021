#Used A*. No honor here. https://en.wikipedia.org/wiki/A*_search_algorithm
#PriorityQueue needs Powershell 7+
#Even with A*, I did not manage to find out why powershell is so slow at P2...
$map = @{}
$size = 0

function Solve-Map {
	param(
		$map,
		$size,
		$sizeMult
	)
	foreach ($key in $map.Keys) {
		$map.$key.gScore = [double]::PositiveInfinity
		$map.$key.fScore = [double]::PositiveInfinity
		$map.$key.cameFrom = ''
	}
	
	$toCheck = New-Object 'System.Collections.Generic.PriorityQueue[String, Double]'
	$checked = New-Object 'System.Collections.Generic.HashSet[String]'
	$start = $end = "0 0"

	$baseSize = $size
	$size *= $sizeMult
	$end = "$($size - 1) $($size - 1)"
	$map[$start].gscore = 0
	$map[$start].fScore = $size * 2 - 1

	[void]($checked.Add($start))
	$toCheck.Enqueue($start, $map[$start].fScore)
	while ($toCheck.Count -gt 0) {
		$key = $toCheck.Dequeue()
		[void]($checked.Remove($key))
		if ($key -eq $end) {
			break
		}
		#Check neighbors
		for ($i = 0; $i -lt 4; $i++) {
			$x = $map.$key.x + $i % 2 * (($i - 2) % 2)
			$y = $map.$key.y + ($i + 1) % 2 * (($i - 1) % 2)
			if ($x -ge 0 -and $x -lt $size -and $y -ge 0 -and $y -lt $size) {
				$keyN = "$x $y"
				if ($x -ge $baseSize -or $y -ge $baseSize -and !($map.Keys -Contains $keyN)) {
					$map.Add($keyN, @{'weight' = ($map["$($x % $baseSize) $($y % $baseSize)"].weight + ([Math]::Floor($x / $baseSize) + [Math]::Floor($y / $baseSize)) - 1) % 9 + 1; 'x' = $x; 'y' = $y; 'gScore' = [double]::PositiveInfinity; 'fScore' = [double]::PositiveInfinity; 'cameFrom' = ''})
				}
				$score = $map.$key.gScore + $map.$keyN.weight
				if ($score -lt $map.$keyN.gScore) {
					$map.$keyN.cameFrom = $key
					$map.$keyN.gScore = $score
					$map.$keyN.fScore = $score + $size - 1 - $map.$keyN.x + $size - 1 - $map.$keyN.y
					if ($checked.Add($keyN)) {
						$toCheck.Enqueue($keyN, $map.$keyN.fScore)
					}
				}
			}
		}
	}
	$result = 0
	$key = $end
	while ($key -ne $start) {
		$result += $map.$key.weight
		$key = $map.$key.cameFrom
	}
	$result
}

$y = 0
Get-Content example.txt | % {
	$x = 0
	if ($size -eq 0) {
		$size = $_.Length
	}
	$_ -Split '' | % {
		if ($_ -Match '\d') {
			$map.Add("$x $y", @{'weight' = [int]$Matches[0]; 'x' = $x; 'y' = $y; 'gScore' = [double]::PositiveInfinity; 'fScore' = [double]::PositiveInfinity; 'cameFrom' = ''})
			$x++
		}
	}
	$y++
}
Solve-Map $map $size 1
Solve-Map $map $size 5