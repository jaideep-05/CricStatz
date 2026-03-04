const ws = new WebSocket('ws://localhost:3055');

ws.addEventListener('open', () => {
    ws.send(JSON.stringify({
        jsonrpc: "2.0",
        id: 1,
        method: "tools/call",
        params: {
            name: "get_file_nodes",
            arguments: {
                url: "https://www.figma.com/design/BeeHZXJXOwpc3qIHxFiQUJ/CRICSTATZ?node-id=158-6809&t=sQh4IDsFHb9ObNNd-4"
            }
        }
    }));
});

ws.addEventListener('message', async (event) => {
    const response = JSON.parse(event.data.toString());
    const fs = require('fs');
    if (response.result && response.result.content && response.result.content[0].text) {
        fs.writeFileSync('figma_scoring_raw.json', response.result.content[0].text);
        console.log('SUCCESS');
    } else {
        console.log('Failed to match structure: ' + JSON.stringify(response));
    }
    process.exit(0);
});
