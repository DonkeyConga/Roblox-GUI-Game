# Updating an Existing Studio Build

If you already built this game in Studio (via Rojo or by hand from
`MANUAL_SETUP.md`), you don't need to rebuild anything — this update only
changes the *contents* of some existing scripts and adds **one** brand-new
one. Nothing needs to be deleted, moved, or renamed.

If you use **Rojo**, just `git pull` and reconnect — everything below happens
automatically and you can stop reading here. The rest of this file is for a
**manual (no-Rojo)** Studio build.

## 1. One new script to add

| Studio instance | Type | Parent | Paste from |
|---|---|---|---|
| `Effects` | ModuleScript | `ReplicatedStorage > Shared` | `src/ReplicatedStorage/Shared/Effects.lua` |

Right-click your existing `Shared` folder → Insert Object → ModuleScript →
rename it `Effects` → paste in the file's contents. This is a sibling of
`Config`, `Titles`, `UIFactory`, etc. — same folder, nothing else changes
about that folder's structure.

## 2. Existing scripts to overwrite (content changed, location unchanged)

For each of these: open the existing instance in Studio, select all its
contents (Ctrl+A), delete, and paste in the new file's contents from this
repo. Nothing about *where* these live changed.

**`ReplicatedStorage > Shared`:**
- `Config` — new starting-coins value (see **Why** below)
- `Rarities` — new pastel color palette (Pusheen theme)
- `Titles` — full rewrite: 106 Pusheen-variant titles (was ~30 generic ones)
- `Achievements` — expanded from 10 to 32 achievements, 3 new achievement types
- `Quests` — 3 new quest templates added to the daily pool
- `RemoteEvents` — added a new `RequestSync` remote (see **Why** below)
- `UIFactory` — full theme rewrite (Pusheen palette; same function names, so
  nothing else needs code changes)

**`ServerScriptService > Server`:**
- `AchievementService` — supports the 3 new achievement types (`IndexPercent`,
  `LoginStreak`, `OwnsVIP`)
- `Init` — fixes the join-time data-sync race (see **Why** below); also now
  checks achievements after a streak claim and a VIP purchase

**`StarterPlayerScripts > Client`:**
- `RemoteController` — adds `RequestSync`; every call is now pcall-guarded so
  a dropped connection can't silently kill a button
- `UI > MainUI` — pulls `RequestSync` once its listeners are ready; adds the
  panel pop-in transition, coin/rebirth count-up animation, and a bobbing paw icon
- `UI > RollPanel` — confetti/burst-ring effects via the new `Effects` module,
  Pusheen-flavored text, always shows feedback on a failed roll
- `UI > IndexPanel` — Pusheen-flavored text, always shows feedback on a failed equip
- `UI > RebirthPanel` — always shows feedback on a failed rebirth
- `UI > ShopPanel` — Pusheen-flavored text, clearer failure feedback
- `UI > QuestPanel` — always shows feedback on a failed quest claim
- `UI > DailyRewardPopup` — **now takes a third parameter** (see below),
  always shows feedback on a failed claim

### One call site changed, not just a paste-over

`DailyRewardPopup.Create` now takes a `notification` argument it didn't
before. If you're pasting `MainUI.lua`'s new contents wholesale (which is what
this guide otherwise tells you to do everywhere), this is already handled —
just make sure you paste over the **entire** `MainUI` script, not just parts
of it, since the line that calls `DailyRewardPopup.Create(...)` needs to match.

## 3. Unchanged — leave these alone

`DataService`, `RollService`, `RebirthService`, `StreakService`,
`AutoRollService`, `EconomyService`, `GamepassService`, `LeaderstatsService`,
`Notification`, `OverheadTitle`, `Init` (client) are all untouched by this
update.

## Why these changes were needed

Two real bugs made the game feel broken, both now fixed:

1. **New players had 0 starting coins against a 50-coin roll cost**, so every
   click on Roll just silently failed with an easy-to-miss "not enough coins"
   toast — it *looked* like the button did nothing. Fixed by giving new
   players 150 starting coins (3 free rolls).
2. **The server's one-time "here's your data" push on join could be lost.**
   It's an ordinary RemoteEvent fired the moment your save finishes loading;
   if your client's listener wasn't connected yet (plausible in Studio,
   especially with DataStores disabled, since the server can then proceed
   almost instantly), that payload — which is what fills in your coins, the
   Quests tab, everything — was gone for good. Nothing re-sent it until a
   successful roll, which bug #1 was also blocking, so both problems compounded
   into "the game just doesn't work." Fixed with a `RequestSync`
   request/response the client actively pulls once it's actually ready,
   instead of only hoping the server's push arrives in time.

Existing players' save data is unaffected — nothing about the save-data shape
changed, only how much a *brand new* player starts with and how reliably the
client receives it.
