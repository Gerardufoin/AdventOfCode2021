$h = 0
$d = 0
$d2 = 0
Get-Content input.txt | % {
	if ($_ -match "(\w+) (\d+)") {
		switch ($Matches[1]) {
			"forward" {$h += $Matches[2]; $d2 += $d * $Matches[2]}
			"down" {$d += $Matches[2]}
			"up" {$d -= $Matches[2]}
		}
	}
}
$h * $d
$h * $d2