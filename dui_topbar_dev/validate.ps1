# ============================================================================
#  DUI Dynamic Topbar HUD -- dev self-check (ASCII only on purpose:
#  Windows PowerShell mis-parses non-BOM UTF-8 scripts with CJK comments)
#  Usage: pwsh -ExecutionPolicy Bypass -File validate.ps1
# ============================================================================
$ErrorActionPreference = 'Stop'
$root = 'D:\Local_Mod\Hearts of Iron IV\dui_topbar'
$problems = New-Object System.Collections.Generic.List[string]
$report = New-Object System.Collections.Generic.List[string]
function Bad($m) { $script:problems.Add($m) | Out-Null }
function ReadAll($p) { return [System.IO.File]::ReadAllText($p, (New-Object System.Text.UTF8Encoding($false))) }
function Strip-Comments($t) { return [regex]::Replace($t, '#[^\r\n]*', '') }

# ------------------------------------------------------------- 1. brace check
$braceFiles = @()
$braceFiles += Get-ChildItem -LiteralPath "$root\interface" -Recurse -File
$braceFiles += Get-ChildItem -LiteralPath "$root\common" -Recurse -File
foreach ($f in $braceFiles) {
	$t = Strip-Comments (ReadAll $f.FullName)
	if ($t.Contains([char]0xFFFD)) { Bad "encoding broken (replacement char): $($f.Name)" }
	$depth = 0; $line = 1; $marked = $false
	foreach ($ch in $t.ToCharArray()) {
		if ($ch -eq "`n") { $line++ }
		elseif ($ch -eq '{') { $depth++ }
		elseif ($ch -eq '}') { $depth--; if ($depth -lt 0 -and -not $marked) { Bad "unbalanced } in $($f.Name) line $line"; $marked = $true } }
	}
	if ($depth -ne 0) { Bad "unclosed { (remaining $depth) in $($f.Name)" }
}
$report.Add("brace check: $($braceFiles.Count) files") | Out-Null

# ------------------------------------------- 2. gui elements + nesting/ancestor
$elements = @{}
$ancestor = @{}
foreach ($g in Get-ChildItem -LiteralPath "$root\interface" -Recurse -Filter *.gui) {
	$raw = Strip-Comments (ReadAll $g.FullName)
	# walk chars, remember brace depth and the last name seen at depth 1
	$depth = 0
	$lastDepth1 = ''
	$pendingDepth = -1
	$sb = New-Object System.Text.StringBuilder
	for ($i = 0; $i -lt $raw.Length; $i++) {
		$ch = $raw[$i]
		if ($ch -eq '}') { $depth-- }
		elseif ($ch -eq '{') { $depth++ }
		# capture  name = "xxx"
		if ($ch -eq 'n' -and $raw.Substring($i, [Math]::Min(6, $raw.Length - $i)) -eq 'name =') { }
		$null = $sb
	}
	# simpler regex approach with depth computed by scanning prefix length
	foreach ($m in [regex]::Matches($raw, 'name\s*=\s*"([^"]+)"')) {
		$before = $raw.Substring(0, $m.Index)
		$d = 0
		foreach ($c in $before.ToCharArray()) { if ($c -eq '{') { $d++ } elseif ($c -eq '}') { $d-- } }
		$elements[$m.Groups[1].Value] = $true
		$ancestor[$m.Groups[1].Value] = @{ depth = $d; top = $null }
	}
	# resolve nearest depth-2 name (direct child of guiTypes) as the top-level ancestor
	$depth1Names = @()
	foreach ($m in [regex]::Matches($raw, 'name\s*=\s*"([^"]+)"')) {
		$before = $raw.Substring(0, $m.Index)
		$d = 0
		foreach ($c in $before.ToCharArray()) { if ($c -eq '{') { $d++ } elseif ($c -eq '}') { $d-- } }
		if ($d -eq 2) { $depth1Names += @{ idx = $m.Index; name = $m.Groups[1].Value } }
	}
	foreach ($key in @($ancestor.Keys)) {
		$info = $ancestor[$key]
		if ($info -eq $null) { continue }
		$idx = $raw.IndexOf('name = "' + $key + '"')
		$pick = $null
		foreach ($dn in $depth1Names) { if ($dn.idx -lt $idx) { $pick = $dn.name } }
		if ($pick -eq $null) { $pick = $key }
		$ancestor[$key] = @{ depth = $info.depth; top = $pick }
	}
}
$report.Add("gui elements: $($elements.Count)") | Out-Null

# --------------------------------------------------- 3. scripted gui sections
$sgText = ''
foreach ($f in Get-ChildItem -LiteralPath "$root\common\scripted_guis" -Recurse -Filter *.txt) { $sgText += ReadAll $f.FullName }
$menuStart = $sgText.IndexOf('dui_topbar_menu = {')
$sgHud = if ($menuStart -gt 0) { $sgText.Substring(0, $menuStart) } else { $sgText }
$sgMenu = if ($menuStart -gt 0) { $sgText.Substring($menuStart) } else { '' }

$guiDefs = @{ hud = @{ text = $sgHud }; menu = @{ text = $sgMenu } }
foreach ($k in @('hud', 'menu')) {
	$t = $guiDefs[$k].text
	$w = [regex]::Match($t, 'window_name\s*=\s*"([^"]+)"').Groups[1].Value
	$guiDefs[$k].window = $w
	$guiDefs[$k].entries = @()
	foreach ($m in [regex]::Matches($t, 'entry_container\s*=\s*"([^"]+)"')) { $guiDefs[$k].entries += $m.Groups[1].Value }
	if ($w -eq '') { Bad "$k gui: no window_name" }
	elseif (-not $elements.ContainsKey($w)) { Bad "$k gui: window_name missing in gui: $w" }
	elseif ($ancestor[$w].depth -ne 2) { Bad "$k gui: window '$w' is not an independent top-level container (depth=$($ancestor[$w].depth))" }
	foreach ($e in $guiDefs[$k].entries) {
		if (-not $elements.ContainsKey($e)) { Bad "$k gui: entry_container missing in gui: $e" }
		elseif ($ancestor[$e].depth -ne 2) { Bad "$k gui: entry container '$e' is not top-level (depth=$($ancestor[$e].depth))" }
	}
	$report.Add("$k gui: window=$w entries=$($guiDefs[$k].entries -join ',')") | Out-Null
}
if ($guiDefs['hud'].text -match 'dynamic_lists') { Bad "hud gui should not contain dynamic_lists (keeps it cheap per tick)" }

# ------------------------------------- 4. element refs + scoping per scripted gui
foreach ($k in @('hud', 'menu')) {
	$t = $guiDefs[$k].text
	$w = $guiDefs[$k].window
	$allowed = @($w) + $guiDefs[$k].entries
	$refs = @{}
	foreach ($m in [regex]::Matches($t, '(?m)^\s*([A-Za-z0-9_]+?)_((?:alt_|shift_|control_|right_)*)click\s*=\s*\{')) { $refs[$m.Groups[1].Value] = $true }
	foreach ($m in [regex]::Matches($t, '(?m)^\s*([A-Za-z0-9_]+?)_(visible|click_enabled)\s*=\s*\{')) { $refs[$m.Groups[1].Value] = $true }
	foreach ($m in [regex]::Matches($t, '(?m)^\s*([A-Za-z0-9_]+)_icon\s*=\s*\{')) { $refs[$m.Groups[1].Value] = $true }
	foreach ($e in $refs.Keys) {
		if (-not $elements.ContainsKey($e)) { Bad "$k gui references unknown element: $e"; continue }
		$top = $ancestor[$e].top
		if ($allowed -notcontains $top) { Bad "$k gui references element '$e' owned by '$top' (outside its own window)" }
	}
}

# per-slot completeness (hud gui)
foreach ($k in 0..7) {
	foreach ($need in @("dui_slot_${k}_btn", "dui_slot_${k}_icon", "dui_slot_${k}_text", "dui_slot_${k}_hl", "dui_slot_$k")) {
		if (-not $elements.ContainsKey($need)) { Bad "gui missing element: $need" }
	}
	$t = $guiDefs['hud'].text
	if ($t -notmatch "(?m)^\s*dui_slot_${k}_btn_click\s*=\s*\{") { Bad "missing effect dui_slot_${k}_btn_click" }
	if ($t -notmatch "(?m)^\s*dui_slot_${k}_btn_right_click\s*=\s*\{") { Bad "missing effect dui_slot_${k}_btn_right_click" }
	foreach ($need in @("dui_slot_${k}_btn", "dui_slot_${k}_icon", "dui_slot_${k}_text", "dui_slot_${k}_hl", "dui_slot_$k")) {
		if ($t -notmatch "(?m)^\s*${need}_visible\s*=\s*\{") { Bad "missing trigger ${need}_visible" }
	}
	if ($t -notmatch "(?m)^\s*dui_slot_${k}_icon\s*=\s*\{") { Bad "missing icon property dui_slot_${k}_icon" }
}

# ------------------------------------------------------ 5. defined_text lookup
$defined = @{}
foreach ($f in Get-ChildItem -LiteralPath "$root\common\scripted_localisation" -Recurse -Filter *.txt) {
	$t = ReadAll $f.FullName
	foreach ($m in [regex]::Matches($t, 'name\s*=\s*([A-Za-z0-9_]+)')) { $defined[$m.Groups[1].Value] = $true }
}
$report.Add("defined_text: $($defined.Count)") | Out-Null
$allInterface = ''
foreach ($f in Get-ChildItem -LiteralPath "$root\interface" -Recurse -File) { $allInterface += ReadAll $f.FullName }
foreach ($src in @(@{n = 'gui'; t = $allInterface }, @{ n = 'scripted gui'; t = $sgText })) {
	foreach ($m in [regex]::Matches($src.t, '\[(Get[A-Za-z0-9_]+)\]')) {
		if (-not $defined.ContainsKey($m.Groups[1].Value)) { Bad "undefined [Get..] in $($src.n): $($m.Groups[1].Value)" }
	}
}

# ------------------------------------------------------------ 6. localization
$locFiles = @{ 'en' = "$root\localisation\english\dui_topbar_l_english.yml"; 'zh' = "$root\localisation\simp_chinese\dui_topbar_l_simp_chinese.yml" }
$locKeys = @{}
foreach ($lang in @('en', 'zh')) {
	$p = $locFiles[$lang]
	$bytes = [System.IO.File]::ReadAllBytes($p)
	if (-not ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)) { Bad "missing UTF-8 BOM: $p" }
	$t = ReadAll $p
	$keys = @{}
	foreach ($m in [regex]::Matches($t, '(?m)^\s*([A-Za-z0-9_.]+)\s*:\s*\d*\s*"')) { $keys[$m.Groups[1].Value] = $true }
	$locKeys[$lang] = $keys
	$report.Add("loc[$lang]: $($keys.Count) keys") | Out-Null
	foreach ($m in [regex]::Matches($t, '\[(Get[A-Za-z0-9_]+)\]')) {
		if (-not $defined.ContainsKey($m.Groups[1].Value)) { Bad "undefined [Get..] in loc[$lang]: $($m.Groups[1].Value)" }
	}
}

# --------------------------------------------------------------- 7. token set
$tokens = @()
foreach ($line in ((ReadAll "$root\common\synchronized_dynamic_tokens\dui_topbar_tokens.txt") -split "`r?`n")) {
	$v = $line.Trim()
	if ($v -ne '' -and -not $v.StartsWith('#')) { $tokens += $v }
}
$effectsText = ''
foreach ($f in Get-ChildItem -LiteralPath "$root\common\scripted_effects" -Recurse -Filter *.txt) { $effectsText += ReadAll $f.FullName }
$menuArray = @()
foreach ($m in [regex]::Matches($effectsText, 'add_to_array\s*=\s*\{\s*dui_menu_items\s*=\s*token:([A-Za-z0-9_]+)')) { $menuArray += $m.Groups[1].Value }
$report.Add("tokens: $($tokens.Count); menu entries: $($menuArray.Count)") | Out-Null
if ($menuArray.Count -gt 33) { Bad "menu entries $($menuArray.Count) exceed 21 main + 12 sub" }
foreach ($tk in $menuArray) { if ($tokens -notcontains $tk) { Bad "menu token not declared: $tk" } }
# Tokens that are intentionally kept (save compatibility) but hidden from the menu.
$hiddenTokens = @('dui_e_infantry','dui_e_support','dui_e_artillery','dui_e_antitank','dui_e_antiair','dui_e_rocketartillery','dui_e_armoredcar','dui_e_motorized','dui_e_mechanized','dui_e_lighttank','dui_e_mediumtank','dui_e_heavytank','dui_m_army_strength','dui_m_air_strength','dui_m_navy_strength',
	'dui_m_threat','dui_m_population','dui_m_army_manpower','dui_m_battalions',
	'dui_m_enemy_strength','dui_m_equipment','dui_m_fuel_ratio','dui_m_aluminium','dui_m_tungsten',
	'dui_m_rubber','dui_m_oil','dui_m_research_slots','dui_m_nukes',
	'dui_m_pp','dui_m_manpower','dui_m_conscription','dui_m_divisions','dui_m_planes','dui_m_ships',
	'dui_m_army_xp','dui_m_navy_xp','dui_m_air_xp','dui_m_free_civ','dui_m_steel','dui_m_chromium',
	'dui_m_research','dui_m_civ_factories','dui_m_mil_factories','dui_m_naval_factories',
	'dui_m_manpower','dui_m_threat','dui_m_fuel','dui_m_fuel_ratio',
	'dui_m_army_xp','dui_m_navy_xp','dui_m_air_xp')
foreach ($tk in $tokens) {
	if ($tk -ne 'dui_m_empty' -and ($hiddenTokens -notcontains $tk) -and ($menuArray -notcontains $tk)) { Bad "declared token missing from menu: $tk" }
	foreach ($suffix in @('', '_text', '_sprite', '_tt')) {
		foreach ($lang in @('en', 'zh')) { if (-not $locKeys[$lang].ContainsKey("$tk$suffix")) { Bad "loc[$lang] missing key: $tk$suffix" } }
	}
}
foreach ($m in [regex]::Matches((Strip-Comments $sgText) + (Strip-Comments $effectsText), 'token:([A-Za-z0-9_]+)')) {
	if ($tokens -notcontains $m.Groups[1].Value) { Bad "undeclared token used: $($m.Groups[1].Value)" }
}

# ------------------------------------------------------- 8. DUI_* ui loc keys
$usedKeys = @{}
foreach ($src in @($allInterface, $sgText)) {
	foreach ($m in [regex]::Matches($src, '(?m)(?:text\s*=\s*|pdx_tooltip(?:_delayed)?\s*=\s*|custom_effect_tooltip\s*=\s*)"?(DUI_[A-Z0-9_]+)"?')) { $usedKeys[$m.Groups[1].Value] = $true }
}
foreach ($k in $usedKeys.Keys) { foreach ($lang in @('en', 'zh')) { if (-not $locKeys[$lang].ContainsKey($k)) { Bad "loc[$lang] missing ui key: $k" } } }
$report.Add("ui keys DUI_*: $($usedKeys.Count)") | Out-Null

# --------------------------------------------------------- 9. sprite existence
$sprites = @{}
foreach ($gr in @('D:\SteamLibrary\steamapps\common\Hearts of Iron IV\interface', 'D:\SteamLibrary\steamapps\workshop\content\394360\1851181613\interface', "$root\interface")) {
	if (Test-Path $gr) {
		foreach ($gf in Get-ChildItem -LiteralPath $gr -Recurse -Filter *.gfx -File) {
			foreach ($m in [regex]::Matches((ReadAll $gf.FullName), 'name\s*=\s*"(GFX_[A-Za-z0-9_]+)"')) { $sprites[$m.Groups[1].Value] = $true }
		}
	}
}
foreach ($lang in @('en', 'zh')) {
	foreach ($m in [regex]::Matches((ReadAll $locFiles[$lang]), '(?m)^\s*([A-Za-z0-9_]+)_sprite\s*:\s*\d*\s*"(GFX_[A-Za-z0-9_]+)"')) {
		if (-not $sprites.ContainsKey($m.Groups[2].Value)) { Bad "loc[$lang] sprite not found in any .gfx: $($m.Groups[2].Value)" }
	}
}
foreach ($m in [regex]::Matches($allInterface, '(?:spriteType|quadTextureSprite)\s*=\s*"(GFX_[A-Za-z0-9_]+)"')) {
	if (-not $sprites.ContainsKey($m.Groups[1].Value)) { Bad "gui references unknown sprite: $($m.Groups[1].Value)" }
}
$report.Add("known sprites: $($sprites.Count)") | Out-Null

# ------------------------------------------------------------------- results
Write-Output '---------------- report ----------------'
$report | ForEach-Object { Write-Output $_ }
Write-Output 'if ($guiText -match "`}\s*[A-Za-z_]") { Bad "gui: } followed by content on the same line (glued line) near: " + $Matches[0] }
---------------- issues ----------------'
if ($problems.Count -eq 0) { Write-Output 'no issues found' } else { $problems | ForEach-Object { Write-Output "[x] $_" } }
Write-Output ("total issues: {0}" -f $problems.Count)
