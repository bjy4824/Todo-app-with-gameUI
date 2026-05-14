import http from "node:http";
import { readFile } from "node:fs/promises";
import { extname, join, normalize } from "node:path";
import { networkInterfaces } from "node:os";

const port = Number(process.env.PORT || 3000);
const publicDir = join(process.cwd(), "public");
const games = new Map();

function createGameId() {
  return Math.random().toString(36).slice(2, 8).toUpperCase();
}

function getGame(id) {
  if (!games.has(id)) {
    games.set(id, {
      id,
      home: 0,
      away: 0,
      history: [],
      clients: new Set()
    });
  }
  return games.get(id);
}

function serialize(game) {
  return JSON.stringify({
    id: game.id,
    home: game.home,
    away: game.away,
    history: game.history.slice(-20)
  });
}

function broadcast(game) {
  const payload = `event: score\ndata: ${serialize(game)}\n\n`;
  for (const client of game.clients) {
    client.write(payload);
  }
}

function localAddresses() {
  const results = [];
  for (const items of Object.values(networkInterfaces())) {
    for (const item of items || []) {
      if (item.family === "IPv4" && !item.internal) {
        results.push(item.address);
      }
    }
  }
  return results;
}

function sendJson(res, status, data) {
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store"
  });
  res.end(JSON.stringify(data));
}

async function readBody(req) {
  const chunks = [];
  for await (const chunk of req) {
    chunks.push(chunk);
  }
  return JSON.parse(Buffer.concat(chunks).toString("utf8") || "{}");
}

async function serveStatic(req, res) {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const pathname = url.pathname === "/" ? "/index.html" : url.pathname;
  const safePath = normalize(pathname).replace(/^(\.\.[/\\])+/, "");
  const filePath = join(publicDir, safePath);
  const types = {
    ".html": "text/html; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".js": "text/javascript; charset=utf-8",
    ".json": "application/json; charset=utf-8",
    ".svg": "image/svg+xml"
  };

  try {
    const file = await readFile(filePath);
    res.writeHead(200, {
      "Content-Type": types[extname(filePath)] || "application/octet-stream",
      "Cache-Control": "no-store"
    });
    res.end(file);
  } catch {
    res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    res.end("Not found");
  }
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (req.method === "POST" && url.pathname === "/api/games") {
    const game = getGame(createGameId());
    return sendJson(res, 201, JSON.parse(serialize(game)));
  }

  if (req.method === "GET" && url.pathname.startsWith("/api/games/")) {
    const [, , , gameId, stream] = url.pathname.split("/");
    const game = getGame(gameId?.toUpperCase());

    if (stream === "events") {
      res.writeHead(200, {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-store",
        Connection: "keep-alive",
        "Access-Control-Allow-Origin": "*"
      });
      res.write(`event: score\ndata: ${serialize(game)}\n\n`);
      game.clients.add(res);
      req.on("close", () => game.clients.delete(res));
      return;
    }

    return sendJson(res, 200, JSON.parse(serialize(game)));
  }

  if (req.method === "POST" && url.pathname.startsWith("/api/games/")) {
    try {
      const [, , , gameId, action] = url.pathname.split("/");
      const game = getGame(gameId?.toUpperCase());
      const body = await readBody(req);
      const team = body.team === "away" ? "away" : "home";

      if (action === "score") {
        const delta = Number(body.delta || 0);
        game[team] = Math.max(0, game[team] + delta);
        game.history.push({ team, delta, at: Date.now() });
      } else if (action === "reset") {
        game.home = 0;
        game.away = 0;
        game.history.push({ team: "both", delta: "reset", at: Date.now() });
      } else {
        return sendJson(res, 404, { error: "Unknown action" });
      }

      broadcast(game);
      return sendJson(res, 200, JSON.parse(serialize(game)));
    } catch {
      return sendJson(res, 400, { error: "Bad request" });
    }
  }

  return serveStatic(req, res);
});

server.listen(port, () => {
  const urls = [`http://localhost:${port}`, ...localAddresses().map((ip) => `http://${ip}:${port}`)];
  console.log("Scoreboard running:");
  for (const url of urls) {
    console.log(`  ${url}`);
  }
});
