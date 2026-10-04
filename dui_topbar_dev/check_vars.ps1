# ============================================================================
#  DUI Dynamic Topbar HUD -- check that every game variable referenced in the
#  localisation exists in the documented 1.19 "game variables" list.
#  Usage: pwsh -ExecutionPolicy Bypass -File check_vars.ps1
# ============================================================================
$ErrorActionPreference = 'Stop'
$root = 'D:\Local_Mod\Hearts of Iron IV\dui_topbar'
function ReadAll($p) { return [System.IO.File]::ReadAllText($p, (New-Object System.Text.UTF8Encoding($false))) }

$allowed = @(
	'political_power', 'political_power_daily', 'stability', 'has_war_support',
	# (ascii-only note: this mod / modifier@ variables)
	'dui_stability_delta', 'dui_war_support_delta',
	'command_power', 'command_power_daily', 'conscription_ratio', 'target_conscription_amount',
	'SOV_paranoia',
	'threat',
	'manpower', 'max_manpower', 'deployed_army_manpower_k',
	'num_armies', 'num_battalions', 'num_deployed_planes', 'num_ships', 'casualties',
	'surrender_progress', 'any_war_score', 'enemies_strength_ratio',
	'army_experience', 'navy_experience', 'air_experience',
	'num_equipment', 'num_equipment_in_armies',
	'num_of_civilian_factories', 'num_of_civilian_factories_available_for_projects',
	'num_of_military_factories', 'num_of_available_military_factories',
	'num_of_naval_factories', 'num_of_available_naval_factories',
	'fuel_k', 'max_fuel_k', 'fuel_ratio',
	'resource', 'resource_produced', 'resource_consumed',
	'num_researched_technologies', 'amount_research_slots', 'num_of_nukes',
	# (ascii-only note: this mod / modifier@ variables)
	'modifier',
	# (ascii-only note: this mod / modifier@ variables)
	'army_strength', 'air_strength', 'navy_strength', 'field_strength',
	'ROOT.num_equipment','num_equipment','num_equipment_in_armies','num_equipment_in_armies_k','ROOT.dui_stock_infantry','ROOT.dui_stock_support','ROOT.dui_stock_artillery','ROOT.dui_stock_antitank','ROOT.dui_stock_antiair','ROOT.dui_stock_rocketartillery','ROOT.dui_stock_armoredcar','ROOT.dui_stock_motorized','ROOT.dui_stock_mechanized','ROOT.dui_stock_lighttank','ROOT.dui_stock_mediumtank','ROOT.dui_stock_heavytank'
)

$files = @(
	"$root\localisation\english\dui_topbar_l_english.yml",
	"$root\localisation\simp_chinese\dui_topbar_l_simp_chinese.yml"
)
$problems = 0
foreach ($f in $files) {
	$t = ReadAll $f
	foreach ($m in [regex]::Matches($t, '\[\?([^\]\|]+)')) {
		$name = $m.Groups[1].Value.Trim()
		$name = $name -replace '^global\.', ''
		$name = ($name -split '@')[0]
		$name = ($name -split '\^')[0]
		if ($name -like 'dui_*') { continue }   # variables written by this mod, not game variables
		if ($allowed -notcontains $name) {
			Write-Output ("[x] {0}: unknown game variable '{1}'" -f (Split-Path $f -Leaf), $name)
			$problems++
		}
	}
}
Write-Output ("checked {0} localisation files, issues: {1}" -f $files.Count, $problems)
