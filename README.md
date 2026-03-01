# PinDrop

A World of Warcraft addon that broadcasts detailed target information — including a **clickable map pin** — to a chat channel of your choice, with a single slash command or macro.

---

## What It Does

With a target selected, `/pindrop <channel>` sends a single line to chat containing:

- **Target name**
- **Classification** (Normal, Elite, Rare, Rare Elite, World Boss)
- **Zone name**
- **Your coordinates** (X, Y)
- **Target's current HP%**
- **A clickable map pin** — recipients can click it to open the exact map location, from anywhere in the world

**Example output in chat:**
```
[Nightbane Skycaller] (Rare) | Azurewing Repose | 48.23, 61.77 | HP: 34% | [Map Pin]
```

---

## Usage

```
/pindrop <channel>
/pd <channel>          (shorthand)
```

### Channel options

| Input | Sends to |
|-------|----------|
| `say` | /say |
| `yell` | /yell |
| `party` | Party chat |
| `raid` | Raid chat |
| `guild` | Guild chat |
| `instance` | Instance/LFG chat |
| `3` (any number) | Custom channel #3 |

### Examples

```
/pindrop raid
/pindrop say
/pd 3
```

---

## Macro Example

You can easily bind this to a macro for one-click use:

```
#showtooltip
/pindrop raid
```

---

## Installation

1. Download or clone this repository
2. Copy the `PinDrop` folder into your WoW addons directory:
   ```
   World of Warcraft/_retail_/Interface/AddOns/PinDrop/
   ```
3. Reload your UI or log in — you'll see `[PinDrop] v1.0.0 loaded.` in chat

---

## Notes

- PinDrop only works on NPC targets, not players
- If you have a personal waypoint set, PinDrop will **preserve and restore it** after broadcasting
- The map pin hyperlink works for recipients in any zone — clicking it opens the correct map automatically
- The `/pd` shorthand is available as a convenience alias

---

## From the Same Author

- **MountMimic** — [[GitHub Page](https://github.com/Kraxiloth/MountMimic)]

---

## License

MIT
