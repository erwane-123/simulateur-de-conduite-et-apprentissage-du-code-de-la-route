$brainDir = 'C:\Users\Romeo\.gemini\antigravity\brain\82a0e8bf-4c7c-49a1-a0f8-2d6c0e10c74d'
$destDir = 'c:\Users\Romeo\projet-2026\code_route_flutter\assets\images\questions'
New-Item -ItemType Directory -Force -Path $destDir | Out-Null

$images = @('priority_intersection', 'roundabout_approach', 'speeding_rain', 'night_driving', 'pedestrian_crossing', 'dashboard_warning')

foreach ($img in $images) {
    $file = Get-ChildItem -Path $brainDir -Filter "$img*.png" | Select-Object -First 1
    if ($file) {
        Copy-Item -Path $file.FullName -Destination "$destDir\$img.png" -Force
    }
}

$content = [IO.File]::ReadAllText('c:\Users\Romeo\projet-2026\code_route_flutter\lib\data\test_questions.dart', [System.Text.Encoding]::UTF8)

$newContent = [regex]::Replace($content, 'question:\s*"([^"]+)",\s*imagePath:\s*"[^"]+"', {
    param($m)
    $q = $m.Groups[1].Value.ToLower()
    $img = 'priority_intersection'
    
    if ($q -match 'piéton|passage|traverser|piétons') { $img = 'pedestrian_crossing' }
    elseif ($q -match 'nuit|phare|éblouissant|obscur|feux') { $img = 'night_driving' }
    elseif ($q -match 'vitesse|pluie|autoroute|mouillé|aquaplaning|limite') { $img = 'speeding_rain' }
    elseif ($q -match 'rond-point|giratoire|anneau') { $img = 'roundabout_approach' }
    elseif ($q -match 'priorité|intersection|cédez|droite|croisement|croise') { $img = 'priority_intersection' }
    elseif ($q -match 'voyant|tableau|frein|moteur|arrêt|freinage|alcool|fatigue') { $img = 'dashboard_warning' }
    else {
        $hashSum = 0
        for ($i=0; $i -lt $q.Length; $i++) { $hashSum += [int][char]$q[$i] }
        $img = $images[$hashSum % 6]
    }
    
    return "question: `"" + $m.Groups[1].Value + "`",`n      imagePath: `"assets/images/questions/$img.png`""
}, [System.Text.RegularExpressions.RegexOptions]::Singleline)

[IO.File]::WriteAllText('c:\Users\Romeo\projet-2026\code_route_flutter\lib\data\test_questions.dart', $newContent, [System.Text.Encoding]::UTF8)
Write-Host "Mapped images successfully!"
