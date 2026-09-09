# Pusheen Roll RNG

A complete, GUI-driven Roblox RNG game where you roll for **Pusheen the Cat
variants** as equippable titles. Every system here was chosen to make the
game "loopy" and worth coming back to: a rebirth ladder, a permanent
collection log (106 titles — full completion is meant to take a long time),
32 achievements, VIP monetization, daily login streaks, pity-protected RNG,
idle/AFK income, an auto-roller, and daily quests.

The whole UI runs on one custom **Pusheen theme** (warm cream backdrops,
blush-pink accents, soft lavender secondary, pastel rarity glows, animated
throughout) defined once in `UIFactory.lua` — see **Visual theme** below.

Don't want to use Rojo? See **[MANUAL_SETUP.md](MANUAL_SETUP.md)** for exact
step-by-step instructions to build the same instance hierarchy by hand in
Roblox Studio. If you already have an earlier version of this game built in
Studio, see **[UPDATING.md](UPDATING.md)** instead — it tells you exactly
which existing scripts to overwrite and which are brand new.

## Core loop

1. Spend coins to **Roll** for a random Pusheen title (7 rarity tiers,
   weighted RNG, 106 possible titles).
2. Equip a discovered title for a passive coin-gain multiplier and a
   BillboardGui tag that follows you around the map.
3. Spend enough coins to **Rebirth**: your coins reset to 0, but you keep a
   permanent % boost to coin gain and luck forever. Costs grow every rebirth.
4. Fill in the **Index** (collection log) by discovering every title in a
   rarity tier for a small permanent luck bonus — with 25 Common titles alone,
   even the "easy" tier takes a while.
5. Come back daily for a login-streak reward, work through daily quests, and
   chip away at 32 long-term achievements (roll counts, rebirth counts, full
   rarity-tier collections, Index completion %, login streaks, and VIP).

## Retention systems and where they live

| System | Server | Client |
|---|---|---|
| Weighted RNG + pity | `RollService.lua` | `RollPanel.lua` |
| Rebirth / prestige | `RebirthService.lua` | `RebirthPanel.lua` |
| Index / collection log + set bonuses | `RollService.lua` (`CheckSetBonus`) | `IndexPanel.lua` |
| VIP gamepass | `GamepassService.lua` | `ShopPanel.lua` |
| Daily login streak | `StreakService.lua` | `DailyRewardPopup.lua` |
| Auto-Roll (online) + AFK gains (offline) | `AutoRollService.lua`, `EconomyService.lua` | `RollPanel.lua` (toggle) |
| Daily quests + permanent achievements | `QuestService.lua`, `AchievementService.lua` | `QuestPanel.lua` |
| Save data / DataStore | `DataService.lua` | — |
| Animation helpers (confetti, burst rings, count-up, pop-in) | — | `Effects.lua` |

Full architecture:

```
src/
  ReplicatedStorage/Shared/     -- data tables + Config, shared by server & client
    Config.lua                  -- every tunable number in the game
    Rarities.lua                -- the 7 rarity tiers (weight, color, boost)
    Titles.lua                  -- all 106 rollable Pusheen titles + the VIP-exclusive one
    Quests.lua / Achievements.lua -- 10 daily quest templates, 32 permanent achievements
    RemoteEvents.lua             -- creates/fetches the RemoteEvents & RemoteFunctions
    UIFactory.lua                -- shared theme + Frame/Label/Button/ProgressBar helpers
    Effects.lua                  -- confetti bursts, burst rings, count-up numbers, pop-ins
  ServerScriptService/Server/    -- all authoritative game logic
    Init.server.lua               -- wires remotes to services, the only script that touches them
    DataService.lua               -- DataStore load/save/autosave
    RollService.lua                -- roll cost, weighted RNG, pity, equip
    RebirthService.lua / StreakService.lua / QuestService.lua
    AchievementService.lua / AutoRollService.lua / EconomyService.lua
    GamepassService.lua / LeaderstatsService.lua
  StarterPlayer/StarterPlayerScripts/Client/
    Init.client.lua                -- entry point
    RemoteController.lua           -- typed, pcall-guarded wrapper over the remotes
    UI/
      MainUI.lua                     -- top bar, bottom nav, wires DataSync -> panels
      RollPanel.lua / IndexPanel.lua / RebirthPanel.lua / ShopPanel.lua / QuestPanel.lua
      DailyRewardPopup.lua / Notification.lua / OverheadTitle.lua
```

The entire GUI is built at runtime from Lua (no `.rbxmx`/`.rbxm` binary blobs), so
every pixel of it is readable, diffable, and editable as code.

## Visual theme: Pusheen

Every panel is built from the same handful of `UIFactory.lua` components, so
the whole game reskins from one file. The palette and behavior:

- **Palette** — warm cream/white backdrops (`Background`/`Panel`) with a
  blush-pink primary accent (`Accent`) and a soft lavender secondary glow
  (`Violet`, Pusheenicorn-flavored), plus pastel rarity colors on `Rarities.lua`.
- **`UIFactory.Card`** — the "hero card" look used for the roll-result reveal,
  Rebirth, Shop, quest entries, the Daily Reward popup, and the bottom nav
  bar: a soft diagonal gradient plus a faint lavender hairline border.
  `UIFactory.UpgradeCardGlow` turns that hairline into a slow, endlessly-pulsing
  glow for a card that should feel special.
- **`UIFactory.Button`** — the primary blush-pink CTA (Roll, Rebirth, Claim,
  Purchase), brightening and scaling up on hover. `UIFactory.SetButtonState`
  flips it between Gold (default) / Success (active green, ready to claim) /
  Owned (inactive green, already purchased) / Disabled (inactive grey) /
  Danger, so call sites never hand-roll colors or accidentally make a
  "ready to claim" button unclickable.
- **`UIFactory.NavButton`** — the quieter bottom-nav style; its `setActive`
  closure handles the dim ↔ glowing-pink transition, also reused for the
  Auto-Roll toggle in `RollPanel`.
- **Rarity-reactive glow** — `RollPanel`'s result card border recolors to the
  rolled rarity every time, pulses for Epic+, and cycles a full rainbow for
  Secret-tier pulls, backed by an expanding "burst ring" and a little paw/heart
  confetti pop for Epic+ (`Effects.lua`). `IndexPanel` mirrors this: every
  discovered title keeps a permanent rarity-tinted border, and whichever one
  is currently equipped gets the same pulsing/rainbow glow treatment.
- **Animation everywhere** (`Effects.lua`) — switching tabs pops the new panel
  in with a little overshoot, the top-bar coins/rebirths count up instead of
  snapping when they change, a paw icon gently bobs in the top bar, and
  notifications/the daily reward modal scale in with a bounce.
- **Fonts** — `FontDisplay` (FredokaOne) for big reveal moments and reward
  numbers, `Font` (GothamBlack) for headers/buttons, `FontMedium`/`FontRegular`
  (Gotham) for body text.

To reskin: change the color/font tokens at the top of `UIFactory.lua` and every
panel updates automatically, since none of them hardcode colors — they all
pull from `UIFactory.Theme`.

## Setup

1. Install [Aftman](https://github.com/LPGhatguy/aftman) (or install
   [Rojo](https://rojo.space/) directly), then run:
   ```
   aftman install
   ```
2. Start the Rojo server:
   ```
   rojo serve
   ```
3. In Roblox Studio, install the **Rojo** plugin, open a new/existing place,
   and click **Connect** in the Rojo plugin panel. Your whole file tree
   syncs in live.
4. Alternatively, build a place file directly without Studio open:
   ```
   rojo build -o Game.rbxlx
   ```

## Before you publish

- **VIP Gamepass**: `Config.GamepassIds.VIP` is `0` by default, which safely
  no-ops all VIP purchase logic (no errors). Create a real Gamepass in the
  Creator Dashboard and paste its asset id into
  `src/ReplicatedStorage/Shared/Config.lua`.
- **DataStores**: `DataService.lua` uses `Config.DataStoreName`. DataStores
  don't work in Studio unless you enable **Game Settings → Security →
  Enable Studio Access to API Services**, or you can just test locally —
  the game falls back to fresh data if a save can't be read.
- Every number that affects game feel (roll cost curve, rarity odds, rebirth
  cost curve, pity threshold, AFK cap, VIP multipliers, daily streak
  rewards) lives in one place: `Config.lua` and `Rarities.lua`.

## Fixed in this update

Two real bugs made the game feel non-functional and are now fixed:

1. **New players couldn't roll.** They started with 0 coins against a 50-coin
   roll cost, so every click just silently failed with an easy-to-miss toast.
   `Config.StartingCoins` is now 150 (3 free rolls up front).
2. **A join-time race could permanently drop your data.** The server pushed
   your save once via a fire-and-forget event right after you joined; if your
   client wasn't listening yet (very plausible in Studio, especially with
   DataStores disabled), that payload — which is what populates the Quests
   tab, your coins, everything — was gone for good, since nothing re-sent it
   until a successful roll (which bug #1 was also blocking). Fixed with a
   `RequestSync` request/response the client pulls once its own listeners are
   wired up, so it's never just hoping the server's push arrives in time.

Every button that talks to the server now always shows *some* feedback on
failure (never a silent dead click), and every RemoteFunction call is
pcall-guarded client-side so a dropped connection can't kill a click handler.
