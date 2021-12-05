$boardStep1 = @{}
$boardStep2 = @{}
$pointsStep1 = @{}
$pointsStep2 = @{}
Get-Content input.txt | % {
	if ($_ -match '^(\d+),(\d+) -> (\d+),(\d+)') {
		$line = @([int]$Matches[1], [int]$Matches[2], [int]$Matches[3], [int]$Matches[4])
		$isStraight = ($line[0] -eq $line[2] -or $line[1] -eq $line[3])
		$steps = [Math]::Max([Math]::Abs($line[0] - $line[2]), [Math]::Abs($line[1] - $line[3]))
		$xInc = ($line[2] - $line[0]) / $steps
		$yInc = ($line[3] - $line[1]) / $steps
		for ($i = 0; $i -le $steps; $i++) {
			$x = $line[0] + $xInc * $i
			$y = $line[1] + $yInc * $i
			$xy = "$x,$y"
			if ($isStraight) {
				if ($boardStep1.ContainsKey($xy)) {
					$pointsStep1[$xy] = 1
				}
				$boardStep1[$xy] = "lol"
			}
			if ($boardStep2.ContainsKey($xy)) {
				$pointsStep2[$xy] = 1
			}
			$boardStep2[$xy] = "lol"
		}
	}
}
$pointsStep1.Keys.Count
$pointsStep2.Keys.Count