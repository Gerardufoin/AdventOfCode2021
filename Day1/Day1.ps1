$res1 = 0
$res2 = 0
$input = Get-Content input.txt
for ($i = 1; $i -lt $input.Count; $i++) {
	if ([int]$input[$i - 1] -lt [int]$input[$i]) {
		$res1 += 1
	}
	if ($i -ge 3 -and 0 + $input[$i - 1] + $input[$i - 2] + $input[$i - 3] -lt 0 + $input[$i] + $input[$i - 1] + $input[$i - 2]) {
		$res2 += 1
	}
}
$res1
$res2