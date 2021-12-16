$converter = @{
	[char]'0' = '0000'
	[char]'1' = '0001'
	[char]'2' = '0010'
	[char]'3' = '0011'
	[char]'4' = '0100'
	[char]'5' = '0101'
	[char]'6' = '0110'
	[char]'7' = '0111'
	[char]'8' = '1000'
	[char]'9' = '1001'
	[char]'A' = '1010'
	[char]'B' = '1011'
	[char]'C' = '1100'
	[char]'D' = '1101'
	[char]'E' = '1110'
	[char]'F' = '1111'
}

$operations = @{
	[int64]0 = {
		param($values)
		$sum = 0
		$values | % {$sum += $_}
		$sum
	}
	[int64]1 = {
		param($values)
		$prod = 1
		$values | % {$prod *= $_}
		$prod
	}
	[int64]2 = {
		param($values)
		$min = $values[0]
		$values | % {$min = [Math]::Min($min, $_)}
		$min
	}
	[int64]3 = {
		param($values)
		$max = $values[0]
		$values | % {$max = [Math]::Max($max, $_)}
		$max
	}
	[int64]5 = {param($values) [int]($values[0] -gt $values[1])}
	[int64]6 = {param($values) [int]($values[0] -lt $values[1])}
	[int64]7 = {param($values) [int]($values[0] -eq $values[1])}
}

function Get-Bits {
	param(
		$bits,
		$size
	)
	return $bits.Substring(0, $size), $bits.Substring($size)
}

function Get-BitsAsInt {
	param(
		$bits,
		$size
	)
	$n, $bits = Get-Bits $bits $size
	return ([Convert]::ToInt64($n, 2)), $bits
}


function Decode-Message {
	param(
		$bits,
		$totVersion = 0
	)
	$result = 0
	$version, $bits = Get-BitsAsInt $bits 3
	$totVersion += $version
	$type, $bits = Get-BitsAsInt $bits 3
	if ($type -eq 4) {
		$num = ''
		do {
			$h, $bits = Get-Bits $bits 1
			$n, $bits = Get-Bits $bits 4
			$num += $n
		} while ($h -eq 1)
		$result = [Convert]::ToInt64($num, 2)
	} else {
		$lenType, $bits = Get-Bits $bits 1
		$values = @()
		if ($lenType -eq 0) {
			$len, $bits = Get-BitsAsInt $bits 15
			$packet, $bits = Get-Bits $bits $len
			do {
				$packet, $val, $totVersion = Decode-Message $packet $totVersion
				$values += $val
			} while ($packet.Length -gt 0)
		} else {
			$nbP, $bits = Get-BitsAsInt $bits 11
			do {
				$bits, $val, $totVersion = Decode-Message $bits $totVersion
				$values += $val
				$nbP--
			} while ($nbP -gt 0)
		}
		$result = $operations[$type].Invoke((,$values))
	}
	return $bits, $result, $totVersion
}

Get-Content input.txt | % {
	$bits = ''
	$_.ToCharArray() | % {
		$bits += $converter[$_]
	}
	$null, $part2, $part1 = Decode-Message $bits
	$part1
	$part2
}