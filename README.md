# LushTurts

A simple chunk miner for turtles from CC: Tweaked.

## Todos
* [ ] Update turtle status every rednet message maybe
        Need to update when we set status or deliver chunk coords
        In terms of the turtle location, updating every move would be dumb so we'll limit it to the assigned chunk
* [ ] Dynamically generate turtle names on first boot
* [ ] Rewrite nextMine() function for spiral
* [ ] Possibly improve resolution of pixel art

Dependencies:
- [JSON api](http://www.computercraft.info/forums2/index.php?/topic/5854-json-api-v201-for-computercraft/), ElvishJerricco
- [Simple github util](http://www.computercraft.info/forums2/index.php?/topic/29920-simple-github-util/), mayanyaa
- [Surface 2](http://www.computercraft.info/forums2/index.php?/topic/28336-surface-2-a-powerful-graphics-library/), CrazedProgrammer

Currently requires manual start by placing desired start coords within the nextMine.json file.

Uses CC: Tweaked v1.84 on MC 1.12.2 (or FTB Rev)

PS. I hate Lua
