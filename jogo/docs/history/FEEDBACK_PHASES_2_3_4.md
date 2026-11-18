# Phase 2–4 feedback revision — 2026-10-28

This revision addresses the user's latest manual feedback. It does not claim new human approval. Godot **4.7.2** and the existing character/input/bridge controllers are preserved. Phases **1 and 6** and Phase 5 are outside this revision.

## Confirmed defects and corrections

| Report | Finding | Applied correction | Validation |
|---|---|---|---|
| Plain tunnel interior | The texture was loaded into a temporary reference in `_draw`; rendered samples showed the uniform tint rather than the loaded blue texture. | Persistent texture references, a new 32×32 ice-wall variant, cutaway ribs, lintels and floor reveal. | Actual rendered pixel variation and inspection while Cake traverses; approved clearance unchanged. |
| Cave characters and vegetation appear above the ground | The physical cave floor was Y390, but the texture becomes continuously opaque at Y394. Decorations ended at Y388. | Only the cave's local TileSet copies now support at Y394. Nearby platforms/panel and fixtures follow that surface. Character scenes and sprite frames unchanged. | Visible feet/collider boundary ~393.998; vegetation boundary 394; original TileSet template still at its original value. |
| Floating lamps | Lantern sprites had no continuous attachment. | Pixel chains and visible ceiling brackets in the cave and workshop; restrained existing light animation retained. | Real rendered frames at 1152×648 and 1280×720, including default D3D12. |
| Workshop bridge overlaps/misses the intended opening | The old final span was X624–752, while the opening is X576–704. It missed 48 units at the entry and overhung 48 at the far bank. | Same 128-unit carrier, now docking at centre X512 and arriving at X640; final support X576–704 at the original Y388. Cargo/rider safety retained. | Rays at entry, centre and exit plus complete Finn/BMO crossing, both roles. |
| False underside pieces across openings | Decorative strips used old spans and retained earlier draw commands. | Derive strips from current terrain cells, keep textures alive and redraw after terrain configuration. | Rendered inspection of the echo channel and carrier opening. |
| Doors need polish | Presentation request; unlock behavior was already working. | Recessed basalt/copper frames, consistent thresholds, inset leaves, braces, rivets, rune/lock details and clear open state. Cave gates grounded to the corrected floor. | Closed/open fixtures and actual unlock/crossing during complete routes. |
| Connection board needs integration | Existing operation retained. | Copper housings, bolts, frosting-capped plinths, pipe collars and a completed-state highlight. | Finn rotates the same two pieces; BMO activates energy once; repeated interaction remains safe. |

## Phase-specific changes

### Phase 2 — frozen trail
The tunnel, Cake bridge transformation and flag progression retain their working behavior. New low vegetation groups and a snow-capped background fence frame the reunion area. Mechanism approaches and the bridge anchor remain clear.

After the checkpoint, a short ice ridge replaces a flat walk: three broad terraces at Y487/455/487 over X1152–1408. Each upward change is 32 units. The old overhead trio was removed because it conflicted with the approach. A final 32-unit crystal terrace occupies X2016–2144. The explicit final test start moved to a safe floor beyond that terrace.

The collectible now uses the existing **green crystal** asset. Collection still requires the established puzzle progress, and completion requires the pair.

### Phase 3 — musical crystal cavern
The initial musical route, clue, symbol terminal and working door-unlock/energy signals are preserved. The floor correction is scene-local; template resources remain unchanged. Sprite-only offsets ground static fixtures without changing their interaction areas.

A new echo-channel crossing occupies X1344–1536. Two 96-unit stone islands provide a broad near landing at Y370 and a far landing at Y338, with a 16-unit gap between them. The energy terminal sits on the far landing. Both characters can cross with their existing controls; Marceline retains optional limited float. The existing two-player confirmation, crystal and joint exit follow the crossing.

The collectible uses the existing **purple crystal**. Its shape and warm-purple highlight distinguish it from the earlier green/cyan crystals.

### Phase 4 — candy workshop
The overall layout and animations are retained. The carrier has corrected dock/end coordinates and a continuous final opening. The loading mark, block lock, waiting for an obstructing partner, cancellation and safe reset logic remain.

The connection board and doors have local material/detail improvements. Lamps have physical-looking chains. Terminal, battery, receiver and flag artwork is aligned to its supporting surface. The collectible uses the existing **orange crystal**, raised seven units so its tip is not clipped by the terrain. No new circuit controls or puzzle actions were added.

## Test evidence
External evidence folder: `D:/TEMP/feedback-234-2026-10-28`.

- Complete Phase 2 route: normal and inverted Cake/Fionna roles, actual simulated player inputs, tunnel entry/reversal/exit, ridge, bridge, airborne-release safety, permanent passage, final terrace, crystal and joint exit. No recovery counted as traversal.
- Complete Phase 3/4 routes: normal and inverted roles, clue and symbol input, echo islands, energy, shared plates, carrier/cargo delivery, physical connections, checkpoints, crystal and joint exit. No scripted repositioning in these complete routes.
- Rendered routes were exercised with Compatibility and the project's default **Direct3D 12 / Forward+** renderer. Phase 3/4 routes at 1152×648 and 1280×720; Phase 2 complete routes at 1152×648, with alignment/presentation fixtures also at 1280×720.
- Separate prepared-state fixtures checked recovery before/after checkpoint, crystal persistence, early-exit rejection, cancellation, local block reset, carrier waiting/resumption and restart. Fixture placements do not count as route completion.
- Final rendered alignment fixtures check crystal asset paths, cave foot contact, unmodified template collision data, actual tunnel texture variation and support across all three parts of the carrier.
- Phase 1 and 6 regression routes passed, and the baseline audit verifies their existing resources unchanged. Character, control, menu, shared camera and approved bridge scripts unchanged.
- Final relevant runs examined had no new runtime errors/warnings. Intermediate failures were fixed; they are retained in external logs, not presented as passing evidence.

Visual inspection covered the tunnel, character contact, vegetation bases, suspended lights, both door states, echo channel, carrier arrival, crystal approaches and connection board. This is a review of representative views, not a claim that every possible frame is perfect.

## Manual check
1. Open `level_2.tscn` with F6. Traverse the tunnel in both directions; climb the ridge; use the bridge; collect the green crystal from its terrace.
2. Open `level_3.tscn`. Check feet on the ground and balconies, reveal the clue, cross the echo islands with both characters, energize and use both plates. Inspect the purple crystal.
3. Open `level_4.tscn`. Load the marked carrier, operate BMO, cross at the near edge, push the delivered block and align/connect the pipes. Check the orange crystal and both doors.
4. Repeat with the root player-role property inverted and inspect the suspended lights at your normal window size.

## Limitations
New appearance and increased layout challenge still require the user's manual evaluation. No two-human session, exported build, another computer or audio listening was performed. Ice remains visually frozen without changing global movement/sliding. No new content for Phases 1, 5 or 6.

## Safety and files
Full pre-change resource backup: `D:/TEMP/feedback-234-2026-10-28/backup`. Exact changed/new files are in that folder's `manifest.json`. Original PNGs are preserved. The new tunnel source and normalized variant are separate files in `Assets/02_Environments/regional_refinement`; see `ice_tunnel_wall_PROVENANCE.md` for generation details.
