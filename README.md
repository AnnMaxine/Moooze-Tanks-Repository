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
| Olaniyi Tolulope | Business Analyst & Product Designer |
| Anna-Marie Oyemiren | Business Analyst & Product Designer |

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


## Block power-ups - November 17, 2026

Updated November 17: eight of the existing 35 destructible icy blocks hide power-ups: two each for heavy ammo, shield, speed and health. All intact icy blocks look alike. Shooting a containing block reveals a floating reward icon for 1.2 seconds and immediately grants its power-up to the shooter in Solo Practice or Local Co-op. Normal blocks retain their original behavior; the forest perimeter remains indestructible. The user confirmed that each power-up should have a distinct visible tank effect.

| Power-up | Effect | Tank feedback |
| --- | --- | --- |
| Heavy ammo | Refills to 5 heavy shots. Each consumes one round and breaks the struck icy block plus unbroken icy blocks whose centers are within 58 pixels of that block. | Orange ring/barrel glow and larger orange projectiles. |
| Shield | Blocks damage and new moose knockback for 8 seconds. | Blue protective bubble. |
| Speed boost | Multiplies movement speed by 1.5 for 8 seconds (352.5 px/s versus the existing 235). | Green trailing chevrons. |
| Health recovery | Immediately restores 35 health, capped at 100; cannot restore lives or revive an eliminated tank. | Heart-shaped reward reveal and a floating pink heart/ring for 2 seconds. |

These are implementation defaults for this user-authorized extension. Different powers coexist; repeated pickups refill ammo or refresh timers rather than accumulate. Pause freezes timers. Losing a life, restarting or leaving gameplay clears active effects. Heavy shots preserve the existing firing interval and projectile lifetime; hitting a moose still provokes its existing charge, and teammates cannot be shot. Splash-destroyed power-up blocks credit the same shooter, with one score award per block. The HUD shows each player's remaining ammunition/effect duration; Main Menu > Help > Power-ups explains all four effects.

Requirement mapping: R1/R3/R4 (effects, projectiles and reward reveals), R5/R6 (boosted movement with independent aim), R7/R8/R9 (shot ownership, blast/destruction, protection and containment), UI2/UI3/UI5 (live status, pause/reset and help), UI6/UI8/UI9 (documentation). Source acceptance criteria/statuses and ReqMgmtPlan.docx remain unchanged; no server contracts were introduced.

Validation in installed Godot 4.7.2: editor import completed without final parser/script errors; 38 power-up, 33 smoke, 16 local co-op, 55 graphical UI and 18 graphical moose-charge checks passed (160 total). Tests include real projectile awards to P2, P1 heavy firing, one-time grants, adjacent destruction/scoring, ammo depletion, projectile cleanup, health caps, shield expiry, boosted input/release/aiming/wall sliding/containment, pause/resume, respawn, restart and cleanup. UI mouse navigation and worst-case combined co-op HUD bounds passed. Graphical power-up arena and help captures were inspected. Existing log/certificate/editor-settings access errors and 2-4 ObjectDB shutdown leak warnings remain; automated tests/screenshots do not establish human balance, readability on other displays, or a full playtest.

Run the focused suite with the existing Godot executable and `--headless --path . --script res://tests/powerups.gd`. Capture the effects/help with `--path . --script res://tests/preview.gd -- --powerups` (graphical renderer required). New captures are `tests/powerups-preview.png` and `tests/powerup-help-preview.png`.


### Hidden rewards and image-based vitals - November 17, 2026

The user clarified that power-ups should be revealed when the containing **block** is shot. Intact blocks no longer show badges. The reward icon rises and fades at the destroyed block; its animation pauses with gameplay and is removed on expiry or world cleanup. Existing automatic shooter ownership, power-up effects, quantities, scoring, splash and containment remain unchanged.

The HUD replaces health/lives words with images for each player: three heart slots show remaining lives (lost hearts dim), and five gold gas-tank icons show health. Each gas tank holds 20 health; partially filled icons reflect exact intermediate values, while empty tanks have a dark outline. Damage drains gas; recovery refills it up to 100. Losing a life dims a heart and respawns with full gas tanks; elimination leaves all hearts dim and all gas tanks empty. Hovering an icon provides exact health/life counts. Health recovery remains a heart-shaped power-up, distinct from the gas-tank health display. Help explains both symbols.

Requirements: R4/R7/R8 for hidden reward appearance and impact reveals; UI2/UI3/UI5 for accurate image-based vitals, pausing and help; UI6/UI8/UI9 for documentation. No source acceptance statuses changed. Godot 4.7.2 import completed without script/parser errors. Passed 45 power-up, 33 smoke, 16 co-op, 59 graphical UI and 19 forest checks (172 total, including 30-second containment). Checks read actual rendered heart/fuel controls rather than the removed text labels. Inspected hidden/revealed-block, partial-health/lost-life HUD and help previews; full preview suite refreshed. Existing log/certificate/editor-settings access errors and 4-7 ObjectDB shutdown warnings remain. Human readability/input testing remains outstanding.

Use `--path . --script res://tests/preview.gd -- --vitals` to capture `tests/hidden-powerups-preview.png`, `tests/revealed-powerup-preview.png` and the updated help screen with the graphical renderer.


## Replacement bricks - November 20, 2026

In both Solo Practice and Local Co-op/Duel, destroyed interior bricks create one replacement at a randomly selected clear interior position, at least 96 pixels from the destroyed spot and clear of tanks, moose, other bricks and both tank respawn points. Replacements are deferred until the shot/blast finishes. Each has an 8/35 chance of hiding one of the four existing power-ups, revealed and awarded to the shooter using the existing effects. The initial eight rewards remain unchanged. Solo Practice replaces bricks during play and still ends after 35 destructions (100 points each); no replacement is needed once the round ends. Duel continues with its existing lives-based ending. No changes to movement, aiming, firing, damage, power-up values or perimeter containment. ICE LEFT continues to show progress toward the original goal rather than current physical brick count.

Focused check: use the existing Godot command with --headless --path . --script res://tests/brick_respawn.gd. Godot 4.7.2: 8 replacement, 33 smoke, 45 power-up and 16 co-op checks passed. Mechanics: 19 passed, one pre-existing Results freeze match clock failure reproduced with unmodified HEAD; not repaired. Environment log/certificate/editor-settings errors and shutdown leak warnings remain. No graphical or human playtest for this change. Requirements R4/R7/R8/R9, UI2/UI4/UI6/UI8/UI9; original acceptance statuses unchanged.


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
