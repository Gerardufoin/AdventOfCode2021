$input = Get-Content input.txt
"Part 1"
$input | % {
	$ca = $_.toCharArray()
	if ($a -eq $null) {
		$a = ,0 * $ca.Count
	}
	for ($i = 0; $i -lt $ca.Count; $i++) {
		switch ($ca[$i]) {
			"0" {$a[$i] -= 1}
			"1" {$a[$i] += 1}
		}
	}
}
$gam = ($a | % {[Math]::Max([Math]::Min($_, 1), 0)}) -Join ''
$eps = ($gam.toCharArray() | % {[Math]::Abs($_ - 49)}) -Join ''
[Convert]::ToInt32($gam, 2) * [Convert]::ToInt32($eps, 2)


"Part 2"
Function filterBit {
	param(
		$a,
		$pos,
		$max
	)
	$one = $zero = @()
	$a | % {
		$v = $_
		switch ($_.toCharArray()[$pos]) {
			"0" {$zero += $v}
			"1" {$one += $v}
		}
	}
	if (($max -and $one.Count -lt $zero.Count) -or (!$max -and $zero.Count -le $one.Count)) {
		return $zero
	}
	return $one
}
$i = 0
$ogr = $input
do {
	$ogr = filterBit $ogr $i $true
	$i++
} while ($ogr.Count -gt 1)
$i = 0
$csr = $input
do {
	$csr = filterBit $csr $i $false
	$i++
} while ($csr.Count -gt 1)
[Convert]::ToInt32($ogr, 2) * [Convert]::ToInt32($csr, 2)