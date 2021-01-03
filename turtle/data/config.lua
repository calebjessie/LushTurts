local config = { }

-- Mining Configs
config.DROPPED_ITEMS = {
    "minecraft:stone",
    "minecraft:dirt",
    "minecraft:cobblestone",
    "minecraft:sand",
    "minecraft:gravel",
    "minecraft:flint",
    "railcraft:ore_metal",
    "extrautils2:ingredients",
    "thaumcraft:nugget",
    "thaumcraft:crystal_essence",
    "thermalfoundation:material",
    "projectred-core:resource_item",
    "thaumcraft:ore_cinnabar",
    "deepresonance:resonating_ore",
    "forestry:apatite"
}

-- Turtle Defaults
config.SLOT_COUNT = 16
config.mineChunk = {w = 16, d = 16, h = 2}
config.locations = {
  home = {x = -483, y = 76, z = -750},
  hub = {x = -487, y = 76, z = -749}
}

return config