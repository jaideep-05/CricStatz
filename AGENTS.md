# CricStatz – Codex Instructions

## Figma Design Context

When asked to get design context, implement a Figma design, or fetch screens **without a URL**, use `figma.config.json` in the project root:

1. Read `figma.config.json`
2. Use `fileKey` and `defaultNodeId` (or `screens.home` for Home) for Figma MCP tools
3. Use `nodeId` in colon format (e.g. `139:4519`)

**Current config:**
- File: CRICSTATZ
- fileKey: `BeeHZXJXOwpc3qIHxFiQUJ`
- Home: nodeId `139:4519`
- Upcoming: nodeId `145:3550`

When the user provides a Figma URL, use that instead and ignore the config.
