# Revision 2 — Godot integration

## Import

Copy the complete `Assets` folder to your project root. Resources use `res://Assets/...` paths. Use the updated `animations.tres` or `visual.tscn` files; the first pack's four-column coordinates are superseded.

## Character geometry

- Frame: 96×80 pixels. Atlas: 768×800 pixels, eight columns and ten rows.
- Visual foot anchor: (48,72). The supplied AnimatedSprite2D is offset by (0,-32) relative to its root.
- Pixel art uses nearest filtering. Original character body scale is retained; the larger frame provides transparent padding.
- `animation_data.json` is the authoritative coordinate/timing map. Blank unused atlas cells are not animation frames.
- Individual frames and horizontal strips are supplied for every exposed playback sequence. Repeated poses in recovery sequences are deliberate.

## Reusable driver

Each `01_Characters/<name>/visual.tscn` includes `animation_driver.gd`. Add the scene under your player body. After movement, call `visual.update_motion(velocity, is_on_floor(), delta)`. This selects idle/walk/ascent/descent/landing and changes playback only when the state changes; repeated physics updates do not restart a walk.

Call `visual.set_ability(held)` for primary ability input; call `visual.play_action(&"interact")`, `visual.play_secondary()` or `visual.play_action(&"celebrate")` for actions. `visual.set_character(id)` swaps the resource set. The included `PlayableTest/player.gd` demonstrates the wiring.

Common names: idle, walk, jump, fall, interact, celebrate, jump_start, land. Special names:

| Character | Ability states |
|---|---|
| Finn | push, pull_lever |
| Jake | bridge_extend, bridge_hold, bridge_retract |
| Fionna | push, crank |
| Cake | crawl, stretch, stretch_hold, stretch_retract |
| Marceline | float, play_music |
| BMO | terminal, connect_power |

Walking uses eight poses at 12 fps at 100 world pixels/second, with speed scaling. Idle is deliberately quieter. `fall`, `bridge_hold` and `stretch_hold` are intentional held states. Physical velocity supplies falling motion. Actions play once and recover; primary held actions continue until released. Do not call a force-restart every physics frame.

`jump_start` is supplied as an optional anticipation clip; the test room prioritizes immediate jump response. `land` is a short recovery state. The native controller includes acceleration, jump buffering, coyote time and shorter jumps on early release.

## Effects and objects

Eight ready-to-instance scenes in `05_Effects` use `effect_driver.gd`. Call `trigger(effect_name)` to replay a one-shot. One-shots hide when finished; portal loops. Preview repetition does not change the game's one-shot behavior.

Gate and crank resources contain activate/deactivate transitions. Other object resources are static visual states such as on/off or open/closed; their held images are intentional. Reflection, energy evaluation, shared exits and other puzzle rules remain game code.

## Other assets

Terrain remains 32×32; each environment's `tileset.tres` is ready to assign to TileMapLayer. Existing simple collision rectangles are starting values for integration with the actual game's controller. Backgrounds and static screen designs remain 640×360. Standard objects are 64×64, portal props 128×128.

Ready-to-instance UI scenes are in `04_Interface/Godot`. Their action_requested signal connects to your game manager. Music/SFX WAVs and configured looping `.res` resources remain in `07_Audio`. Fonts and original licenses remain in `08_Fonts`.

The included test room is a movement/animation demonstration, not the finished six-stage game. Physical-controller hardware was not supplied or tested.
