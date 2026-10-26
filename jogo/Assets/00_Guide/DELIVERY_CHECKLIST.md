# Approved inventory → delivered files (Revision 2)

| Approved item | Delivery |
|---|---|
| Palette, scale, naming and animation conventions | 00_Guide/visual_guide.png, palette.json, palette.gpl, GODOT_INTEGRATION.md |
| Six characters and common/special animations | 01_Characters/<character>/frames, animations, spritesheet.png, animations.tres |
| Portraits, player markers, interaction/ability cues | Character portrait.png; marker/hand sprites; Q/E/Enter controls; special-animation frames |
| Six backgrounds | 02_Environments/<stage>/background.png |
| Ground tops, sides, centers, bottom/corners, platforms and decoration | Each stage's tileset_32.png, tiles folder and tileset.tres |
| Six distinguishable friendship crystals and HUD collection state | crystal_<color>.png, crystal_empty.png, crystal_collected.png |
| Log, blocks, plates, lever, gate and crank states | 03_Objects_and_Puzzles/sprites and Godot resources |
| Bridges, anchors, moving platform, tunnel entrances, ice block | Individual sprites in 03_Objects_and_Puzzles/sprites |
| Musical symbols, clues, terminal and sound door | rune_*, clue_panel, terminal_*, musical_door_* |
| Battery, connectors, cables and power indicators | battery_*, cable_*, terminal_* |
| Mirrors, beams and single/double receiver states | mirror_*, beam_*, receiver_*, double_receiver_* |
| Portal frame, sockets, pedestal, access/gears and restored state | portal_*, socket_*, access_*, gears_* |
| Checkpoint, shared exit, starting marker and reset icon | checkpoint_*, exit_*, start_flag, reset_arrow |
| Logo, main menu, instructions, pause, HUD and victory | 04_Interface/logo.png, screens, components and Godot scenes |
| Buttons normal/focus/pressed/disabled and sound icons | 04_Interface/buttons and components |
| Keyboard and provisional generic gamepad prompts | 04_Interface/controls |
| Speech/hint panels and stage introductions | components/speech_panel, hint_panel; 06_Story_Screens/stage_cards |
| Jump/landing, interaction, collection, mechanism, checkpoint, music, portal and celebration effects | 05_Effects, 8 animations × 4 frames |
| Opening, portal malfunction and six-friend ending | 06_Story_Screens/discovery, scattered_crystals, celebration |
| Menu/stage/victory music and gameplay/UI effects | 07_Audio/Music and SFX, 36 WAV files |
| UI/title fonts with licenses | 08_Fonts, two TTF and two OFL files |
| Character/environment/object previews and original source sheets | 09_Previews_and_Credits; OPEN_PREVIEW.html |
| Import/integrity evidence | godot_validation.json, package_validation.json, checksums.sha256 |

The SGDD defines six playable characters and no additional NPC. No extra NPC role was invented. Camera/checkpoints/pause transitions are programming features: their visual assets are present, while their game behavior must be implemented in the game project.

Revision 2: revised character resources use 96×80 frames, eight-column atlases and per-state timing. Playable tests are in the root browser page and PlayableTest folder. See ANIMATION_REVISION_REPORT.md for the complete review.
