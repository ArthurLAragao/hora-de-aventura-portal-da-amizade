# Ice tunnel wall variant

Tool: built-in `image_gen` in edit/reference mode. Reference: existing `02_ice_kingdom/tiles/fill.png`. No external asset download, original texture unchanged.

Saved master: `ice_tunnel_wall_source.png`; runtime variant: `ice_tunnel_wall_detail.png` (32×32). `tests/feedback_tunnel_extract.gd` reproduces nearest-neighbor normalization. The opaque tile is rendered behind Cake with architectural ribs; it does not add collision. The scene retains the texture reference rather than loading it only temporarily in `_draw`.

Prompt:

Create ONE square seamless pixel-art texture tile for the INTERIOR REAR WALL of a small ice tunnel in a children's 2D platform game. Match this reference blue-ice material, pixel cluster size, dark outlines and restricted blue palette. Logical resolution 32x32 pixels, enlarged nearest-neighbor for presentation. Crisp true pixel art with flat pixel clusters, NO antialiasing, blur, gradients, glow, painterly shading, 3D rendering, frames, text, ground surface, opening or objects. A tunnel rear wall: layered fractured blue ice and a few embedded darker stone fragments, short horizontal sediment seams, fine bright frost ridges, irregular angular cracks. Medium-dark desaturated blue so an orange-and-white character remains legible over it. Detail must read at 32px, not tiny noisy speckles. All four edges tile seamlessly. Flat opaque background, fill entire square. This texture is a new local variant; do not copy any characters or change the existing terrain style.

Runtime filtering is Nearest on the local scene drawing node. The reference palette and integration were reviewed in actual game captures; no claim of final human approval is made.
