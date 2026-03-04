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

    const result = await client.callTool({
        name: "get_file_nodes",
        arguments: {
            url: "https://www.figma.com/design/BeeHZXJXOwpc3qIHxFiQUJ/CRICSTATZ?node-id=158-6809&t=sQh4IDsFHb9ObNNd-4"
        }
    });

    const texts = [];
    const rawNodes = [];

    function extractText(node) {
        if (!node) return;
        if (node.type === 'TEXT') {
            texts.push({ text: node.characters, x: node.absoluteBoundingBox?.x, y: node.absoluteBoundingBox?.y });
        }
        if (node.children) node.children.forEach(extractText);
        if (node.document) extractText(node.document);
        if (node.nodes) Object.values(node.nodes).forEach(n => extractText(n.document));
    }

    const parsed = JSON.parse(result.content[0].text);
    extractText(parsed);

    // Sort visually from top to bottom
    texts.sort((a, b) => (a.y || 0) - (b.y || 0));

    const outPath = "../scoring_design_text.json";
    fs.writeFileSync(outPath, JSON.stringify(texts.map(t => t.text), null, 2));
    console.log(`Saved Figma node data to ${outPath}`);

    process.exit(0);
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
