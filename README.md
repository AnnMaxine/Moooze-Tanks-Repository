# Moooze Tanks

## Project Overview

Moooze Tanks is a playable 2D top-down tank game with Solo Practice and same-computer Local Co-op. Move, aim, and shoot to clear 35 destructible bricks, earn points, and finish the practice field. @Studio develops the client side, working with Ctrl-Alt-Elite, the server-side development team. The Requirements Management Plan sets the Alpha Demo milestone for October 20, 2026.

Source: [ReqMgmtPlan.docx](ReqMgmtPlan.docx). The requirement tables retain the source IDs and acceptance criteria. Implementation and verification details are reported separately below.

## Inspection Status

Mechanics review, November 10, 2026 (R1/R5/R6/R8/R9, UI2/UI3/UI4/UI6/UI8/UI9): retained direct WASD movement and the elapsed match clock as explicitly confirmed by the user. Movement is normalized at 235 px/s, with immediate input release and smooth chassis rotation toward travel; A/D do not pivot the tank in place. Turret aiming remains independent. Existing CharacterBody2D movement blocks/slides against the indestructible perimeter and destructible cover. Solo/co-op spawn points are clear of solid geometry; respawn restores health while preserving the field and score.

Moose spawning remains one initial group of four at the forest corners, with staggered emergence at 0.6-1.35 seconds. The user explicitly declined additional moose; there are no reinforcement waves. Added invisible Area2D contact triggers to the existing moose, monitoring only tank bodies through entry/exit signals. The 45px combined contact reach, 20 damage, two-second tank protection, separation-before-repeat rule, knockback, roar, charge and final-life explosion remain. No new environmental objects or visual changes. Area2D overlap notifications are delivered on physics steps, so recoil can be observed one step later than the previous distance-only detection.

The existing elapsed timer advances during play, freezes during pause/defeat/results and resets on restart. It remains a stopwatch, not a countdown or timeout rule. New `tests/mechanics.gd` covers all WASD directions/releases, diagonal speed, chassis facing, spawn clearance, timer lifecycle and Area2D entry/exit/filtering. Run with the same Godot command below using `--script res://tests/mechanics.gd`.

On October 20, 2026, a Godot project was created in this workspace after inspecting the existing documentation. No pre-existing tank scripts or assets were available to reuse. The original requirements document and formal team list were preserved.

The source marks R1 In Progress and R2–R9 and UI1–UI9 To Be Confirmed. These are source-reported statuses, not independently verified results.

R1–R9 now have implementations. Godot 4.7.2 successfully imported the project, and 20 automated engine checks passed: menu loading, arena creation, movement/release, independent aiming and attachment, firing, collisions, wall sliding, brick destruction, movement through cleared space, projectile lifetime, pause/resume, results, replay, and cleanup. Menu and arena screenshots were also rendered and visually inspected. These checks do not replace a full human playtest.

The game includes Solo Practice, Local Co-op / 2 Players, Controls/Help, Credits, Exit, a score/health/lives HUD, pause/resume/restart, and field-clear results. Host Game and Join Game remain disabled pending server integration. Each tank starts with 100 health and 3 lives. Damage handling and respawning exist, and roaming moose now provide contact damage; friendly fire remains disabled.

## Team

@Studio — Client-Side Development Team

| Member | Role in the plan's formal team section |
| --- | --- |
| Olaniyi Tolulope | Product Design & Business Analysis |
| Anna-Marie Oyemiren | Game Design & Project Operations |

The team names and roles above follow the plan's formal team section, as confirmed by the user. Use this list for documentation rather than the names in the plan's overview.

Project partner: Ctrl-Alt-Elite — Server-Side Development Team.

## Godot Version

The plan specifies Godot 4, version 4.7.2. Development and checks used the installed Godot 4.7.2 stable Windows build, matching that version. The project uses GDScript and the Compatibility renderer; it requires no external packages or downloaded assets.

## Game Features and Acceptance Criteria

| ID | Required feature | Acceptance criteria |
| --- | --- | --- |
| R1 | Player Sprite | Chassis is visible in the arena, correctly oriented, and positioned for movement and collision detection. |
| R2 | Turret Sprite | A visually separate turret stays attached and rotates independently without rotating the chassis. |
| R3 | Bullet Sprite | Firing creates a visible projectile that is removed on a valid hit or at its defined lifetime. |
| R4 | Brick Sprite | A visible brick has an appropriate collision shape, blocks movement, and can be destroyed by a projectile. |
| R5 | WASD movement | Tank moves in the intended directions, responds to inputs, stops when relevant keys are released, and cannot pass through bricks. |
| R6 | Turret Movement | Turret continuously faces the mouse independently of chassis movement and maintains its attachment. |
| R7 | Shooting | Left-click spawns a projectile from the turret or muzzle; it travels in the intended direction and can hit a brick. |
| R8 | Collisions and Destruction | Tank cannot pass through or stick to bricks. A projectile hit removes the brick and its movement obstruction. |
| R9 | Player Arena | Arena is visible at startup, has a brick perimeter preventing escape, and provides enough room to move, aim, and shoot. |

The Alpha overview focuses on R1–R8; the requirements table also contains R9. The implementation uses destructible pale ice interior bricks and an indestructible forest tree perimeter to preserve arena containment. This is an implementation choice where the source leaves perimeter destructibility unspecified.

## Broader UI and Documentation Baseline

The plan distinguishes the broader UI baseline from minimum Alpha gameplay mechanics.

| ID | Requirement | Expected behavior or content |
| --- | --- | --- |
| UI1 | Main Menu | Host Game, Join Game, Solo Practice, Controls/Help, Credits, and Exit; implemented options respond to mouse input and open the appropriate screen or action. |
| UI2 | Gameplay HUD | Readable health/lives and score when implemented, updated from gameplay events and the agreed data source. |
| UI3 | Pause Overlay | Open the overlay, resume gameplay, and access other approved pause actions. |
| UI4 | Results Screen | Accurately display available match completion information and the round winner. |
| UI5 | Controls/Help Screen | Readable keyboard and mouse instructions accessible from the main menu. |
| UI6 | README.md | Project overview, prerequisites, opening/running instructions, and project structure. |
| UI7 | AGENTS.md | Agent conventions, development rules, testing instructions, and file modification restrictions. |
| UI8 | status.md | Requirement IDs, statuses, completed and outstanding work, and latest update date. |
| UI9 | prompt_log.md | Prompts, dates, relevant changes, results, and follow-up tasks. |

Credits and exit functionality are also explicitly included in the broader scope and are implemented. UI1 is partial because Host/Join require server integration. UI2 shows score and each active mode's player health/lives. UI4 reports solo or shared local co-op completion statistics, not competitive multiplayer winners. UI8 is tracked in `status.md`; UI9 has an existing `prompt_log.md`, which was not updated in this task.

## Controls

| Input | Required action |
| --- | --- |
| W, A, S, D | Move up, left, down, right |
| Mouse movement | Aim the turret |
| Left mouse button / hold | Fire projectiles |
| Arrow keys | Player 2 movement in Local Co-op |
| T / F / G / H | Player 2 aim up / left / down / right; combine for diagonals |
| J / hold | Player 2 fires snowballs |
| Esc or Pause button | Pause/resume; access restart and main menu |

Implementation defaults: normalized movement at 235 pixels/second, a 0.22-second firing interval, projectiles at 780 pixels/second with a 1.8-second lifetime, and 100 points per destroyed brick. These are adjustable implementation choices rather than additional source requirements. Clearing all 35 interior bricks completes the round.

## Setup and Running

Prerequisite: Godot 4.7.2 (standard edition; .NET is not needed).

1. Open Godot's project manager and select Import.
2. Choose `project.godot` in this folder and open the project.
3. Allow the SVG assets to import, then press F5 (Run Project). The configured entry scene is `scenes/main.tscn`.
4. Select Play, then Solo Practice or Local Co-op / 2 Players. Destroy all pale ice bricks, then use Play Again or Main Menu on the results screen.

To rerun automated checks from this folder in PowerShell (adjust the executable path for another machine):

```powershell
& 'C:\Users\ANNAMARIE\Desktop\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --import --quit
& 'C:\Users\ANNAMARIE\Desktop\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tests/smoke.gd
```

The smoke test exits with a nonzero status on failed assertions. Also inspect console output for engine errors. `tests/preview.gd` can be run without `--headless` to capture menu and arena PNGs and exit automatically. A manual check should confirm aiming and firing feel, menu mouse navigation, Escape pause/resume, and window resizing on the target machine.

## Project Structure

Project files:

```text
Moooze Tanks/
├── ReqMgmtPlan.docx   # Requirements Management Plan
├── README.md         # Project overview and requirements summary
├── AGENTS.md         # Instructions for Codex
├── project.godot     # Engine configuration and entry scene
├── scenes/
│   └── main.tscn     # Main game scene
├── scripts/
│   ├── game.gd       # Arena, menus, HUD, score, particles, round lifecycle
│   ├── player.gd     # Chassis movement, turret aiming, fire input
│   ├── bullet.gd     # Swept projectile collision and lifetime
│   └── brick.gd      # Collision, destruction, reinforced boundary
├── assets/           # Original tank, turret, bullet, and brick SVGs
└── tests/            # Engine smoke test and rendered preview capture
```

The `.godot/` folder is generated by the editor and ignored by Git. Scenes and physics/UI nodes are constructed by the scripts from the main scene. Original vector assets use Sprite2D textures and require no external art service.

## Local Co-op extension ? October 26, 2026

This user-authorized extension maps to R1/R2 (second chassis and attached turret), R3/R7 (independent snowball firing), R5/R6 (independent movement and aiming), and R8/R9 (shared collisions and contained arena). Original R1?R9 acceptance criteria remain unchanged: Player 1 still uses WASD, mouse aim, and left-click; Player 2 adds keyboard equivalents. R4 ice walls remain unchanged. UI1?UI5 cover mode selection, both players' HUD values, shared pause/restart, results, and help; UI6/UI8 document this extension. No requirement IDs have been replaced or renumbered.

Choose **Local Co-op / 2 Players** from the main menu. Player 1 is blue and Player 2 is purple. Player 2 keeps its last aim when aim keys are released. Both players share points, shots counted in results, and the 35-brick field objective. Tanks do not block or damage each other; both are blocked by bricks and the perimeter. Each player respawns at its own starting position with 100 health after losing a life. If damage is invoked, the surviving teammate can continue; Game Over occurs when both have no lives. Replay and restart preserve the selected mode. Solo Practice remains available with its existing HUD and behavior.

Validation: Godot 4.7.2 import completed without script/parser errors; all 32 existing smoke checks and 16 new local co-op checks passed. Run the latter with the same engine command above and `--script res://tests/local_coop.gd`. The graphical preview script now also captures `tests/coop-preview.png`; the menu and co-op HUD/tank colors were visually inspected. Engine environment errors accessing logs, certificates, and editor settings remain.

Manual testing still needed: two people using simultaneous physical keys/mouse (keyboard rollover and comfort), diagonal keyboard aiming, menu/pause navigation, and resizing. Automated input actions and screenshots do not establish a full human playtest. Network multiplayer remains unimplemented. Moose contact damage was added on October 30, 2026.

## Sound effects - October 26, 2026

Final-life explosion follow-up (November 6, 2026; R1/R8, UI2/UI3/UI4/UI6): a tank losing its final life disappears into a one-second fireball, smoke, shockwave and metal debris at its last position. The existing explosion sound starts immediately. When no teammates remain, gameplay and match time freeze; Game Over appears only after the visual delay and explosion playback finish. Mute retains the visual delay without waiting for an audio signal. A surviving co-op teammate keeps playing. Restart/menu cleanup removes effects and cancels the pending defeat transition. Original damage, health and life counts remain unchanged.

Follow-up validation in Godot 4.7.2: editor import, 33 smoke checks, 16 co-op checks, 40 graphical UI checks and 35 graphical audio checks passed. The explosion screenshot was rendered and inspected using `--path . --script res://tests/preview.gd -- --explosion` (`tests/explosion-preview.png`). No script errors; environment log/certificate/editor-settings errors and shutdown ObjectDB leak warnings remain. Automated playback and screenshots do not replace speaker listening or a human playtest.

November 6, 2026 update (R5/R8, UI3/UI4/UI6): reused the existing original WAV assets and increased idle engine, driving engine, obstacle destruction and tank explosion levels. Accepted moose contact now plays a louder roar than ambient emergence calls, including boosting an already-playing roar without layering another voice. Volume/mute still applies. Existing explosions on each lost life remain, including the final moose hit into Game Over. The last obstacle's destruction sound now continues into field-clear results instead of being stopped immediately.

Verification for this update: installed Godot version confirmed as 4.7.2; editor import completed, 29 graphical audio checks and 32 headless smoke checks passed with no script errors in the final runs. Existing environment errors remain for log/root-certificate/editor-settings access, plus two ObjectDB instances leaked at smoke-test shutdown. Perceived loudness, sound quality and physical speaker output still need human listening; these checks verify playback/state behavior.

Original synthesized WAV effects in `assets/audio/` provide a snowball pop for either player's shot, ice-breaking chimes, soft explosion bursts, a quiet shared engine loop during actual tank motion, and menu/pause button clicks. These were generated for this project from mathematical tones and noise; no third-party recordings, downloads, or attribution requirements are involved.

Open **Main Menu > Sound** to adjust volume from 0 to 100; **0 mutes all sounds**. Default volume is 65%. The setting lasts for the current application session and resets on relaunch. Effects use conservative individual levels, at most two concurrent shooting voices and one voice per other effect. Repeated impact sounds within 90 ms are coalesced, including the existing duplicate visual burst on brick impacts. Engine sound stops on movement release, pause, or leaving gameplay. The gameplay, visuals and controls are unchanged.

The requirements plan has no dedicated sound requirement. This user-authorized enhancement maps to existing R7 (shooting feedback), R8 (destruction/impact feedback), R5 (movement feedback), UI1/UI3 (button feedback and sound controls/pause), and UI6/UI8 (documentation/status). It adds no requirement ID and changes no original acceptance criteria.

Validation: 32 smoke checks, 16 co-op checks, and 13 audio checks passed in Godot 4.7.2. The audio suite ran with the graphical renderer using `--path . --script res://tests/sound.gd`; it checks loaded streams, playback state, bounded voices, duplicate suppression, movement start/stop, pause, mute, and volume control. Main-menu preview inspected. These checks do not verify perceived sound quality or physical speaker output. Listen manually while both players fire, break bricks, hit the reinforced perimeter, move/stop, pause, click buttons and adjust/mute volume. Confirm comfortable levels on your own speakers/headphones. Existing environment errors for logs, certificates and editor settings remain; no script errors were reported.


## Christmas forest and moose - October 30, 2026

Forest border revision (November 6, 2026; R9/UI6/UI9): removed the two extra decorative evergreen layers at the user's request, restoring only the original solid border trees while retaining the grass tufts. Collision geometry, playable space and gameplay remain unchanged. This supersedes the dense-tree appearance recorded in prompt-log Entry 33.

Snowball provocation update (November 6, 2026; R3/R7/R8/R9, UI3/UI5/UI6): either player's snowball is consumed on a moose hit, triggering the existing loud contact roar and a charge toward the closest active tank by straight-line distance, regardless of who fired. Charge speed is 300 pixels/second for up to 2 seconds. The moose tracks its selected tank, retargets if that tank is eliminated, and resumes roaming on tank contact, wall collision, timeout or loss of all targets. Each new hit refreshes the charge and selects the nearest tank again; simultaneous roars share one voice. Hits can interrupt emergence. Bricks intercept shots before moose behind them, and tanks still cannot shoot each other. Existing 20-damage contact, protection, knockback, lives, final explosion, scoring and arena containment remain unchanged. Pause freezes charges; mute suppresses audio only. These charge settings are implementation defaults for this request, not changes to the source acceptance criteria.

Run `tests/moose_charge.gd` with the existing Godot command and a graphical renderer to verify snowball impacts, nearest-target selection, roar playback, charge movement/contact, elimination retargeting, pause, walls, timeout, mute and cleanup. Speaker loudness and charge difficulty still require a human playtest.

Validation: Godot 4.7.2 version confirmed and editor import completed without script/parser errors. Passed 18 graphical charge checks, 33 smoke, 16 co-op, 35 graphical sound, 40 graphical UI and 18 forest checks (160 total), including the 30-second containment run. Existing log/root-certificate/editor-settings access errors and shutdown ObjectDB leak warnings remain. `git diff --check` passed.

Requirement mapping: R4 covers the restored icy brick appearance; R8/R9 cover roaming contact hazards, brick collisions and containment; UI2/UI3 cover health feedback and paused hazards; UI5 covers updated help; UI6/UI8 cover this requirements summary and status. These are user-authorized extensions to existing IDs, not new source-plan requirements or changed Alpha acceptance criteria. `ReqMgmtPlan.docx` remains the original baseline.

The 35 destructible walls use the original icy brick texture. Only the indestructible perimeter uses snow-dusted evergreen tree sprites, with the original 48 x 40 collision geometry and unchanged arena dimensions/layout. This follows the requested visual correction: an actual forest border, not stacked logs. Original and earlier SVG assets remain available. Winter background, snow, lights, both tanks, controls, shots, score, lives and sound effects remain in place.

Decorated corner Christmas trees have been removed; only the forest perimeter trees remain. Four animated vector moose start near the corners after staggered 0.6-1.35 second delays, walk at 68 pixels/second, periodically turn and bounce off bricks. Moose are yielding contact obstacles, not solid barriers to tanks: they turn away on contact and cannot pin a tank against a wall. Snowballs now stop on moose and provoke a charge (November 6 update below); moose remain indestructible and award no points. The forest perimeter retains its collision boundary.

Each fresh moose contact deals 20 health damage through the existing local tank damage method. Each tank has its own 2-second protection timer shared across all moose, shown by a gold ring. Sustained overlap cannot repeatedly damage a tank without separation; losing a life grants protection on respawn. Moose motion and protection timers freeze during pause, and restart replaces the herd and resets protection. These values are implementation defaults for this requested enhancement, not source-plan values or network contracts.

New files: `scripts/moose.gd`, `assets/moose.svg`, `assets/christmas_tree.svg`, `assets/forest_brick.svg`, `assets/forest_reinforced.svg`, and `tests/forest.gd`. Existing `game.gd`, `player.gd`, `brick.gd` and preview timing are updated.

Run the new behavioral suite with the verified Godot executable above and `--headless --path . --script res://tests/forest.gd`. It exercises emergence, both players' contact damage/HUD, shared cooldown, recontact, sustained overlap, pause, obstacle collisions, free tank movement, respawn, restart, extended roaming and cleanup. Graphical previews show the forest perimeter and roaming moose; screenshots do not establish animation quality or a full human playtest.

Validation on October 30: installed Godot 4.7.2 confirmed; import completed without script/parser errors. All 32 smoke, 16 local co-op, 13 graphical sound, and 16 forest checks passed, including a 30-second contained roam. Rendered co-op screenshot inspected after updating tank draw order. Existing environment errors remain for log writes, root certificates and editor settings; these are not reported as clean engine output. No full human playtest performed.

Forest border correction (October 30): `scripts/brick.gd` restores `assets/brick.svg` for destructible walls and uses new `assets/forest_tree.svg` for the reinforced boundary, removing metal rivets. Help text updated (UI5); R4/R8/R9 preserve destruction and containment. Moose behavior is unchanged.

Border correction verification: Godot 4.7.2 import had no script/parser errors; 32 smoke and 16 local co-op checks passed, including destruction, wall sliding and containment. Updated graphical arena preview inspected. Existing log/certificate/editor-settings access errors remain; full human playtesting is still outstanding.

Corner decoration removal (October 30, R9/UI6/UI8): removed the eight decorated Christmas trees from gameplay, retaining only forest border trees. Moose spawn locations and behavior are unchanged. Updated the existing forest assertions; Godot 4.7.2 import reported no script/parser errors, 32 smoke and 16 forest checks passed, and the updated arena preview was inspected. Existing environment access errors remain; no human playtest performed.


Moose hit feedback (October 30; R5/R8/R9, UI2/UI3, UI6/UI8): accepted moose hits now push either tank away from the moose with a 520 px/s impulse, decelerating at 1800 px/s squared (about 0.29 seconds and 75 pixels at rest in open space). A 0.3-second orange-red tank flash and expanding impact ring/rays make contact visible, including when a wall blocks recoil. Movement input remains available, and turret aiming/shooting remain active. The impulse uses existing swept character movement so icy walls and the forest border block it. The existing 2-second moose damage protection also blocks repeated impulses; pause freezes recoil/flash, and respawn/restart clears them. Damage and lives are unchanged. These are implementation defaults for the requested feedback, not new requirement IDs.

`tests/knockback.gd` checks both players, cooldown, pause, collision containment, respawn cleanup, input/firing during recoil and restart. Run with the usual Godot executable and `--path . --script res://tests/knockback.gd`; graphical mode also captures `tests/hit-preview.png`. Manual two-player testing should confirm recoil strength and visual comfort.

Hit-feedback verification: Godot 4.7.2 import completed without script/parser errors; 32 smoke, 16 co-op, 18 forest and 14 graphical knockback checks passed. Hit-effect screenshot inspected. Existing log/certificate/editor-settings access errors remain. Full human playtesting and subjective recoil/flash comfort are still outstanding.


## Winter interface update - November 3, 2026

The main menu now offers Play, Controls, Help, Sound, Credits and Exit in a consistent evergreen, frost-blue and warm-gold style. Play opens the existing Solo Practice and Local Co-op choices; Host/Join remain visible but disabled pending server integration. Credits use the user-confirmed @Studio names and roles above.

The top HUD includes an original SVG moose seated on a tank, each active player's health/lives, score, remaining icy bricks, shots fired and elapsed play time. All HUD content fits above the existing arena at the 1280 x 800 reference size. Co-op uses the existing **shared team score**, not separate invented scores. The logo is a UI-only asset; tank/moose sprites and collision geometry are unchanged.

Pause offers Resume, Restart and Main Menu. Escape still toggles pause. Restart and Play Again preserve the selected mode. Results show Player 1 as winner on a solo clear, Team P1 + P2 on a co-op clear, and no winner on defeat. They show the actual score, bricks cleared, shots, time and final health/lives. An eliminated teammate remains part of the cooperative team result; there is no competitive ranking or server result contract.

Controls and Help are separate screens. Controls lists both players' movement, aiming and shooting inputs; Help explains the 35-brick objective, 100 points per brick, 100 starting health/3 lives, respawn/elimination, 20-damage moose contact, knockback, two-second protection and indestructible forest perimeter. Sound volume/mute and the recent contact roar remain intact.

Requirement mapping: UI1-UI5 implement menu/HUD/pause/results/controls-help improvements; UI6/UI8/UI9 record them. R1-R9 acceptance criteria and UI7 remain unchanged; ReqMgmtPlan.docx is preserved. Original source statuses are not promoted by these checks.

Validation: Godot 4.7.2 import reported no script/parser errors (exit 0). Graphical UI tests passed 40 checks using viewport mouse/key events for navigation and Escape, with state/data/bounds assertions. Existing checks passed: 32 smoke, 16 local co-op, 18 forest and 25 graphical sound (131 total with UI). Graphical preview captures were inspected for main menu, mode selection, solo/co-op HUD, pause, victory results, controls and help. An initial oversized HUD logo was corrected after screenshot inspection and a strengthened bounds test. Screenshots and automated input do not establish a human playtest.

Run `tests/ui.gd` with the same Godot executable above and `--path . --script res://tests/ui.gd`; run `tests/preview.gd` graphically to refresh screenshots. Existing environment errors remain for user-log/root-certificate/editor-settings access; some test/preview runs reported two ObjectDB leaked instances at shutdown. Human testing should cover two-person input, readability/window resizing on the target display, keyboard focus comfort and audio listening. Network multiplayer remains unavailable.

Mechanics review validation (November 10): Godot 4.7.2 import completed without script/parser errors. Passed 20 mechanics, 19 forest, 33 smoke, 16 co-op, 18 graphical charge and 35 graphical audio checks (141 total). The forest suite includes 30-second containment and the unchanged four-moose population. Existing log/certificate/editor-settings access errors and 2-8 ObjectDB shutdown warnings remain. No visual changes or new screenshots; physical input comfort and audio listening still require human testing.
