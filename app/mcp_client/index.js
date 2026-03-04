const { Client } = require("@modelcontextprotocol/sdk/client/index.js");
const { StdioClientTransport } = require("@modelcontextprotocol/sdk/client/stdio.js");
const fs = require("fs");

async function main() {
    const transport = new StdioClientTransport({
        command: "bunx",
        args: ["cursor-talk-to-figma-mcp@latest"]
    });

    const client = new Client(
        { name: "figma-extractor", version: "1.0.0" },
        { capabilities: { tools: {} } }
    );

    await client.connect(transport);
    console.log("Connected to MCP server");

    const tools = await client.listTools();
    console.log("Available tools:", tools.tools.map(t => t.name));

    const result = await client.callTool({
        name: "get_file_nodes",
        arguments: {
            url: "https://www.figma.com/design/BeeHZXJXOwpc3qIHxFiQUJ/CRICSTATZ?node-id=154-5222"
        }
    });

    const outPath = "../squad_design.json";
    fs.writeFileSync(outPath, JSON.stringify(result, null, 2));
    console.log(`Saved Figma node data to ${outPath}`);

    process.exit(0);
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
