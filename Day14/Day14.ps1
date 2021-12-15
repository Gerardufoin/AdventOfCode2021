$ROUNDS = 40

$formulas = @{}
$elements = @{}
$poly = ''

Get-Content input.txt | % {
	if ($_ -match '^(\w+)$') {
		$poly = $Matches[1]
	} elseif ($_ -match '([A-Z]{2}) -> ([A-Z])') {
		$formulas.Add($Matches[1], @(0, 0, $Matches[2]))
		if (!($elements.Keys -Contains [String]$Matches[1][0])) {
			$elements.Add([String]$Matches[1][0], 0)
		}
	}
}
for ($i = 0; $i -lt $poly.Length; $i++) {
	$letter = [String]$poly[$i]
	if ($i -lt $poly.Length - 1) {
		$formulas["$letter$($poly[($i+1)])"][0]++
	}
	$elements[$letter]++
}

for ($i = 1; $i -le $ROUNDS; $i++) {
	foreach ($k in $formulas.Keys) {
		$new = $formulas[$k][2]
		$elements[$new] += $formulas[$k][0]
		$formulas["$($k[0])$new"][1] += $formulas[$k][0]
		$formulas["$new$($k[1])"][1] += $formulas[$k][0]
	}
	foreach ($k in $formulas.Keys) {
		$formulas[$k][0] = $formulas[$k][1]
		$formulas[$k][1] = 0
	}
	if ($i -eq 10) {
		($elements.Values | Measure -Maximum).Maximum - ($elements.Values | Measure -Minimum).Minimum
	}
}
($elements.Values | Measure -Maximum).Maximum - ($elements.Values | Measure -Minimum).Minimum