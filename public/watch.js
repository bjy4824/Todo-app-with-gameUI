const params = new URLSearchParams(location.search);
const gameId = params.get("game")?.toUpperCase();
const homeScore = document.querySelector("#homeScore");
const awayScore = document.querySelector("#awayScore");
const gameIdLabel = document.querySelector("#gameId");

gameIdLabel.textContent = gameId || "------";

async function request(path, body) {
  const response = await fetch(path, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body || {})
  });
  if (!response.ok) throw new Error("request failed");
  return response.json();
}

if (gameId) {
  const source = new EventSource(`/api/games/${gameId}/events`);
  source.addEventListener("score", (event) => {
    const game = JSON.parse(event.data);
    homeScore.textContent = game.home;
    awayScore.textContent = game.away;
  });
}

document.addEventListener("click", (event) => {
  const button = event.target.closest("[data-team][data-delta]");
  if (!button || !gameId) return;
  request(`/api/games/${gameId}/score`, {
    team: button.dataset.team,
    delta: Number(button.dataset.delta)
  });
});
