# Manual Setup Guide (no Rojo)

If you'd rather not install Rojo, you can build the exact same game by hand in
Roblox Studio: create the instances below in the **Explorer**, then paste each
file's contents into the matching script. The hierarchy here is identical to
what Rojo would sync from `default.project.json` — same names, same parents,
same script types.

**Rule of thumb for every entry below:**
- `ModuleScript` → right-click the parent → Insert Object → ModuleScript
- `Script` → right-click the parent → Insert Object → Script (this is a
  **server** script — used only for `Init.server.lua`)
- `LocalScript` → right-click the parent → Insert Object → LocalScript (used
  only for `Init.client.lua`)
- `Folder` → right-click the parent → Insert Object → Folder
- Rename each instance to the exact name in the table (drop the `.lua` /
  `.server.lua` / `.client.lua` suffix — that suffix is only a Rojo file-naming
  convention, Studio instances are named plainly)
- Open the instance, select all (Ctrl+A), delete the placeholder content, and
  paste in the matching file's contents from this repo

Do these three sections in any order — nothing runs until you press Play.

---

## 1. ReplicatedStorage

Insert a **Folder** named `Shared` directly under `ReplicatedStorage`. Everything
below goes inside that one folder, all as siblings (no further nesting):

| Studio instance (inside `ReplicatedStorage > Shared`) | Type | Paste from |
|---|---|---|
| `Config` | ModuleScript | `src/ReplicatedStorage/Shared/Config.lua` |
| `Rarities` | ModuleScript | `src/ReplicatedStorage/Shared/Rarities.lua` |
| `Titles` | ModuleScript | `src/ReplicatedStorage/Shared/Titles.lua` |
| `Quests` | ModuleScript | `src/ReplicatedStorage/Shared/Quests.lua` |
| `Achievements` | ModuleScript | `src/ReplicatedStorage/Shared/Achievements.lua` |
| `RemoteEvents` | ModuleScript | `src/ReplicatedStorage/Shared/RemoteEvents.lua` |
| `UIFactory` | ModuleScript | `src/ReplicatedStorage/Shared/UIFactory.lua` |
| `Effects` | ModuleScript | `src/ReplicatedStorage/Shared/Effects.lua` |

You do **not** need to manually create any `RemoteEvent`/`RemoteFunction`
instances or a `Remotes` folder — `RemoteEvents.lua`'s `Setup()` function
creates them automatically the first time the game runs.

```
ReplicatedStorage
└── Shared (Folder)
    ├── Config (ModuleScript)
    ├── Rarities (ModuleScript)
    ├── Titles (ModuleScript)
    ├── Quests (ModuleScript)
    ├── Achievements (ModuleScript)
    ├── RemoteEvents (ModuleScript)
    ├── UIFactory (ModuleScript)
    └── Effects (ModuleScript)
```

---

## 2. ServerScriptService

Insert a **Folder** named `Server` directly under `ServerScriptService`. Everything
below goes inside that folder, all as siblings:

| Studio instance (inside `ServerScriptService > Server`) | Type | Paste from |
|---|---|---|
| `Init` | **Script** | `src/ServerScriptService/Server/Init.server.lua` |
| `DataService` | ModuleScript | `src/ServerScriptService/Server/DataService.lua` |
| `RollService` | ModuleScript | `src/ServerScriptService/Server/RollService.lua` |
| `RebirthService` | ModuleScript | `src/ServerScriptService/Server/RebirthService.lua` |
| `StreakService` | ModuleScript | `src/ServerScriptService/Server/StreakService.lua` |
| `QuestService` | ModuleScript | `src/ServerScriptService/Server/QuestService.lua` |
| `AchievementService` | ModuleScript | `src/ServerScriptService/Server/AchievementService.lua` |
| `AutoRollService` | ModuleScript | `src/ServerScriptService/Server/AutoRollService.lua` |
| `EconomyService` | ModuleScript | `src/ServerScriptService/Server/EconomyService.lua` |
| `GamepassService` | ModuleScript | `src/ServerScriptService/Server/GamepassService.lua` |
| `LeaderstatsService` | ModuleScript | `src/ServerScriptService/Server/LeaderstatsService.lua` |

`Init` is the only one that's a plain **Script** (not a ModuleScript) — it's
the thing that actually runs on server start and wires everything together
via `require(script.Parent.X)`, which is exactly why every other module needs
to be its sibling inside the same `Server` folder.

```
ServerScriptService
└── Server (Folder)
    ├── Init (Script)
    ├── DataService (ModuleScript)
    ├── RollService (ModuleScript)
    ├── RebirthService (ModuleScript)
    ├── StreakService (ModuleScript)
    ├── QuestService (ModuleScript)
    ├── AchievementService (ModuleScript)
    ├── AutoRollService (ModuleScript)
    ├── EconomyService (ModuleScript)
    ├── GamepassService (ModuleScript)
    └── LeaderstatsService (ModuleScript)
```

---

## 3. StarterPlayer > StarterPlayerScripts

Insert a **Folder** named `Client` directly under `StarterPlayerScripts`. Then
inside that, insert a **Folder** named `UI`.

| Studio instance | Type | Paste from |
|---|---|---|
| `StarterPlayerScripts > Client > Init` | **LocalScript** | `src/StarterPlayer/StarterPlayerScripts/Client/Init.client.lua` |
| `StarterPlayerScripts > Client > RemoteController` | ModuleScript | `src/StarterPlayer/StarterPlayerScripts/Client/RemoteController.lua` |
| `StarterPlayerScripts > Client > UI > MainUI` | ModuleScript | `.../Client/UI/MainUI.lua` |
| `StarterPlayerScripts > Client > UI > RollPanel` | ModuleScript | `.../Client/UI/RollPanel.lua` |
| `StarterPlayerScripts > Client > UI > IndexPanel` | ModuleScript | `.../Client/UI/IndexPanel.lua` |
| `StarterPlayerScripts > Client > UI > RebirthPanel` | ModuleScript | `.../Client/UI/RebirthPanel.lua` |
| `StarterPlayerScripts > Client > UI > ShopPanel` | ModuleScript | `.../Client/UI/ShopPanel.lua` |
| `StarterPlayerScripts > Client > UI > QuestPanel` | ModuleScript | `.../Client/UI/QuestPanel.lua` |
| `StarterPlayerScripts > Client > UI > DailyRewardPopup` | ModuleScript | `.../Client/UI/DailyRewardPopup.lua` |
| `StarterPlayerScripts > Client > UI > Notification` | ModuleScript | `.../Client/UI/Notification.lua` |
| `StarterPlayerScripts > Client > UI > OverheadTitle` | ModuleScript | `.../Client/UI/OverheadTitle.lua` |

`Init` (the LocalScript) is the only thing that runs automatically — Roblox
runs every LocalScript that's a descendant of `StarterPlayerScripts`
regardless of how deep it's nested in folders, so keeping everything under
`Client/` is just for organization.

```
StarterPlayer
└── StarterPlayerScripts
    └── Client (Folder)
        ├── Init (LocalScript)
        ├── RemoteController (ModuleScript)
        └── UI (Folder)
            ├── MainUI (ModuleScript)
            ├── RollPanel (ModuleScript)
            ├── IndexPanel (ModuleScript)
            ├── RebirthPanel (ModuleScript)
            ├── ShopPanel (ModuleScript)
            ├── QuestPanel (ModuleScript)
            ├── DailyRewardPopup (ModuleScript)
            ├── Notification (ModuleScript)
            └── OverheadTitle (ModuleScript)
```

---

## Checklist before you press Play

- [ ] All 7 modules exist under `ReplicatedStorage > Shared`
- [ ] All 11 instances exist under `ServerScriptService > Server`, and `Init` is a **Script** (not a ModuleScript)
- [ ] All 11 instances exist under `StarterPlayerScripts > Client` (incl. the `UI` subfolder), and `Init` is a **LocalScript**
- [ ] Every instance is named exactly as shown (no `.lua` in the name)
- [ ] You pasted each file's *entire* contents, including the `--!strict` line at the top

If something doesn't work, the single most common cause is a typo in an
instance's name or a script placed one folder too deep/shallow — the
`require(...)` calls inside these scripts (e.g. `require(script.Parent.DataService)`)
depend on the exact sibling/folder structure above.

## Before you publish

Same as the Rojo path — see the **Before you publish** section of `README.md`
for the VIP Gamepass ID and DataStore notes.
