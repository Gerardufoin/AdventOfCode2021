$fishies = ,0 * 9
$nbFishies = 0
$days = 256
Get-Content input.txt | % {
	$_ -Split ',' | % {
		$fishies[$_]++
		$nbFishies++
	}
}
for ($i = 0; $i -lt $days; $i++) {
	$birth, $fishies = $fishies
	$fishies[6] += $birth
	$fishies += $birth
	$nbFishies += $birth
	if ($i -eq 79) {
		$nbFishies
	}
}
$nbFishies