$part1 = 0
$part2 = 0
function Sub-Num {
	param(
		[String[]]$list,
		[String]$sub,
		[int]$goal,
		[String]$avoid = ''
	)
	foreach ($num in $list) {
		if ($num -ne $avoid) {
			$cpy = $num
			foreach ($char in $sub.toCharArray()) {
				$cpy = $cpy -Replace $char,''
			}
			if ($cpy.Length -eq $goal) {
				return $num
			}
		}
	}
	return ''
}

Get-Content input.txt | % {
	if ($_ -match '(\w+) (\w+) (\w+) (\w+) (\w+) (\w+) (\w+) (\w+) (\w+) (\w+) \| (\w+) (\w+) (\w+) (\w+)') {
		$combi = ,'' * 10
		$five = @()
		$six = @()
		for ($i = 1; $i -le 10; $i++) {
			$num = (-join ($Matches[$i].ToCharArray() | Sort-Object))
			switch ($num.Length) {
				2 {$combi[1] = $num}
				3 {$combi[7] = $num}
				4 {$combi[4] = $num}
				5 {$five += $num}
				6 {$six += $num}
				7 {$combi[8] = $num}
			}
		}
		$combi[3] = (Sub-Num $five $combi[1] 3)
		$combi[2] = (Sub-Num $five $combi[4] 3 $combi[3])
		$combi[5] = (Sub-Num $five $combi[4] 2 $combi[3])
		$combi[9] = (Sub-Num $six $combi[4] 2)
		$combi[0] = (Sub-Num $six $combi[7] 3 $combi[9])
		$combi[6] = (Sub-Num $six $combi[7] 4 $combi[9])
		$output = ''
		for ($i = 11; $i -le 14; $i++) {
			$num = (-join ($Matches[$i].ToCharArray() | Sort-Object))
			if ($num.Length -le 4 -or $num.Length -eq 7) {
				$part1++
			}
			$output += [array]::indexof($combi, $num)
		}
		$part2 += $output
	}
}
$part1
$part2