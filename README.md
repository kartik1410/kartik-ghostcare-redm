# kartik-ghostscare-redm

Halloween script for RedM (VORP and RSG). Players who are alone out in the wild at night get haunted by ghosts that only they can see.

Need help? Join the [Discord](https://discord.gg/T6AXd2eWdH).


https://github.com/user-attachments/assets/c979b296-3ddb-4108-b1f5-f398dbcb71c1


## How it works

Every player has a haunting level. It slowly goes up while you're alone outside at night and drops when you're with others or it's daytime. The higher it gets, the worse it gets: first small things, then ghosts, then ghosts that come after you.

Some places are more haunted than others: Bayou Nwa, Lagras, Bluewater Marsh, Braithwaite, Tall Trees and Roanoke. Check `Config.Hotspots`.

## Scares

Tier 1, small stuff:
- **Glimpse** - someone standing out in the dark at the edge of your vision, gone when you look
- **Footsteps** - footsteps walking up behind you, nobody there
- **Lights Out** - every lamp and lantern around you dies for a few seconds
- **Spooked** - your horse panics at something you can't see

Tier 2, ghosts:
- **Behind** - a ghost appears right behind you, turn around and it's staring at you
- **Trail** - a ghost stands on the trail ahead, ride into it and your horse throws you
- **Rider** - something climbs on your horse behind you
- **Screamer** - the lights die, then a ghost screams right in your face

Tier 3, it's after you:
- **Follow** - a ghost follows you and gets closer every time you look away
- **Angel** - it can't move while you watch it, but you have to blink sometime
- **Possessed** - the townsfolk around you all stop and stare at you. One of them gets closer every time you look away. Then they all walk off like nothing happened
- **Stalker** - something invisible follows you. You feel hunted and catch a shimmer of it now and then, until it's suddenly right in your face

## Spirit Compass

Usable item with a 5-bar meter that ticks faster the closer a ghost is. It also picks up how haunted you are and haunted places, so it starts ticking before anything shows up. Keeping it out makes ghosts show up more often.

## Dependencies

- VORP or RSG (only needed for the Spirit Compass item)

## Installation

1. Drop `kartik-ghostscare-redm` in your resources folder
2. Add `ensure kartik-ghostscare-redm` to your server.cfg (after your framework)
3. Add the item

VORP (`items` table, columns can differ between VORP versions):
```sql
INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
VALUES ('spirit_compass', 'Spirit Compass', 1, 1, 'item_standard', 1, 'Its needle points at things that should not be there.');
```

RSG (`rsg-core/shared/items.lua`):
```lua
spirit_compass = { name = 'spirit_compass', label = 'Spirit Compass', weight = 300, type = 'item', image = 'spirit_compass.png', unique = true, useable = true, shouldClose = true, description = 'Its needle points at things that should not be there.' },
```

## Commands

- `/haunt [id] [scare]` - haunt a player right now, skips the haunting level (admin)
- `/spiritcompass` - toggle the compass without the item (admin)
- `/hauntvoice` - play the ghost scream on yourself. `/hauntvoice 1` plays one entry of `Config.Screams`, `/hauntvoice pain 8` plays a pain voice (admin)

These need the `command` ace, which `group.admin` has with:
```
add_ace group.admin command allow
```

## Sounds

Ghosts scream with an in-game voice, and you can add your own sound files on top. Drop these in `html/sounds/` (any missing file is just skipped):

- `scream.ogg` - every jumpscare
- `whisper.ogg` - played from where a ghost is standing
- `breath.ogg` - when something is right behind you
- `laugh.ogg` - when the lights die

Whispers and breathing get louder the closer the ghost is. Volume and range are in `config.lua`.

## Config

By default it only runs in October, set `Config.Months = {}` to run it all year. Everything else (chance, cooldown, night hours, ghost models, hotspots) is in `config.lua`.

## Links

- Discord (support & updates): https://discord.gg/T6AXd2eWdH
- Docs: https://kartik-scripts.gitbook.io/
- More scripts: https://kartikscripts.store/
