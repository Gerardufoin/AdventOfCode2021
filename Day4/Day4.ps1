$board = ,@() * 10
$i = $score = $bScore = $idx = $lScore = $lIdx = 0

Function Solve-Board {
	param(
		$board,
		$num,
		$sco
	)
	for ($j = 0; $j -lt $num.Count; $j++) {
		$dec = $false
		for ($r = 0; $r -lt $board.Count; $r++) {
			$row = $board[$r] | Where-Object { $_ -ne $num[$j] }
			if (!$dec -and $row.Count -lt $board[$r].Count) {
				$sco -= $num[$j]
				$dec = $true
			}
			$board[$r] = $row
			if ($board[$r].Count -eq 0) {
				return $j, $sco
			}
		}
	}
	return $num.Count - 1, $sco
}

Get-Content input.txt | % {
	if ($num -eq $null -and $_ -match '\d+,') {
		$num = $_ -Split ','
	} elseif ($_ -match '^ *(\d+) +(\d+) +(\d+) +(\d+) +(\d+)') {
		1..5 | % {
			$bScore += $Matches[$_]
			$board[$i] += $Matches[$_]
			$board[$_ + 4] += $Matches[$_]
			<# C'est quoi ce bingo de @#&@$ qui prend pas les diagonales ????
			if ($i + 1 -eq $_) {
				$board[10] += $Matches[$_]
			}
			if ([Math]::Abs($i - 5) -eq $_) {
				$board[11] += $Matches[$_]
			}#>
		}
		$i++
		if ($i -eq 5) {
			$tmpIdx, $tmpScore = Solve-Board $board $num $bScore
			if ($idx -eq 0 -or $tmpIdx -lt $idx) {
				$score = $tmpScore
				$idx = $tmpIdx
			}
			if ($lIdx -eq 0 -or $tmpIdx -gt $lIdx) {
				$lScore = $tmpScore
				$lIdx = $tmpIdx
			}
			$i = $bScore = 0
			$board = ,@() * 10
		}
	}
}
$score * $num[$idx]
$lScore * $num[$lIdx]