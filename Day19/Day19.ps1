$scanners = @{}
$magnMapping = @{}
$overlappingAreas = @{}
$current = 0

$scannerRot1 = @{
	0 = {param($coord) return @($coord[0], $coord[1], $coord[2])}
	1 = {param($coord) return @($coord[0], $coord[2], $coord[1])}	
	2 = {param($coord) return @($coord[1], $coord[0], $coord[2])}
	3 = {param($coord) return @($coord[1], $coord[2], $coord[0])}
	4 = {param($coord) return @($coord[2], $coord[0], $coord[1])}
	5 = {param($coord) return @($coord[2], $coord[1], $coord[0])}
}
$scannerRot2 = @{
	0 = {param($coord) return @($coord[0], $coord[1], $coord[2])}
	1 = {param($coord) return @(-$coord[0], $coord[1], $coord[2])}
	2 = {param($coord) return @($coord[0], -$coord[1], $coord[2])}
	3 = {param($coord) return @($coord[0], $coord[1], -$coord[2])}
	4 = {param($coord) return @(-$coord[0], -$coord[1], $coord[2])}
	5 = {param($coord) return @($coord[0], -$coord[1], -$coord[2])}
	6 = {param($coord) return @(-$coord[0], $coord[1], -$coord[2])}
	7 = {param($coord) return @(-$coord[0], -$coord[1], -$coord[2])}
}

Get-Content input.txt | % {
	if ($_ -Match 'scanner (\d+)') {
		$current = [int]$Matches[1]
		$scanners.Add($current, @())
	} elseif ($_ -Match '(-?\d+),(-?\d+),(-?\d+)') {
		$scanners[$current] += ,@([int]$Matches[1], [int]$Matches[2], [int]$Matches[3])
	}
}

foreach ($k in $scanners.Keys) {
	$magnMapping.Add($k, @{})
	for ($i = 0; $i -lt $scanners.$k.Count - 1; $i++) {
		for ($j = $i + 1; $j -lt $scanners.$k.Count; $j++) {
			# We use the magnitude between beacons as they will be the same no matter their orientation. As we are comparing magnitudes with each others, the square root is not necessary
			$magnMapping.$k.Add("$i-$j", ([Math]::pow(($scanners.$k[$i][0] - $scanners.$k[$j][0]), 2) + [Math]::pow(($scanners.$k[$i][1] - $scanners.$k[$j][1]), 2) + [Math]::pow(($scanners.$k[$i][2] - $scanners.$k[$j][2]), 2)))
		}
	}
}

function Test-UniqueVectorCoord {
	param(
		$coordA,
		$coordB
	)
	$x = [Math]::Abs($coordA[0] - $coordB[0])
	$y = [Math]::Abs($coordA[1] - $coordB[1])
	$z = [Math]::Abs($coordA[2] - $coordB[2])
	return ($x -eq $y -or $x -eq $z -or $y -eq $z)
}

# Overlapping areas have 12 similar beacons so exactly 66 common magnitudes (12-1)!. Can be greater if there are similar magnitudes
for ($i = 0; $i -lt $magnMapping.Keys.Count - 1; $i++) {
	for ($j = $i + 1; $j -lt $magnMapping.Keys.Count; $j++) {
		$cnt = 0
		$mappedMagn = @{}
		foreach ($k1 in $magnMapping[$i].Keys) {
			foreach ($k2 in $magnMapping[$j].Keys) {
				if ($magnMapping[$i][$k1] -eq $magnMapping[$j][$k2]) {
					$magn = $magnMapping[$i][$k1]
					if ($mappedMagn.ContainsKey($magn)) {
						# Duplicate can't be used to detect scanners orientation
						$mappedMagn[$magn] = $null
					} else {
						$mappedMagn.Add($magn, @(($k1 -Split '-' | % {[int]$_}), ($k2 -Split '-' | % {[int]$_})))
					}
					$cnt++
				}
			}
		}
		if ($cnt -ge 66) {
			$refCoords = $null
			foreach ($k in $mappedMagn.Keys) {
				if ($mappedMagn.$k -eq $null) {
					continue
				}
				if ($refCoords -eq $null) {
					# Can't have a vector with 2 similar values ([1 2 1] for example)
					if (!(Test-UniqueVectorCoord $scanners[$i][$mappedMagn.$k[0][0]] $scanners[$i][$mappedMagn.$k[0][1]])) {
						$refCoords = $mappedMagn.$k
					}
				} else {
					$comp = $mappedMagn.$k
					if ($comp[0] -Contains $refCoords[0][0]) {
						if (!($comp[1] -Contains $refCoords[1][0])) {
							$tmp = $refCoords[1][0]
							$refCoords[1][0] = $refCoords[1][1]
							$refCoords[1][1] = $tmp
						}
						break
					} elseif ($comp[0] -Contains $refCoords[0][1]) {
						if (!($comp[1] -Contains $refCoords[1][1])) {
							$tmp = $refCoords[1][0]
							$refCoords[1][0] = $refCoords[1][1]
							$refCoords[1][1] = $tmp
						}
						break
					}
				}
			}
			if (!($overlappingAreas.Keys -Contains $i)) {
				$overlappingAreas.Add($i, @{})
			}
			if (!($overlappingAreas.Keys -Contains $j)) {
				$overlappingAreas.Add($j, @{})
			}
			$overlappingAreas[$i].Add($j, $refCoords)
			$overlappingAreas[$j].Add($i, @($refCoords[1], $refCoords[0]))
		}
	}
}

function Find-Orientation {
	param(
		$coordA1,
		$coordB1,
		$coordA2,
		$coordB2
	)
	$vec1 = @(($coordA1[0] - $coordB1[0]), ($coordA1[1] - $coordB1[1]), ($coordA1[2] - $coordB1[2]))
	$vec2 = @(($coordA2[0] - $coordB2[0]), ($coordA2[1] - $coordB2[1]), ($coordA2[2] - $coordB2[2]))
	for ($i = 0; $i -lt $scannerRot1.Count; $i++) {
		$testR1 = $scannerRot1[$i].Invoke((,$vec2))
		for ($j = 0; $j -lt $scannerRot2.Count; $j++) {
			$testR2 = $scannerRot2[$j].Invoke((,$testR1))
			if ($vec1[0] -eq $testR2[0] -and $vec1[1] -eq $testR2[1] -and $vec1[2] -eq $testR2[2]) {
				$coordA2 = $scannerRot1[$i].Invoke((,$coordA2))
				$coordA2 = $scannerRot2[$j].Invoke((,$coordA2))
				return @(@(($coordA2[0] - $coordA1[0]), ($coordA2[1] - $coordA1[1]), ($coordA2[2] - $coordA1[2])), $i, $j)
			}
		}
	}
	throw "Unable to find rotation. You failed, matey."
}

$uniqueCoords = New-Object 'System.Collections.Generic.HashSet[String]'
$correctedScanners = New-Object 'System.Collections.Generic.HashSet[int]'
$toCheck = New-Object 'System.Collections.Generic.Queue[int]'

[void]($correctedScanners.Add(0))
[void]($toCheck.Enqueue(0))

$scanners[0] | % {[void]($uniqueCoords.Add("$_"))}

$scannerDist = @(@(0, 0, 0))
$bestManathan = 0
while ($toCheck.Count -gt 0) {
	$scan = $toCheck.Dequeue()
	if ($overlappingAreas.Keys -Contains $scan) {
		foreach ($k in $overlappingAreas[$scan].Keys) {
			if ($correctedScanners.Add($k)) {
				[void]($toCheck.Enqueue($k))
				$coords = $overlappingAreas[$scan][$k]
				$orientations = Find-Orientation ($scanners[$scan][$coords[0][0]]) ($scanners[$scan][$coords[0][1]]) ($scanners[$k][$coords[1][0]]) ($scanners[$k][$coords[1][1]])
				for ($i = 0; $i -lt $scanners[$k].Count; $i++) {
					$scanners[$k][$i] = $scannerRot1[$orientations[1]].Invoke((,$scanners[$k][$i]))
					$scanners[$k][$i] = $scannerRot2[$orientations[2]].Invoke((,$scanners[$k][$i]))
					$scanners[$k][$i] = @(($scanners[$k][$i][0] - $orientations[0][0]), ($scanners[$k][$i][1] - $orientations[0][1]), ($scanners[$k][$i][2] - $orientations[0][2]))
					[void]($uniqueCoords.Add("$($scanners[$k][$i])"))
				}
				for ($i = 0; $i -lt $scannerDist.Count; $i++) {
					$bestManathan = [Math]::Max($bestManathan, [Math]::Abs($orientations[0][0] - $scannerDist[$i][0]) + [Math]::Abs($orientations[0][1] - $scannerDist[$i][1]) + [Math]::Abs($orientations[0][2] - $scannerDist[$i][2]))
				}
				$scannerDist += ,$orientations[0]
			}
		}
	}
}
Write-Host $uniqueCoords.Count
Write-Host $bestManathan