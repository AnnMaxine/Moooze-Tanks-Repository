# Moooze Tanks status

Updated: November 3, 2026

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
