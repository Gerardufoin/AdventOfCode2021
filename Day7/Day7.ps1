Get-Content input.txt | % {
	$crabs = $_ -Split ',' | % { [int]$_ } | Sort-Object
}
"Part 1"
if ($crabs.Count % 2 -eq 0) {
	$middle = ($crabs[$crabs.Count / 2 - 1] + $crabs[$crabs.Count / 2]) / 2
} else {
	$middle = $crabs[$crabs.Count / 2]
}
$result = 0
$crabs | % { $result += [Math]::Abs($_ - $middle) }
$result

"Part 2"
# Triangular number =  int(n*(n+1)/2)
$avg = [Math]::Floor(($crabs | Measure-Object -Average).Average)
$result = 0
$crabs | % { $result += [int]([Math]::Abs($_ - $avg) * ([Math]::Abs($_ - $avg) + 1) / 2) }
$result