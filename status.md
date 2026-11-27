# Moooze Tanks status

Updated: November 10, 2026

## Current mechanics review - November 10, 2026

- R1/R5/R6: runtime checks verified both tank spawn points are clear of solid geometry, all WASD directions and release, normalized diagonal speed, smooth chassis facing and independent turret behavior. Existing controls/physics retained by user confirmation.
- R8/R9: perimeter/cover blocking, wall sliding, cover destruction and cleared-space movement pass existing checks. Added Area2D entry/exit detection to the existing moose contact hazards, preserving contact reach, damage protection, knockback, charge and appearance.
- R9: four moose still spawn once with staggered emergence. The user explicitly requested no additional moose; recurring waves were not added.
- UI2/UI3/UI4: existing elapsed timer advances during play, freezes outside play and resets on restart. Respawn, defeat explosion delay, HUD and replay behavior retained. No countdown or server match contract introduced.
- UI6/UI8/UI9: updated README, this status and prompt-log Entry 35. New tests/mechanics.gd and adjusted forest checks document the review. UI7 and ReqMgmtPlan.docx preserved. The earlier sections below remain historical evidence.

The source plan reports R1 In Progress and R2?R9/UI1?UI9 To Be Confirmed. The evidence below describes the current implementation separately; it does not change the source plan's acceptance statuses.

| IDs | Implementation and evidence | Remaining verification / scope |
| --- | --- | --- |
| R1?R4 | Existing SVG tanks, attached turrets, snowballs retained; destructible bricks use ice textures and the perimeter uses forest trees; local co-op adds a purple second tank. Runtime checks and rendered co-op preview inspected. | Full human visual/play test. |
| R5?R7 | P1 WASD/mouse/left-click unchanged. P2 arrows/T-F-G-H/J provide independent movement, aim and fire. Automated independence, release, retained aim and simultaneous fire passed. | Physical keyboard rollover, diagonal aim and two-person comfort. |
| R8?R9 | Shared field and perimeter unchanged. P2 impact, destruction, boundary blocking and wall sliding passed; original smoke suite passed. | Full two-person arena playtest. |
| UI1 | Play opens Solo/Local Co-op; separate Controls/Help, Sound, Credits and Exit retained. GUI mouse navigation passed; restart retains mode. | Host/Join still disabled; network integration outstanding. |
| UI2 | Compact logo/HUD shows both players' health/lives, shared score, ice remaining, shots and time. Data and logo bounds checked. | Moose now supply contact damage; friendly fire remains disabled. |
| UI3 | Pause freezes both players; restart resets both. Automated checks passed. | Human menu/Escape navigation. |
| UI4 | Solo/team winner or no-winner defeat, shared score and statistics; results/replay checked. | Competitive/network winner calculations not implemented. |
| UI5 | Separate Controls and Help screens explain both players and existing rules; navigation checked. | Human readability and control comfort. |
| UI6 | README updated with local co-op controls, requirement mapping and limits. | None for this documentation change. |
| UI7 | Existing AGENTS.md retained. | No change requested. |
| UI8 | This status file records the authorized co-op extension and evidence. | Update when new work is authorized. |
| UI9 | prompt_log.md records this UI request, changes, tests and limitations. | No source status promoted. |

Godot 4.7.2: 32 smoke checks and 16 local co-op checks passed; import had no script/parser errors. Menu/co-op graphical previews inspected. Logs, root certificates and editor settings produce environment access errors. No full human playtest performed. No server protocol or network health/result contract introduced.

## Sound enhancement - October 26, 2026

- R7: Both players trigger short shooting effects; two simultaneous voices maximum.
- R8: Ice destruction and explosion/impact effects connected; 90 ms duplicate suppression.
- R5: One low-volume engine loop follows actual movement of either tank and stops on release.
- UI1/UI3: Enabled button clicks, Sound menu volume/mute, and gameplay audio stopped on pause. Volume is session-only.
- UI6/UI8: README and this status updated. No new requirement ID; the source plan has no dedicated audio requirement.
- Five original synthesized WAV assets added, with no third-party recordings.
- Observed validation: Godot 4.7.2 import; 32 smoke + 16 co-op + 13 graphical audio checks passed. Menu preview inspected. Audio tests initially exposed insufficient wait time for frame/audio updates; after correcting the test synchronization, all checks passed.
- Remaining: human listening test for speaker output, tone, comfort and simultaneous firing mix. Runtime playback assertions do not establish audible quality. Existing environment access errors remain.


## Christmas forest and moose - October 30, 2026

- R4/R8/R9: icy destructible walls restored, reinforced perimeter rendered as evergreen trees, no decorated corner trees, and four roaming animated moose. Original brick geometry/layout and arena size unchanged; original SVGs retained.
- R8/UI2: actual contact damages either tank by 20, with independent 2-second protection shared across moose. A fresh contact after separation is required. Moose yield instead of physically pinning tanks; respawn is protected. Existing lives, score and health handling reused.
- UI3/UI5: pause freezes hazards and protection, restart replaces the herd, and help describes icy walls, forest borders and moose. Tank controls unchanged; tanks render above decorative foliage.
- UI6/UI8: README requirements mapping and this status updated; no new requirement IDs or source-plan acceptance changes. Original requirements document and prompt log preserved.
- Human testing still required: two-person keyboard/mouse play, long-session difficulty and fairness, animation feel, readability when crossing trees, resize behavior, and audible sound quality. Network multiplayer remains outside this task.

Validation on October 30: installed Godot 4.7.2 confirmed; import completed without script/parser errors. All 32 smoke, 16 local co-op, 13 graphical sound, and 16 forest checks passed, including a 30-second contained roam. Rendered co-op screenshot inspected after updating tank draw order. Existing environment errors remain for log writes, root certificates and editor settings; these are not reported as clean engine output. No full human playtest performed.

Forest border correction (October 30): R4 restores original icy interior bricks; R8/R9 retain indestructible boundary collisions with actual evergreen tree sprites and no metal rivets. UI5 help corrected; UI6/UI8 documentation updated. Moose retained; corner Christmas trees subsequently removed at user request.

Border correction verification: Godot 4.7.2 import had no script/parser errors; 32 smoke and 16 local co-op checks passed, including destruction, wall sliding and containment. Updated graphical arena preview inspected. Existing log/certificate/editor-settings access errors remain; full human playtesting is still outstanding.

Corner decoration removal (October 30, R9/UI6/UI8): removed the eight decorated Christmas trees from gameplay, retaining only forest border trees. Moose spawn locations and behavior are unchanged. Updated the existing forest assertions; Godot 4.7.2 import reported no script/parser errors, 32 smoke and 16 forest checks passed, and the updated arena preview was inspected. Existing environment access errors remain; no human playtest performed.


Moose hit feedback (October 30; R5/R8/R9, UI2/UI3, UI6/UI8): accepted moose hits now push either tank away from the moose with a 520 px/s impulse, decelerating at 1800 px/s squared (about 0.29 seconds and 75 pixels at rest in open space). A 0.3-second orange-red tank flash and expanding impact ring/rays make contact visible, including when a wall blocks recoil. Movement input remains available, and turret aiming/shooting remain active. The impulse uses existing swept character movement so icy walls and the forest border block it. The existing 2-second moose damage protection also blocks repeated impulses; pause freezes recoil/flash, and respawn/restart clears them. Damage and lives are unchanged. These are implementation defaults for the requested feedback, not new requirement IDs.

`tests/knockback.gd` checks both players, cooldown, pause, collision containment, respawn cleanup, input/firing during recoil and restart. Run with the usual Godot executable and `--path . --script res://tests/knockback.gd`; graphical mode also captures `tests/hit-preview.png`. Manual two-player testing should confirm recoil strength and visual comfort.

Hit-feedback verification: Godot 4.7.2 import completed without script/parser errors; 32 smoke, 16 co-op, 18 forest and 14 graphical knockback checks passed. Hit-effect screenshot inspected. Existing log/certificate/editor-settings access errors remain. Full human playtesting and subjective recoil/flash comfort are still outstanding.


## Winter UI - November 3, 2026

UI1-UI5: implemented the requested main menu, top HUD, pause, results, Controls and Help improvements using existing game data and callbacks. Added an original moose-on-tank SVG logo and shared forest/frost/gold panel/button styling. Sound/Credits/Exit and unavailable Host/Join options remain accessible. No separate player scores or competitive winner logic were added: co-op retains its existing shared score/team victory. Source R1-R9 and UI1-UI9 criteria/statuses unchanged. UI6/UI8/UI9 documentation updated; UI7 and requirements document preserved.

Observed: Godot 4.7.2 import exited 0 without parser errors. Passed 40 graphical UI, 32 smoke, 16 co-op, 18 forest and 25 graphical audio assertions (131 total). UI suite sends GUI mouse events and Escape key events and checks accurate health/score/results and HUD bounds. Screenshots of menu, mode selection, both HUD modes, pause, results, Controls and Help inspected. Visual inspection found an oversized logo; the strengthened UI bounds check reproduced it, and the final correction passed.

Limitations: existing log/certificate/editor-settings access errors and occasional two-instance ObjectDB shutdown warnings remain. Full human playtesting, physical two-player input, resizing/readability on other displays and audio listening are still outstanding. Exit remains connected to the existing quit callback; automated UI navigation does not click Exit to terminate its own test runner. Network multiplayer remains unimplemented. Prior sections are historical evidence, not current UI descriptions.

November 10 review validation: 141 assertions passed in Godot 4.7.2 (20 mechanics, 19 forest, 33 smoke, 16 co-op, 18 graphical charge, 35 graphical audio); editor import had no script/parser errors. An initial recoil assertion required an extra physics-step allowance for Area2D notifications and passed after synchronization was corrected. Existing log/certificate/editor-settings errors and 2-8 ObjectDB shutdown warnings remain. No human playtest or audio-listening claim; source acceptance statuses unchanged.


## Block power-ups - November 17, 2026

- R1/R3/R4/R5/R6/R7/R8/R9: eight marked blocks grant heavy ammo, shield, speed or heart-shaped health recovery to the shooter. Distinct orange, blue, green and pink tank effects; existing sprites, controls, 35-block objective, perimeter and moose rules preserved. Implementation defaults are documented in README.md.
- UI2/UI3/UI5: per-player ammo/timer HUD, pause/reset handling, and a separate illustrated Power-ups help screen. UI6/UI8/UI9 documentation maintained; UI7 and source-plan statuses unchanged.
- Observed checks: installed Godot 4.7.2; final import without parser/script errors; 38 power-up, 33 smoke, 16 co-op, 55 graphical UI and 18 graphical moose-charge assertions passed (160 total). Corrected HUD overlap found by a new bounds check. Graphical arena/effects and help previews inspected; git diff whitespace check passed.
- Limitations: initial bullet type syntax was corrected after import identified a parser error. Existing log/certificate/editor-settings access errors and 2-4 shutdown ObjectDB leak warnings remain. No human playtest, physical input-comfort assessment, or balance claim; network multiplayer remains outside this extension.


## Hidden rewards and heart/gas-tank HUD - November 17, 2026

- R4/R7/R8: power-up blocks have no visible badge before impact. Shooting a containing block reveals its reward icon for 1.2 seconds and grants it to the shooter. Existing power-up values, score, collision and perimeter behavior preserved.
- UI2/UI3/UI5: each player has three heart images for lives and five gas-tank images for health (20 health each, partial fills supported). Lost hearts dim; health damage/recovery, respawn and elimination update the actual icons. Tooltips provide exact values. Help updated; reveal animation pauses and cleans up.
- UI6/UI8/UI9: README and prompt log updated, preserving prior history and source requirement statuses. This supersedes the visible block badges described in the earlier power-up entry.
- Verified in Godot 4.7.2: editor import without parser errors; 45 power-up, 33 smoke, 16 local co-op, 59 graphical UI and 19 forest checks passed (172 total). Screenshots inspected for hidden/revealed rewards, lost hearts, partial gas tanks and help. Tight Help layout found visually and reduced spacing; new bounds assertion passes. Git whitespace check passed.
- Limits: existing log/root-certificate/editor-settings access errors and 4-7 ObjectDB shutdown leak warnings. No full human playtest or target-display accessibility/readability certification.


## Replacement bricks - November 20, 2026

R4/R7/R8/R9: destroyed interior cover respawns elsewhere with clear placement and an 8/35 hidden reward chance; original effects/perimeter preserved. UI2/UI4: Solo retains 35-destruction goal and 3500-point victory, duel retains lives-based ending. UI6/UI8/UI9 documentation updated. Tests: 8 respawn, 33 smoke, 45 power-up and 16 co-op passed in Godot 4.7.2. Mechanics has 19 passes and one timer failure also reproduced on unmodified HEAD; left unchanged. Environment access errors and shutdown leak warnings remain; no graphical/human playtest. Source acceptance statuses unchanged.


## Duel-only replacement correction - November 20, 2026

User clarified that Solo Practice must not replace destroyed bricks. Replacement scheduling and execution now require Local Co-op/Duel. Hidden rewards and all other gameplay preserved. Updated scripts/game.gd and tests/brick_respawn.gd; README.md/status.md/prompt_log.md maintained. Requirements R4/R7/R8/R9, UI2/UI4/UI6/UI8/UI9. Godot 4.7.2: 10 respawn, 33 smoke, 45 power-up and 16 co-op checks passed (104 total), using --headless --path . --script res://tests/<suite>.gd. New assertions cover Solo no-replacement and pending Duel replacements across a switch to Solo. Existing log/certificate errors and 2-5 shutdown leak warnings remain. No graphical/human playtest. This corrects the earlier replacement-in-Solo description; source acceptance statuses unchanged.


## Both-mode brick replacement correction - November 20, 2026

Request summary: user reports missing replacements and now explicitly requests brick replacement at another location in BOTH Solo and Local Co-op. Supersedes the earlier Solo exclusion. Removed mode guards in scripts/game.gd; preserved safe placement, hidden reward chance, 35-destruction Solo goal and all other gameplay. Expanded tests/brick_respawn.gd to fire actual tank projectiles in Solo, Co-op P1 and Co-op P2 and check one visible replacement elsewhere. README.md/status.md/prompt_log.md updated. Requirements R4/R7/R8/R9, UI2/UI4/UI6/UI8/UI9. Branch fix/brick-replacement-both-modes.

Actual checks in Godot 4.7.2: 16 respawn, 33 smoke, 45 power-up and 16 co-op assertions passed (110 total), using --headless --path . --script res://tests/<suite>.gd. No script/parser errors in these runs; existing log/certificate access errors and 2-4 ObjectDB shutdown leak warnings remain. No human playtest. Changes are local in C:/Users/ANNAMARIE/Desktop/Codexdemo/Moooze-Tanks-Repository, not pushed. Earlier mode-exclusion entries are historical and superseded by this clarification.


## Credits correction - November 20, 2026

Request summary: remove JDAT STUDIOS heading from Main Menu Credits; both Olaniyi Tolulope and Anna-Marie Oyemiren should be Business Analyst & Product Designer. Replaced heading with CREDITS, kept names intact, updated both displayed roles and README team table. Updated existing UI assertion. Files: scripts/game.gd, tests/ui.gd, README.md, status.md, prompt_log.md. Requirements UI1/UI6/UI8/UI9; no gameplay changes. Branch fix/credits-roles. Actual verification: graphical Godot 4.7.2 tests/ui.gd passed with UI TEST FAILURES: 0, including updated credits and menu navigation. Initial headless attempt could not drive mouse navigation, failed and was stopped; graphical rerun succeeded. No full human playtest. Existing unrelated working changes preserved.


## Team credits layout - November 20, 2026

Request summary: Credits should list @Studio - Client-Side Development with Olaniyi Tolulope and Anna-Marie Oyemiren underneath, no roles; Server-side project: Ctrl-Alt-Elite followed by Rica Vicente, Jaden Dijkstra, Harsh Patel and Malik Sultan; end with Assets generated by Codex. Updated scripts/game.gd and tests/ui.gd; removed superseded partner/artwork line. Requirements UI1/UI6/UI8/UI9. No gameplay changes. Graphical Godot 4.7.2 check: --path . --script res://tests/ui.gd, exit 0 and UI TEST FAILURES: 0. No human playtest. Supersedes earlier role descriptions for the on-screen Credits only. Branch fix/credits-team-list; changes local, not pushed.


## Alphabetical credits correction - November 20, 2026

Request summary: put Ctrl-Alt-Elite before Server-side project and alphabetize names. Credits now reads Ctrl-Alt-Elite - Server-side project, with Harsh Patel, Jaden Dijkstra, Malik Sultan, Rica Vicente. Client names are Anna-Marie Oyemiren then Olaniyi Tolulope. Names sorted by first name within each team. Updated scripts/game.gd and tests/ui.gd; README.md/status.md/prompt_log.md maintained (UI1/UI6/UI8/UI9). Graphical Godot 4.7.2 --path . --script res://tests/ui.gd exited 0, UI TEST FAILURES: 0. No gameplay changes or human playtest; local changes not pushed. Supersedes prior displayed order.


## Server credits order - November 20, 2026

Request summary: put Jaden Dijkstra first in the server-side list. Updated scripts/game.gd and existing tests/ui.gd expected text to Jaden Dijkstra, Harsh Patel, Malik Sultan, Rica Vicente; other credits unchanged. UI1/UI6/UI8/UI9. README.md/status.md/prompt_log.md updated. Verified exact ordered text in script and UI expectation; git diff --check passed. Graphical Godot 4.7.2 --path . --script res://tests/ui.gd passed (exit 0, UI TEST FAILURES: 0); no gameplay changes. Local changes not pushed.


## Direct Solo and multiplayer lobby - November 20, 2026

Request summary: remove Play/Choose Your Crew and main-menu Help; add Solo and Multiplayer, Solo goes directly into its game and Multiplayer opens a lobby based on supplied screenshot, styled consistently with main menu. Implemented direct Solo, matching frost-blue/evergreen lobby with Host/Join/Exit/List Games, empty available-games list and inactive game ID field. Exit returns to main menu; existing local duel is accessible from lobby to preserve gameplay. Help remains under Controls. There is no networking/discovery implementation in this repository: Host/Join/List Games and address entry are clearly unavailable pending the server project, requested from user. No invented sessions, user names, IPs or server protocols.

Files: scripts/game.gd, tests/ui.gd, tests/preview.gd, tests/menu-preview.png, tests/lobby-preview.png; README.md/status.md/prompt_log.md. Requirements UI1/UI5/UI6/UI8/UI9. Godot 4.7.2 smoke passed 33 checks; graphical --path . --script res://tests/ui.gd exited 0, UI TEST FAILURES: 0; screenshot command --path . --script res://tests/preview.gd -- --lobby exited 0. Inspected both screenshots: layout fits and theme matches. Preview reported two ObjectDB shutdown leaks; headless smoke has existing log/certificate errors and two leaks. No full human playtest, no networking verification. Earlier Play/crew-menu descriptions superseded. Branch feat/direct-solo-multiplayer-lobby, changes local and not pushed.


## Lobby branding update - November 20, 2026

Request summary: remove List Games, add Moooze Tanks logo to lobby and remove slash between game name and Multiplayer Lobby. Updated scripts/game.gd to reuse original menu logo at 86 pixels and show MOOOZE TANKS MULTIPLAYER LOBBY. Available-games panel retained; Host/Join remain unavailable pending server integration. Updated tests/ui.gd and refreshed tests/lobby-preview.png using tests/preview.gd -- --lobby. UI1/UI6/UI8/UI9; no gameplay changes. Godot 4.7.2 graphical UI suite passed, exit 0 / UI TEST FAILURES: 0. Graphical preview exited 0 and was visually inspected for logo, title, removed button and viewport fit. git diff --check passed for changed text files. README.md/status.md/prompt_log.md updated. Branch fix/lobby-logo-title; local, not pushed.


## Tank overhead vitals and server user ID - November 20, 2026

Request summary: move each player health/lives above their tank; user ID above health bar and a heart with lives count beside it. Added player-owned upright, non-interactive overhead UI and user_id string property (server assigns tank.user_id; local fallback Player 1/Player 2 until supplied). Label truncates long IDs with ellipsis and keeps full text as tooltip. Health bar max 100 tracks exact current health; heart count updates on life loss. Existing damage/healing/respawn/elimination logic unchanged. Removed fixed heart/fuel HUD rows; score/timer/power-ups/pause remain in top HUD. Help text updated. No network protocol or authoritative server health contract invented; server integration remains pending. UI2/UI3/UI5/UI6/UI8/UI9.

Files: scripts/player.gd, scripts/game.gd; tests/tank_vitals.gd, tests/hud_values.gd, tests/smoke.gd, tests/ui.gd, tests/preview.gd, tests/tank-vitals-preview.png; README.md/status.md/prompt_log.md. Godot 4.7.2: 17 overhead-vitals, 33 smoke, 45 power-up, 16 co-op and 16 brick-respawn checks passed. Graphical UI suite --path . --script res://tests/ui.gd passed, UI TEST FAILURES: 0. Preview --path . --script res://tests/preview.gd -- --tank-vitals exited 0 and was visually inspected for distinct IDs, 65%/40% health and 2/3 lives. First focused run had an incorrect Control.global_rotation test reference, fixed; smoke exact-child-count assertion replaced with explicit collision/chassis/turret checks for added UI. Existing headless log/certificate errors and 2-10 shutdown leak warnings remain; no full human playtest. Historical gas-tank HUD descriptions superseded. Local branch feat/tank-overhead-vitals; not pushed.


## Reference health-bar layout - November 20, 2026

Request summary: heart on LEFT of health bar; health display should match supplied screenshot. Changed scripts/player.gd: green 112x28 health bar with red centered user ID inside, percentage hidden; heart/lives to left. Existing dynamic fill, ID assignment and gameplay preserved. Updated tests/tank_vitals.gd assertions and tests/tank-vitals-preview.png. Requirements UI2/UI6/UI8/UI9. Godot 4.7.2: --headless --path . --script res://tests/tank_vitals.gd passed 19 checks; smoke.gd passed 33. Graphical --path . --script res://tests/preview.gd -- --tank-vitals exited 0 and screenshot inspected for red ID in bar, left heart and partial health. Existing headless log/certificate errors and two shutdown leak warnings remain; no human playtest. README.md/status.md/prompt_log.md updated. Supersedes earlier ID-above-bar/right-heart layout. Branch fix/tank-vitals-reference-layout; local changes not pushed.


## Icy health nameplate and removal of Help - November 20, 2026

Request summary: match newly uploaded icy Player 1 health-bar reference; remove Help everywhere including Controls. Updated player overhead vitals with original SVG snowy navy nameplate, cyan antlers/trim, white user ID and bright green striped health fill below; heart/lives remain LEFT per prior request. Live health, server-assigned user_id, lives and gameplay preserved. Removed show_help/show_powerup_help screens and Controls Help link, and their preview/test calls. Controls screen retained. Historical documentation/screenshots remain as history, not live Help UI.

Files: scripts/player.gd, scripts/game.gd; assets/vitals_plate.svg, assets/vitals_fill.svg and Godot import metadata; tests/tank_vitals.gd, tests/ui.gd, tests/smoke.gd, tests/preview.gd, tests/tank-vitals-preview.png; README.md/status.md/prompt_log.md. UI2/UI5/UI6/UI8/UI9. Godot 4.7.2 editor import exited 0 without parser errors; 19 tank-vitals and 33 smoke checks passed with --headless --path . --script res://tests/<suite>.gd. Graphical tests/ui.gd exited 0 with UI TEST FAILURES: 0, checking Controls and absence of Help screens. Graphical preview --path . --script res://tests/preview.gd -- --tank-vitals exited 0; final image inspected for snowy nameplate, live partial fill, cyan bottom edge and left heart. Adjusted bar size after styles to avoid default-theme height obscuring trim. Search found no Help/show_help/show_powerup_help in gameplay scripts. git diff --check passed. Existing headless log/certificate/editor-settings errors and 2-9 shutdown leak warnings remain; no full human playtest. Supersedes earlier Help availability and plain red-ID bar descriptions. Local branch feat/icy-healthbar-remove-help; not pushed.


## Shared icy winter menu theme - November 20, 2026

Request summary: style main menu like uploaded winter reference and apply matching design to lobby/other screens and gameplay HUD without changing the game. Adapted portrait reference to existing 1280x800 landscape viewport: snowy navy/cyan frame, illustrated mountains/pines/snow/tank backdrop, retained original logo, bold title, prominent Solo/Multiplayer cards with tank icons/arrows, and Controls/Sound/Credits/Exit icons. Shared panel/button styling applies to lobby, Controls, Sound, Credits, pause/results and top gameplay HUD. Tank overhead health/lives and gameplay remain unchanged. Help remains removed. Existing callbacks, button names/accessibility, volume, score/timer, controls and network-disabled state preserved. Copy describes current game honestly rather than promising AI combat or connected networking from reference.

Files: scripts/game.gd; new original assets/menu_winter.svg, menu_panel.svg, menu_button.svg, menu_tank.svg, menu_controls.svg, menu_sound.svg, menu_credits.svg, menu_exit.svg and imports; tests/ui.gd, tests/preview.gd and refreshed menu/lobby/play/controls/sound/credits/pause/results/game/coop previews. README.md/status.md/prompt_log.md maintained. Requirements UI1/UI2/UI3/UI4/UI5/UI6/UI8/UI9. No physics, damage, movement, spawning or networking changes. Branch feat/icy-menu-theme, local and not pushed.

Actual verification: Godot 4.7.2 editor import exited 0 without parser/script errors. Graphical --path . --script res://tests/ui.gd exited 0, UI TEST FAILURES: 0, including new menu bounds and logo lookup assertions. Headless smoke (33), tank_vitals (19) and brick_respawn (16) checks passed. Full graphical tests/preview.gd exited 0; inspected menu, lobby, Controls, Sound, Credits, pause, results and gameplay HUD captures for fit/readability/consistent styling. git diff --check passed. Existing headless certificate/log/editor-settings errors and 2-5 shutdown leaks remain; no full human playtest. Original reference is visual guidance, adapted with code-native SVG artwork and existing logo, not a pixel-identical portrait reproduction. Earlier evergreen-menu styling descriptions superseded.


## Angry moose warning and sketch vitals - November 20, 2026

Request summary: shot moose should visibly shake angrily with steam from ears before charging next available tank; overhead health/lives should match supplied heart-and-bar sketch and become translucent while moving near bricks/moose. R7/R8/R9, UI2/UI3/UI6/UI8/UI9. scripts/moose.gd now has a 0.8-second stationary wind-up, sprite shake/red tint, outlined rising steam from both ears, pulsing warning ring and exclamation, then existing 300px/s charge with full two-second duration. Retargets nearest active tank; repeated hits cannot endlessly restart warning. Pause freezes warning. scripts/player.gd now shows lives number inside large left heart, user ID above adjacent green health bar. Smoothly fades vitals to 35% opacity while moving within 100px of an intact brick (including perimeter) or moose; stopping/leaving proximity restores full opacity. Existing health/lives values, scoring, movement, projectile rules and number of moose preserved. Wind-up is the requested new pre-charge delay.

Files: scripts/moose.gd, scripts/player.gd; assets/vitals_heart.svg and import; tests/moose_charge.gd, tests/tank_vitals.gd, tests/preview.gd; tests/angry-moose-preview.png and tests/translucent-vitals-preview.png. README.md/status.md/prompt_log.md updated. Branch feat/angry-moose-compact-vitals, local not pushed.

Actual validation in Godot 4.7.2: 27 tank-vitals, 33 smoke, 45 power-up, 19 forest checks passed, including 30-second containment. Graphical moose_charge suite passed 21 assertions, UI suite exited 0 with UI TEST FAILURES: 0. Commands use --headless --path . --script res://tests/<suite>.gd for non-graphical checks; graphical --path . --script res://tests/moose_charge.gd and tests/ui.gd. Preview --path . --script res://tests/preview.gd -- --angry-moose exited 0; final angry/steam and translucent-vitals images inspected. Initial type-inference parser error fixed with explicit bool before final successful runs. Preview restart sequence corrected to avoid trying to remove an already detached world. Existing headless logs/certificate/editor-settings access errors and 2-9 ObjectDB shutdown warnings remain. No full human balance/audio playtest. Supersedes prior icy nameplate layout with latest sketch.


## Eight-second power-up duration - November 20, 2026

Request summary: all acquired power-ups should stay on tanks for 5-10 seconds. Default chosen: eight gameplay seconds for every power-up (existing shield/speed duration). Heavy is now time-based, providing heavy shots for the full eight seconds instead of a five-round limit; cadence, damage and blast radius unchanged. Health still heals 35 immediately up to 100 and never revives/adds lives; visible recovery heart/ring now lasts eight seconds and expires without removing healed health. Shield/speed retain eight seconds. Countdown status for heavy and recovery added. Repeated pickups refresh to eight seconds; pause freezes timers; losing a life/restart/menu clears effects as before. No timer accumulation. User explicitly confirmed: Unlimited heavy shots for 8 seconds.

Files: scripts/player.gd, scripts/powerups.gd; tests/powerups.gd, tests/duel.gd, new tests/powerup_duration.gd. README.md/status.md/prompt_log.md maintained. R3/R5/R7/R8, UI2/UI3/UI6/UI8/UI9. Branch fix/powerup-eight-second-duration, local not pushed.

Actual checks in Godot 4.7.2: headless --path . --script res://tests/powerup_duration.gd passed 17 assertions (real eight-second gameplay timer on both players, still active after 5.1 seconds, pause, expiry, health persistence, more than five heavy shots and refresh); existing powerups.gd passed 45, smoke.gd passed 33, duel.gd passed with DUEL TEST FAILURES: 0. Graphical --path . --script res://tests/ui.gd exited 0 with UI TEST FAILURES: 0, including combined co-op countdown bounds. git diff --check passed. Existing headless log/certificate errors and two shutdown leak warnings remain; no full human balance playtest. Supersedes historical five-shot heavy and two-second recovery feedback descriptions.


## Thirty-second radial power-ups and distinct impacts - November 20, 2026

Request summary: green heart-outline shield, circular elapsed timers for all power-ups lasting 30 seconds, angry moose-shot sound and a different tank-hit sound. Updated shared DURATION to 30 gameplay seconds, superseding prior eight-second default. Each active power has an icon, colored shrinking circular ring and remaining-seconds number below its tank. Shield now draws a green heart outline around tank and uses matching green-heart pickup/timer icon. Unlimited heavy shots continue for duration; healing remains immediate with 30-second recovery feedback. Pause/refresh/life-loss/reset semantics preserved. Added synthesized angry moose growl on provoked signal and separate metallic tank-impact sound on accepted damage from projectile or moose; protected/blocked hits do not sound, final hits preserve impact plus explosion. Ambient emergence roar retained. Volume/mute/pause respected.

Files: scripts/player.gd, scripts/powerups.gd, scripts/game.gd, scripts/sound.gd; assets/powerup_shield_heart.svg, assets/audio/moose_angry.wav, tank_hit.wav and import metadata; tools/generate_impact_audio.py and assets/audio/LICENSE.txt; tests/powerup_duration.gd, powerups.gd, sound.gd, moose_charge.gd, preview.gd and tests/powerup-timers-preview.png. README.md/status.md/prompt_log.md updated. R1/R3/R5/R7/R8, UI2/UI3/UI6/UI8/UI9. Branch feat/powerup-radial-timers-hit-audio, local not pushed.

Actual Godot 4.7.2 verification: editor import exited 0 without parser errors. Headless duration suite passed 17 checks over real 30-second gameplay interval; powerups 45 and smoke 33 passed. Graphical moose_charge passed 21 checks and sound passed 37, UI suite exited 0 / UI TEST FAILURES: 0. Commands --headless --path . --script res://tests/<suite>.gd for headless suites; --path . --script res://tests/sound.gd, moose_charge.gd, ui.gd graphically. Preview --path . --script res://tests/preview.gd -- --powerup-timers exited 0; inspected full 30-second and half 15-second rings, green heart shield and HUD layout. git diff --check passed. Existing certificate/log/editor-settings access errors and 2-19 ObjectDB shutdown leaks remain. Playback checks do not establish perceived quality or physical audio output; human listening/balance test outstanding. Original sounds/assets preserved.


## Shield silhouette correction - November 20, 2026

Request summary: shield power-up should be a shield shape around the tank. Replaced heart-outline protection with a green shield silhouette around tank in scripts/player.gd, and selected matching new assets/powerup_shield_green.svg in scripts/powerups.gd. Green color, protection behavior, 30-second duration and circular countdown unchanged; health/lives heart unchanged. Requirements R1/UI2/UI6/UI8/UI9. Refreshed tests/powerup-timers-preview.png and maintained README.md/status.md/prompt_log.md. Godot 4.7.2 import exited 0 without parser errors; --headless --path . --script res://tests/powerups.gd passed 45 checks. Graphical --path . --script res://tests/preview.gd -- --powerup-timers exited 0 and screenshot inspected. Existing import/headless certificate/log/editor-settings access errors remain. No human playtest. Supersedes earlier heart-outline shield description; branch fix/shield-outline-shape, local not pushed.


## Arena visuals and power-up balance - November 27, 2026

Current behavior (supersedes earlier 30-second and health-pickup descriptions): the arena HUD uses the main-menu logo. Horizontal decorative grass ends inside the arena sides; perimeter collisions are unchanged. Heavy and speed last 10 gameplay seconds; shield lasts 7 seconds. Each heavy projectile hitting an active shield subtracts 2 additional seconds, clamped to zero. That hit is absorbed even when it exhausts the shield; subsequent hits can damage the tank. Normal shots do not subtract extra shield time. Pause and respawn protection prevent hit-driven depletion. Circular timers use each effect's own duration. Health pickups and recovery feedback are removed; health/lives and normal respawning remain. Eight initial rewards now comprise three heavy, three shield and two speed pickups; replacement rewards use only these three types. Original unused artwork is preserved.

Requirements: R1/R3/R5/R7/R8/R9, UI2/UI3/UI6/UI8/UI9. Files: scripts/game.gd, player.gd, bullet.gd, powerups.gd; tests/powerups.gd, powerup_duration.gd, duel.gd, ui.gd, preview.gd, powerup-timers-preview.png; README.md, status.md, prompt_log.md.

Actual validation: installed engine reports 4.7.2.stable.official.ed1daf0bf. Editor import exited 0 without parser errors. Headless smoke (33 checks), powerups (39 checks), powerup_duration (17 checks) and duel suites exited 0 with zero failures. Graphical UI suite exited 0 with zero failures. Graphical preview.gd -- --powerup-timers exited 0; inspected refreshed screenshot for logo, grass bounds and full/partial countdown rings. Commands use the README executable with --path . --script res://tests/<suite>.gd, adding --headless for those four suites. Known environment errors remain for log writing, certificate-store access and editor-settings saving; smoke/duration reported 4/19 ObjectDB shutdown leaks. These are automated runtime checks and screenshot inspection, not a full human playtest. Changes are in the Documents/GitHub repository on local main; the separate Desktop/Codexdemo copy was not edited. No online multiplayer integration was added.
