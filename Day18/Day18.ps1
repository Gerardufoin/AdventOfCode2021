$values = @()
$rawValues = @()
Get-Content input.txt | % {
	$values += [SnailPair]::New($_)
	$rawValues += $_
}
$number, $values = $values
if ($values -ne $null) {
	$values | % { [void]($number.Add($_)) }
}
$number.Magnitude()

$bestMagnitude = 0
for ($i = 0; $i -lt $rawValues.Count; $i++) {
	Write-Host "Progress P2: $($i + 1) / $($rawValues.Count)"
	for ($j = 0; $j -lt $rawValues.Count; $j++) {
		if ($i -ne $j) {
			$res = [SnailPair]::new($rawValues[$i]).Add([SnailPair]::new($rawValues[$j])).Magnitude()
			$bestMagnitude = [Math]::Max($res, $bestMagnitude)
		}
	}
}
$bestMagnitude

Class SnailPair {
	$value
	
	SnailPair() {
		$this.value = $null
	}
	
	SnailPair([int]$val) {
		$this.value = $val
	}
	
	SnailPair([String]$input) {
		if ($input -Match '^\d+$') {
			$this.value = [int]$Matches[0]
		} elseif ($input -Match "\[((?:(?:(?'open'\[)[^][]*)+(?:(?'-open'\])[^][]*)+)*(?(open)(?!))|\d+),((?:(?:(?'open'\[)[^][]*)+(?:(?'-open'\])[^][]*)+)*(?(open)(?!))|\d+)\]") {
			$reg = $Matches
			$this.value = @($null, $null)
			0..1 | % {
				$this.value[$_] = [SnailPair]::New($reg[$_ + 1])
			}
		} else {
			throw "$input is not a valid SnailPair input."
		}
	}
	
	[void]Reduce() {
		do {
			$ret, $null = $this.Explode(0)
			if (!$ret) {
				$ret = $this.Split()
			}
		} while ($ret)
	}
	
	[System.Collections.ArrayList]Explode([int]$depth) {
		if ($this.value -is [int]) {
			return $false, $null
		}
		if ($depth -ge 4 -and $this.HasIntPair()) {
			$ret = @($this.value[0].value, $this.value[1].value)
			$this.value = 0
			return $true, $ret
		}
		for ($i = 0; $i -le 1; $i++) {
			$ret, $val = $this.value[$i].Explode($depth + 1)
			if ($ret -eq $true) {
				# Carry explode
				$idx = [Math]::Abs($i - 1)
				if ($val -ne $null -and $val[$idx] -ne $null) {
					$this.value[$idx].Add($val[$idx], $i)
					$val[$idx] = $null
				}
				return $true, $val
			}
		}
		return $false, $null
	}
	
	[Boolean]Split() {
		if ($this.value -is [int]) {
			if ($this.value -ge 10) {
				$newVal = @([SnailPair]::New([Math]::Floor($this.value / 2)), [SnailPair]::New([Math]::Ceiling($this.value / 2)))
				$this.value = $newVal
				return $true
			}
			return $false
		}
		for ($i = 0; $i -le 1; $i++) {
			$ret = $this.value[$i].Split()
			if ($ret -eq $true) {
				return $true
			}
		}
		return $false
	}
	
	[String]ToString() {
		if ($this.value -is [int]) {
			return $this.value
		}
		return "[$($this.value[0].ToString()),$($this.value[1].ToString())]"
	}
	
	[SnailPair]Add([SnailPair]$val) {
		$tmp = [SnailPair]::new()
		$tmp.value = $this.value
		$this.value = @($tmp, $val)
		$this.Reduce()
		return $this
	}
	
	[void]Add([int]$val, [int]$idx) {
		if ($this.value -is [int]) {
			$this.value += $val
		} else {
			$this.value[$idx].Add($val, $idx)
		}
	}
	
	[Boolean]HasIntPair() {
		return (!($this.value -is [int]) -and $this.value[0].value -is [int] -and $this.value[1].value -is [int])
	}
	
	[int]Magnitude() {
		if ($this.value -is [int]) {
			return $this.value
		}
		return 3 * $this.value[0].Magnitude() + 2 * $this.value[1].Magnitude()
	}
}