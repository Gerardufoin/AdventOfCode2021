Function Explore-AllPathP1 {
	param(
		$caves,
		$links,
		$current
	)
	if ($current -eq 'end') {
		return 1
	}
	$count = 0
	$links[$current] | % {
		if (!$caves[$_][1]) {
			if (!$caves[$_][0]) {
				$caves[$_][1] = $true
			}
			$count += Explore-AllPathP1 $caves $links $_
			$caves[$_][1] = $false
		}
	}
	return $count
}

Function Explore-AllPathP2 {
	param(
		$caves,
		$links,
		$miniTwiced,
		$current
	)
	if ($current -eq 'end') {
		return 1
	}
	$count = 0
	$links[$current] | % {
		if ($_ -ne 'start' -and ($caves[$_][2] -eq 0 -or ($miniTwiced -eq '' -and $caves[$_][2] -eq 1))) {
			if (!$caves[$_][0]) {
				$caves[$_][2]++
			}
			if ($caves[$_][2] -eq 2) {
				$count += Explore-AllPathP2 $caves $links $_ $_
			} else {
				$count += Explore-AllPathP2 $caves $links $miniTwiced $_
			}
			if (!$caves[$_][0]) {
				$caves[$_][2]--
			}
		}
	}
	return $count
}

$caves = @{}
$caveLinks = @{}
Get-Content input.txt | % {
	if ($_ -Match '(\w+)-(\w+)') {
		$link = $Matches
		if (!($caves.Keys -Contains $link[1])) {
			$caves.Add($link[1], @(($link[1] -Cmatch '^[A-Z]+$'), $false, 0))
			$caveLinks.Add($link[1], @())
		}
		if (!($caves.Keys -Contains $link[2])) {
			$caves.Add($link[2], @(($link[2] -Cmatch '^[A-Z]+$'), $false, 0))
			$caveLinks.Add($link[2], @())
		}
		$caveLinks[$link[1]] += $link[2]
		$caveLinks[$link[2]] += $link[1]
	}
}
$caves['start'][1] = $true
Explore-AllPathP1 $caves $caveLinks 'start'
Explore-AllPathP2 $caves $caveLinks '' 'start'