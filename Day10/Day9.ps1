$part1 = 0
$scores = @()
$chunks = @{
	[char]')' = @('(', 3)
	[char]']' = @('[', 57)
	[char]'}' = @('{', 1197)
	[char]'>' = @('<', 25137)
}
$closing = @([char]'(', [char]'[', [char]'{', [char]'<')
Get-Content input.txt | % {
	$line = ''
	for ($i = 0; $i -lt $_.Length; $i++) {
		if ($chunks.Keys -Contains $_[$i]) {
			if ($line.Length -eq 0 -or $chunks[$_[$i]][0] -ne $line[0]) {
				$part1 += $chunks[$_[$i]][1]
				return
			}
			$line = $line.Substring(1, $line.Length - 1)
		} else {
			$line = $_[$i] + $line
		}
	}
	$score = 0
	for ($i = 0; $i -lt $line.Length; $i++) {
		$score = $score * 5 + $closing.IndexOf($line[$i]) + 1
	}
	$scores += $score
}
$part1
($scores | Sort-Object)[[Math]::Floor($scores.Length / 2)]
