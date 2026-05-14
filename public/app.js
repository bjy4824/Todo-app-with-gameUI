const storageKey = "touch-score.current-match";

const homeScore = document.querySelector("#homeScore");
const awayScore = document.querySelector("#awayScore");
const homeName = document.querySelector("#homeName");
const awayName = document.querySelector("#awayName");
const gameIdLabel = document.querySelector("#gameId");
const watchLink = document.querySelector("#watchLink");
const remoteUrl = document.querySelector("#remoteUrl");
const resetButton = document.querySelector("#resetButton");
const undoButton = document.querySelector("#undoButton");
const copyButton = document.querySelector("#copyButton");
const syncStatus = document.querySelector("#syncStatus");
const timerDisplay = document.querySelector("#timerDisplay");
const timerToggle = document.querySelector("#timerToggle");
const timerReset = document.querySelector("#timerReset");

let source;
let state = loadState();

function defaultState() {
  return {
    gameId: new URLSearchParams(location.search).get("game")?.toUpperCase() || null,
    home: 0,
    away: 0,
    homeName: "HOME",
    awayName: "AWAY",
    timerSeconds: 0,
    timerRunning: false,
    timerStartedAt: null,
    history: []
  };
}

function loadState() {
  try {
    return { ...defaultState(), ...JSON.parse(localStorage.getItem(storageKey)) };
  } catch {
    return defaultState();
  }
}

function saveState() {
  localStorage.setItem(storageKey, JSON.stringify(state));
}

async function request(path, body) {
  const response = await fetch(path, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body || {})
  });
  if (!response.ok) throw new Error("request failed");
  return response.json();
}

function elapsedSeconds() {
  if (!state.timerRunning || !state.timerStartedAt) return state.timerSeconds;
  return state.timerSeconds + Math.floor((Date.now() - state.timerStartedAt) / 1000);
}

function formatTime(seconds) {
  const minutes = Math.floor(seconds / 60).toString().padStart(2, "0");
  const rest = (seconds % 60).toString().padStart(2, "0");
  return `${minutes}:${rest}`;
}

function render() {
  homeScore.textContent = state.home;
  awayScore.textContent = state.away;
  homeName.value = state.homeName;
  awayName.value = state.awayName;
  gameIdLabel.textContent = state.gameId || "LOCAL";
  timerDisplay.textContent = formatTime(elapsedSeconds());
  timerToggle.textContent = state.timerRunning ? "PAUSE" : "START";
  undoButton.disabled = state.history.length === 0;

  const watchUrl = state.gameId ? `${location.origin}/watch.html?game=${state.gameId}` : "";
  watchLink.href = watchUrl || "/watch.html";
  remoteUrl.textContent = watchUrl || "오프라인 모드입니다. 서버가 켜지면 워치용 주소가 표시됩니다.";
  syncStatus.textContent = state.gameId && navigator.onLine ? "ONLINE" : "LOCAL";
}

function commit() {
  saveState();
  render();
}

async function ensureGame() {
  if (state.gameId) {
    history.replaceState(null, "", `/?game=${state.gameId}`);
    connect();
    render();
    return;
  }

  try {
    const game = await request("/api/games");
    state.gameId = game.id;
    history.replaceState(null, "", `/?game=${state.gameId}`);
    connect();
  } catch {
    state.gameId = null;
  }

  commit();
}

function connect() {
  if (!state.gameId) return;
  source?.close();
  source = new EventSource(`/api/games/${state.gameId}/events`);
  source.addEventListener("score", (event) => {
    const game = JSON.parse(event.data);
    state.home = game.home;
    state.away = game.away;
    commit();
  });
  source.addEventListener("error", () => {
    syncStatus.textContent = "LOCAL";
  });
}

async function syncScore(team, delta) {
  if (!state.gameId) return;
  try {
    await request(`/api/games/${state.gameId}/score`, { team, delta });
  } catch {
    syncStatus.textContent = "LOCAL";
  }
}

function changeScore(team, delta) {
  state.history.push({
    type: "score",
    team,
    delta,
    before: state[team],
    at: Date.now()
  });
  state[team] = Math.max(0, state[team] + delta);
  commit();
  syncScore(team, delta);
}

function undoLast() {
  const item = state.history.pop();
  if (!item) return;

  if (item.type === "score") {
    const correction = item.before - state[item.team];
    state[item.team] = item.before;
    commit();
    syncScore(item.team, correction);
  } else if (item.type === "reset") {
    state.home = item.before.home;
    state.away = item.before.away;
    state.timerSeconds = item.before.timerSeconds;
    state.timerRunning = item.before.timerRunning;
    state.timerStartedAt = item.before.timerRunning ? Date.now() : null;
    commit();
    if (state.gameId) {
      request(`/api/games/${state.gameId}/reset`)
        .then(() => Promise.all([
          request(`/api/games/${state.gameId}/score`, { team: "home", delta: state.home }),
          request(`/api/games/${state.gameId}/score`, { team: "away", delta: state.away })
        ]))
        .catch(() => {
          syncStatus.textContent = "LOCAL";
        });
    }
  }
}

function resetMatch() {
  state.history.push({
    type: "reset",
    before: {
      home: state.home,
      away: state.away,
      timerSeconds: elapsedSeconds(),
      timerRunning: state.timerRunning
    },
    at: Date.now()
  });
  state.home = 0;
  state.away = 0;
  state.timerSeconds = 0;
  state.timerRunning = false;
  state.timerStartedAt = null;
  commit();

  if (state.gameId) {
    request(`/api/games/${state.gameId}/reset`).catch(() => {
      syncStatus.textContent = "LOCAL";
    });
  }
}

function toggleTimer() {
  if (state.timerRunning) {
    state.timerSeconds = elapsedSeconds();
    state.timerRunning = false;
    state.timerStartedAt = null;
  } else {
    state.timerRunning = true;
    state.timerStartedAt = Date.now();
  }
  commit();
}

function resetTimer() {
  state.timerSeconds = 0;
  state.timerRunning = false;
  state.timerStartedAt = null;
  commit();
}

document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-team][data-delta]");
  if (!button) return;
  changeScore(button.dataset.team, Number(button.dataset.delta));
});

document.addEventListener("keydown", (event) => {
  const keyMap = {
    q: ["home", 1],
    a: ["home", -1],
    p: ["away", 1],
    l: ["away", -1],
    z: ["undo"]
  };
  const action = keyMap[event.key.toLowerCase()];
  if (!action) return;
  if (action[0] === "undo") undoLast();
  else changeScore(action[0], action[1]);
});

homeName.addEventListener("input", () => {
  state.homeName = homeName.value || "HOME";
  commit();
});

awayName.addEventListener("input", () => {
  state.awayName = awayName.value || "AWAY";
  commit();
});

resetButton.addEventListener("click", resetMatch);
undoButton.addEventListener("click", undoLast);
timerToggle.addEventListener("click", toggleTimer);
timerReset.addEventListener("click", resetTimer);

copyButton.addEventListener("click", async () => {
  if (!remoteUrl.textContent.startsWith("http")) return;
  await navigator.clipboard.writeText(remoteUrl.textContent);
  copyButton.textContent = "COPIED";
  setTimeout(() => {
    copyButton.textContent = "COPY";
  }, 1200);
});

window.addEventListener("online", render);
window.addEventListener("offline", render);

render();
ensureGame();
setInterval(render, 500);
