# CRICSTATZ – Pages & Navigation

All pages from the Figma prototype and their navigation connections.

## Figma Screens Implemented

| Screen | Figma Node | Route | Status |
|--------|------------|-------|--------|
| **Home** | 139:4519 | `/` | ✅ Implemented |
| **Upcoming** (International Fixtures) | 145:3550 | `/matches` | ✅ Implemented |
| **Results** | — | `/stats/match` | ✅ Implemented |
| **My Matches** | — | `/my-matches` | ✅ Placeholder |
| **Feed** | — | `/feed` | ✅ Placeholder |
| **Search** (Teams) | — | `/teams` | ✅ Implemented |
| **Chats** (Scoring) | — | `/scoring` | ✅ Implemented |
| **Profile** (Player Stats) | — | `/stats/player` | ✅ Implemented |

## Navigation Flow (Connected Pages)

```
┌─────────────────────────────────────────────────────────────────┐
│                         BOTTOM NAV BAR                            │
│  Home(0) │ Feed(1) │ Search(2) │ Chats(3) │ Profile(4)          │
└─────────────────────────────────────────────────────────────────┘
     │          │          │          │          │
     ▼          ▼          ▼          ▼          ▼
   Home       Feed      Teams    Scoring   PlayerStats
     │
     │  QUICK TABS (Home only)
     │  Live │ Upcoming │ Results │ My Matches
     │    │       │         │           │
     │    │       ▼         ▼           ▼
     │    │   Matches   MatchStats   MyMatches
     │    │      │          │
     │    │      │          └── View Scorecard
     │    │      │
     │    │      └── Start Match → TossScreen
     │    │      └── Details → CreateMatchScreen
     │    │
     │    └── View Full Scorecard → MatchStatsScreen
     │
     └── FAB (+) → CreateMatchScreen
```

## Connection Summary

### From Home (`/`)
- **Tab Upcoming** → `/matches` (MatchListScreen)
- **Tab Results** → `/stats/match` (MatchStatsScreen)
- **Tab My Matches** → `/my-matches` (MyMatchesScreen)
- **View Full Scorecard** → `/stats/match`
- **View All** (Upcoming) → `/matches`
- **FAB (+)** → `/matches/create` (CreateMatchScreen)
- **Bottom nav** → Feed, Teams, Scoring, Profile

### From Upcoming / Matches (`/matches`)
- **Tab Live** → `/` (Home)
- **Tab Results** → `/stats/match`
- **Tab My Matches** → `/my-matches`
- **Start Match** → `/matches/toss` (TossScreen)
- **Details** → `/matches/create`
- **Set Reminder** → SnackBar (coming soon)
- **Bottom nav** → Home, Feed, Teams, Scoring, Profile

### From Results (`/stats/match`)
- **Tab Live** → `/`
- **Tab Upcoming** → `/matches`
- **Tab My Matches** → `/my-matches`
- **View Scorecard** → (placeholder)
- **Bottom nav** → Home, Feed, Teams, Scoring, Profile

### From My Matches (`/my-matches`)
- **Create Match** → `/matches/create`
- **FAB (+)** → `/matches/create`
- **Bottom nav** → Home, Feed, Teams, Scoring, Profile

### From Teams (`/teams`)
- **Create Team** → `/teams/create`
- **FAB (+)** → `/teams/create`
- **Bottom nav** → Home, Feed, Teams, Scoring, Profile

### From Scoring (`/scoring`)
- **Bottom nav** → Home, Feed, Teams, Scoring, Profile

### From Profile (`/stats/player`)
- **Back** → `Navigator.pop`
- **Bottom nav** → Home, Feed, Teams, Scoring, Profile

## Routes Reference

| Route | Screen |
|-------|--------|
| `/` | HomeScreen |
| `/feed` | FeedScreen |
| `/teams` | TeamListScreen |
| `/teams/create` | CreateTeamScreen |
| `/matches` | MatchListScreen |
| `/my-matches` | MyMatchesScreen |
| `/matches/create` | CreateMatchScreen |
| `/matches/toss` | TossScreen |
| `/scoring` | ScoringScreen |
| `/stats/player` | PlayerStatsScreen |
| `/stats/match` | MatchStatsScreen |
