# Unreal PCG Parity Matrix (Godot Flow Nodes)

Source baseline: Unreal Engine PCG Node Reference (UE 5.7):  
<https://dev.epicgames.com/documentation/unreal-engine/procedural-content-generation-framework-node-reference-in-unreal-engine?lang=en-US>

Scope compared against: `demo/addons/flow_nodes_editor/nodes/*.gd` (non-`_settings` scripts).

## Must (approved to implement)

| Unreal node / category | Godot equivalent | Status | Priority | Action |
|---|---|---|---|---|
| Loop (Subgraph) | `loop` | Present | Must | Keep; verify feedback pin behavior in stress graphs |
| Subgraph | `subgraph` | Present | Must | Keep |
| Branch | `branch` | Present | Must | Keep |
| Select / Select (Multi) | `select`, `select_multi` | Present | Must | Keep |
| Switch | `switch` | Present | Must | Keep |
| Filter Data By Tag / Type / Attribute | `filter_data_by_tag`, `filter_data_by_type`, `filter_data_by_attribute` | Present | Must | Keep |
| Attribute Filter / Point Filter | `filter` (generic) | Partial | Must | Add explicit range presets/docs parity |
| Add Attribute / Delete Attributes | `add_attribute`, `remove_attribute` | Present | Must | Keep |
| Match And Set Attributes | `match_and_set` | Present | Must | Keep |
| Attribute Boolean Op | `boolean` | Present (new) | Must | Hardened; keep in menu/search |
| Difference (Spatial) | `difference` | Present (new) | Must | Hardened; keep in menu/search |
| Point Neighborhood | `point_neighborhood` | Present (new) | Must | Keep |
| Point From Mesh | `point_from_mesh` | Present (new) | Must | Keep |
| Mesh Sampler | `mesh_sampler` (alias), `sample_mesh` | Present (new alias) | Must | Keep both names |
| Points From Scene / Get Actor-style point source | `points_from_scene`, `scan_nodes` | Partial | Must | Keep alias; expand actor filtering options |
| Copy Points | `copy` | Present (enhanced) | Must | Added source/target mode + inheritance controls |
| Transform Points | `transform` | Present | Must | Keep |
| Surface Sampler | `surface_sampler` | Present | Must | Keep |
| Spline Sampler | `sample_spline` | Present | Must | Keep |
| Self Pruning | `self_pruning` | Present | Must | Keep |
| Merge Points | `merge` | Present | Must | Keep |
| Debug / Sanity Check / Print String | `debug`, `sanity_check`, `print_string` | Present | Must | Keep |

## Should (high-value next)

| Unreal node / category | Godot equivalent | Status | Priority | Action |
|---|---|---|---|---|
| Attribute Rename | `attribute_rename` | Present (new) | Should | Keep; add batch rename mode later |
| Point Filter Range / Attribute Filter Range | `point_filter_range`, `attribute_filter_range` | Present (new) | Should | Keep; evaluate advanced typed comparisons |
| Volume Sampler | `volume_sampler` | Present (new alias) | Should | Keep; currently aliases sample-points volume patterns |
| Intersection (Spatial) | `intersection` (alias), `substract`, `difference` | Present (enhanced) | Should | Added overlap-source controls |
| Union (Spatial) | `union` (alias), `merge` | Present (enhanced) | Should | Added overlap-source controls |
| Get Points Count | `get_points_count`, `size` | Present (new alias) | Should | Keep |
| Attribute Set To Point / Point To Attribute Set | `attribute_set_to_point`, `point_to_attribute_set` | Present (new) | Should | Keep; extend typed conversion modes if needed |
| Mutate Seed | `mutate_seed` | Present (new) | Should | Keep |
| Spatial Noise | `noise` | Present (enhanced) | Should | Added sample source, space mode, and fractal controls |
| Texture Sampler | `texture_sampler` | Present (new) | Should | Keep; expand sampler sources/modes as needed |
| World Ray Hit Query | `ray_cast`, `physics_overlap_query` | Present (enhanced) | Should | Added direction/distance attrs + collision query options |
| Static Mesh Spawner | `spawn_meshes` | Present (enhanced) | Should | Added weighted variants + selector + parent target |
| Spawn Actor | `spawn_scenes`, `spawn_nodes` | Present (enhanced) | Should | Added variants, selector, assign-target path, parent target |
| Get Loop Index | `get_loop_index` | Present (new) | Should | Keep |

## Nice (important, but not blocking current stress goals)

| Unreal node / category | Godot equivalent | Status | Priority | Action |
|---|---|---|---|---|
| Data Table Row to Attribute Set / Load Data Table | - | Missing | Nice | Add data table import nodes |
| Load Alembic File / Load PCG Data Asset | - | Missing | Nice | Add external asset import adapters |
| Add/Delete/Replace Tags | `add_tags`, `delete_tags`, `replace_tags`, `filter_data_by_tag` | Present (new) | Nice | Keep |
| Apply On Actor / Proxy | - | Missing | Nice | Add runtime/property application nodes |
| Polygon Operation / Clip Paths / Split Splines | - | Missing | Nice | Add spline/polygon boolean toolset |
| World Volumetric Query | `physics_overlap_query` | Present (new) | Nice | Keep |
| Point From Player Pawn | - | Missing | Nice | Add runtime source node |
| Create Surface From Polygon/Spline | - | Missing | Nice | Add derived surface constructors |

## Already Added In This Burn-Down

- `boolean` + `boolean_settings`
- `difference` + `difference_settings`
- `point_neighborhood` + `point_neighborhood_settings`
- `point_from_mesh` + `point_from_mesh_settings`
- `points_from_scene` + `points_from_scene_settings`
- `mesh_sampler` (UE naming alias for `sample_mesh`)
- `attribute_rename` + `attribute_rename_settings`
- `intersection` (UE naming alias) + `union` (UE naming alias)
- `attribute_filter_range` + `point_filter_range` (+ settings)
- `mutate_seed` + `mutate_seed_settings`
- `attribute_set_to_point` + `point_to_attribute_set` (+ settings)
- `volume_sampler` + `volume_sampler_settings`
- `texture_sampler` + `texture_sampler_settings`
- `get_points_count` + `get_loop_index` (+ settings)
- parity upgrades on `copy`, `noise`, `ray_cast`, `spawn_meshes`, `spawn_scenes`, `spawn_nodes`
- Godot-specific: `points_from_tilemap`, `points_from_gridmap`, `physics_overlap_query`
- tag operations: `add_tags`, `delete_tags`, `replace_tags` (+ `tags_mutate`)
- menu/search/template registration updates (`flow_editor.gd`, `search_add_node_popup.gd`, `node_templates.csv`)

## Godot-First Extensions (beyond Unreal parity)

1. `points_from_tilemap`: read used cells from `TileMapLayer` into 3D points.
2. `points_from_gridmap`: read used cells/items from `GridMap` into points.
3. `physics_overlap_query`: per-point shape overlap checks for Godot physics workflows.
