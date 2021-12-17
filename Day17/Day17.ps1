$limits = ,0 * 4
Get-Content input.txt | % {
	if ($_ -Match 'x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)') {
		$limits = @([int]$Matches[1], [int]$Matches[2], [int]$Matches[3], [int]$Matches[4])
	}
}
# May not work for every configuration?
$maxY = $limits[2]
if ([Math]::Abs($limits[3]) -gt [Math]::Abs($limits[2])) {
	$maxY = $limits[3]
}
$maxY = [Math]::Abs($maxY) + [Math]::Sign([Math]::Sign($maxY) - 1)
$step1 = 0
1..$maxY | % {$step1 += $_}
Write-Host $step1

# Part 2. Don't do this at home kids, use normal bruteforce like a smart person.
Function Get-AllXStep {
	param(
		$steps,
		$dest,
		$ZeroSteps,
		$limits
	)
	$sign = [Math]::Sign($dest)
	[Math]::Abs($dest)..0 | % {
		$cnt = 0
		$nb = $_
		$tot = $_
		do {
			if ($tot -ge [Math]::Min($limits[0], $limits[1]) -and $tot -le [Math]::Max($limits[0], $limits[1])) {
				if (!($steps.Keys -Contains $nb)) {
					$steps.Add($nb, @())
				}
				$steps[$nb] += $cnt + 1
				if ($_ - ($cnt + 1) -eq 0 -and !($ZeroSteps -Contains $nb)) {
					$ZeroSteps += $nb
				}
			}
			$cnt++
			$tot += ($_ - $cnt)
		} while ($_ - $cnt -gt 0)
	}
	return $ZeroSteps
}

$ZeroSteps = @()
$allXSteps = @{}
if ([Math]::Max($limits[0], $limits[1]) -gt 0) {
	$ZeroSteps = Get-AllXStep $allXSteps ([Math]::Max($limits[0], $limits[1])) $ZeroSteps $limits
}
if ([Math]::Min($limits[0], $limits[1]) -lt 0) {
	$ZeroSteps = Get-AllXStep $allXSteps ([Math]::Min($limits[0], $limits[1])) $ZeroSteps $limits
}
$allYSteps = @{}
$maxY = [Math]::Max([Math]::Abs($limits[2]), [Math]::Abs($limits[3]))
[Math]::Min($limits[2], $limits[3])..$maxY | % {
	$cnt = 0
	$nb = $_
	$tot = $_
	do {
		if ($tot -ge [Math]::Min($limits[2], $limits[3]) -and $tot -le [Math]::Max($limits[2], $limits[3])) {
			if (!($allYSteps.Keys -Contains $nb)) {
				$allYSteps.Add($nb, @())
			}
			$allYSteps[$nb] += $cnt + 1
		}
		$cnt++
		$tot += ($_ - $cnt)
	} while ($_ - $cnt -ge -$maxY)
}
$combi = New-Object 'System.Collections.Generic.HashSet[String]'
$allXSteps.Keys | % {
	$x = $_
	$allXSteps.$x | % {
		$step = $_
		$allYSteps.Keys | % {
			$y = $_
			if ($allYSteps.$y -Contains $step) {
				[void]($combi.Add("$x,$y"))
			}
		}
	}
}
$allYSteps.Keys | % {
	$y = $_
	$allYSteps.$y | % {
		$step = $_
		$ZeroSteps | % {
			if ($step -ge $_) {
				[void]($combi.Add("$_,$y"))
			}
		}
	}
}
Write-Host $combi.Count