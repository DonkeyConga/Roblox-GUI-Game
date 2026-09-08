# Title Roll RNG

A complete, GUI-driven Roblox RNG game built around rolling for **Titles & Classes**.
Every system here was chosen to make the game "loopy" and worth coming back to:
a rebirth ladder, a permanent collection log, VIP monetization, daily login
streaks, pity-protected RNG, idle/AFK income, an auto-roller, and daily quests
stacked on top of permanent achievements.

The whole UI runs on one custom **"Arcane Royalty" theme** (deep violet-black
backdrops, gilded gold accents, rarity-tinted glowing borders) defined once in
`UIFactory.lua` — see **Visual theme** below for what that looks like and how
to reskin it.

Don't want to use Rojo? See **[MANUAL_SETUP.md](MANUAL_SETUP.md)** for exact
step-by-step instructions to build the same instance hierarchy by hand in
Roblox Studio.

## Core loop

1. Spend coins to **Roll** for a random Title (7 rarity tiers, weighted RNG).
2. Equip a discovered Title for a passive coin-gain multiplier and a
   BillboardGui tag that follows you around the map.
3. Spend enough coins to **Rebirth**: your coins reset to 0, but you keep a
   permanent % boost to coin gain and luck forever. Costs grow every rebirth.
4. Fill in the **Index** (collection log) by discovering every title in a
   rarity tier for a small permanent luck bonus.
5. Come back daily for a login-streak reward, work through 3 daily quests,
   and chip away at long-term achievements.

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

Full architecture:

```
src/
  ReplicatedStorage/Shared/     -- data tables + Config, shared by server & client
    Config.lua                  -- every tunable number in the game
    Rarities.lua                -- the 7 rarity tiers (weight, color, boost)
    Titles.lua                  -- every rollable title + the VIP-exclusive one
    Quests.lua / Achievements.lua
    RemoteEvents.lua             -- creates/fetches the RemoteEvents & RemoteFunctions
    UIFactory.lua                -- shared theme + Frame/Label/Button/ProgressBar helpers
  ServerScriptService/Server/    -- all authoritative game logic
    Init.server.lua               -- wires remotes to services, the only script that touches them
    DataService.lua               -- DataStore load/save/autosave
    RollService.lua                -- roll cost, weighted RNG, pity, equip
    RebirthService.lua / StreakService.lua / QuestService.lua
    AchievementService.lua / AutoRollService.lua / EconomyService.lua
    GamepassService.lua / LeaderstatsService.lua
  StarterPlayer/StarterPlayerScripts/Client/
    Init.client.lua                -- entry point
    RemoteController.lua           -- typed wrapper over the remotes
    UI/
      MainUI.lua                     -- top bar, bottom nav, wires DataSync -> panels
      RollPanel.lua / IndexPanel.lua / RebirthPanel.lua / ShopPanel.lua / QuestPanel.lua
      DailyRewardPopup.lua / Notification.lua / OverheadTitle.lua
```

The entire GUI is built at runtime from Lua (no `.rbxmx`/`.rbxm` binary blobs), so
every pixel of it is readable, diffable, and editable as code.

## Visual theme: "Arcane Royalty"

Every panel is built from the same handful of `UIFactory.lua` components, so
the whole game reskins from one file. The palette and behavior:

- **Palette** — deep violet-black backdrops (`Background`/`Panel`) with a
  gilded gold primary accent (`Accent`) and a magenta-violet secondary glow
  (`Violet`), fitting the "royal title" fantasy theme.
- **`UIFactory.Card`** — the "hero card" look used for the roll-result reveal,
  Rebirth, Shop, and the Daily Reward popup: a soft diagonal gradient plus a
  faint violet hairline border. `UIFactory.UpgradeCardGlow` turns that hairline
  into a slow, endlessly-pulsing glow for a card that should feel special.
  QuestPanel's entries and the bottom nav bar use the same Card look, so the
  whole game reads as one system.
- **`UIFactory.Button`** — the primary gold-gradient CTA (Roll, Rebirth,
  Claim, Purchase), brightening and scaling up on hover.
  `UIFactory.SetButtonState` flips it between Gold / Success (active green,
  ready to claim) / Owned (inactive green, already purchased) / Disabled
  (inactive grey) / Danger, so call sites never hand-roll colors.
- **`UIFactory.NavButton`** — the quieter bottom-nav style; its `setActive`
  closure handles the dim ↔ glowing-gold transition, also reused for the
  Auto-Roll toggle in `RollPanel`.
- **Rarity-reactive glow** — `RollPanel`'s result card border recolors to the
  rolled rarity every time, pulses for Epic+, and cycles a full rainbow for
  Secret-tier pulls, backed by an expanding "burst ring" that blooms outward
  from the card (bigger for Epic+). `IndexPanel` mirrors this: every
  discovered title keeps a permanent rarity-tinted border, and whichever one
  is currently equipped gets the same pulsing/rainbow glow treatment.
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
