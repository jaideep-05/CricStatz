// Use native WebSocket in Node 25
const ws = new WebSocket('ws://localhost:3055');

ws.addEventListener('open', () => {
    console.log('Connected to Figma MCP WebSocket');

    const request = {
        jsonrpc: "2.0",
        id: 1,
        method: "tools/call",
        params: {
            name: "get_file_nodes",
            arguments: {
                url: "https://www.figma.com/design/BeeHZXJXOwpc3qIHxFiQUJ/CRICSTATZ?node-id=154-5222&t=sQh4IDsFHb9ObNNd-4"
            }
        }
    };

    ws.send(JSON.stringify(request));
    console.log('Sent request:', request);
});

ws.addEventListener('message', async (event) => {
    console.log('Received response:');
    const response = JSON.parse(event.data.toString());

    // Write the giant JSON response to a file so it doesn't flood the terminal
    const fs = require('fs');
    fs.writeFileSync('figma_squads_node.json', JSON.stringify(response, null, 2));
    console.log('Saved response to figma_squads_node.json');
    process.exit(0);
});

ws.addEventListener('error', (err) => {
    console.error('WebSocket Error:', err);
    process.exit(1);
});

setTimeout(() => {
    console.log('Timeout waiting for response');
    process.exit(1);
}, 15000);
