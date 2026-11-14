# Mars: Last Survivor assets

AssetRegistry maps the expected image paths in this directory. The conceptual PDF and source images were not present in the workspace when this manifest was created, so no placeholder images are included; add the original exported PNGs at the paths below to activate them.

## Sprite sheets

Character sheets use 8 columns x 9 rows (astronauts) or 8 columns x 5 rows (pets). Rover uses 7 columns x 5 rows. `SpriteSheetBuilder` takes explicit row-major cell indices and skips fully transparent cells. If the concept art uses a different layout, update the corresponding layout/grid in `scripts/core/asset_registry.gd` before importing the sheet.

- `sprites/characters/astronaut_female_sheet.png`
- `sprites/characters/astronaut_male_sheet.png`
- `sprites/characters/pet_laika_sheet.png`
- `sprites/characters/pet_ham_sheet.png`
- `sprites/vehicles/rover_explorer_sheet.png`

## Buildings

- `sprites/buildings/habitat_lvl1.png`
- `sprites/buildings/workshop_lvl1.png`
- `sprites/buildings/warehouse_lvl1.png`
- `sprites/buildings/greenhouse_lvl1.png`
- `sprites/buildings/solar_panel_lvl1.png`
- `sprites/buildings/comm_antenna_lvl1.png`
- `sprites/buildings/laboratory_lvl1.png`
- `sprites/buildings/pet_shelter_lvl1.png`
- `sprites/buildings/crashed_ship.png`

## UI and story

- `ui/logo_mars.png`
- `ui/menu_bg.png`
- `ui/portrait_female.png`
- `ui/portrait_male.png`
- `ui/portrait_laika.png`
- `ui/portrait_ham.png`
- `ui/intro_1.png` through `ui/intro_4.png`
