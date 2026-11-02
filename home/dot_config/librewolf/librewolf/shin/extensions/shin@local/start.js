"use strict";

// ~/links: [shortcut, name, url, search url (%s = what you type after the shortcut)].
// At the prompt, "gh" opens GitHub and "gh helix" searches it; anything else
// is opened as an address or searched with the default engine.
const LINKS = {
  dev: [
    ["gh", "github", "https://github.com", "https://github.com/search?q=%s"],
    ["aw", "archwiki", "https://wiki.archlinux.org", "https://wiki.archlinux.org/index.php?search=%s"],
    ["aur", "aur", "https://aur.archlinux.org", "https://aur.archlinux.org/packages?K=%s"],
    ["cl", "claude", "https://claude.ai"],
  ],
  media: [
    ["yt", "youtube", "https://www.youtube.com", "https://www.youtube.com/results?search_query=%s"],
    ["rd", "reddit", "https://www.reddit.com", "https://www.reddit.com/search/?q=%s"],
    ["up", "unixporn", "https://www.reddit.com/r/unixporn"],
  ],
  uiuc: [
    ["cv", "canvas", "https://canvas.illinois.edu"],
    ["ml", "mail", "https://outlook.office.com/mail/"],
  ],
  steam: [
    ["st", "store", "https://store.steampowered.com", "https://store.steampowered.com/search/?term=%s"],
    ["db", "steamdb", "https://steamdb.info", "https://steamdb.info/search/?q=%s"],
    ["cs", "market", "https://steamcommunity.com/market/search?appid=730", "https://steamcommunity.com/market/search?appid=730&q=%s"],
  ],
};

const $ = (id) => document.getElementById(id);
const input = $("q");
const status = $("status");
const shortcuts = new Map();
let engine = "the default engine";

// ls ~/links
for (const [dir, links] of Object.entries(LINKS)) {
  const column = document.createElement("div");
  const heading = document.createElement("h2");
  heading.textContent = dir + "/";
  const list = document.createElement("ul");
  for (const [key, name, url, search] of links) {
    const a = document.createElement("a");
    a.href = url;
    const kbd = document.createElement("kbd");
    kbd.textContent = key;
    a.append(kbd, name);
    const item = document.createElement("li");
    item.append(a);
    list.append(item);
    shortcuts.set(key, { name, url, search, element: a });
  }
  column.append(heading, list);
  $("links").append(column);
}

// fastfetch's clock lines and the pane frame's clock
const two = (n) => String(n).padStart(2, "0");
function isoWeek(date) {
  const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
  return Math.ceil(((d - Date.UTC(d.getUTCFullYear(), 0, 1)) / 86400000 + 1) / 7);
}
function tick() {
  const now = new Date();
  const hm = `${two(now.getHours())}:${two(now.getMinutes())}`;
  $("pane-clock").textContent = hm;
  $("time").textContent = `${hm}:${two(now.getSeconds())}`;
  $("date").textContent = now.toLocaleDateString("en-US", { weekday: "long", month: "long", day: "numeric", year: "numeric" }).toLowerCase();
  $("week").textContent = `w${isoWeek(now)}`;
}
tick();
setInterval(tick, 1000);

// What the prompt would do with its text: [description, action].
function looksLikeAddress(text) {
  return /^[a-z][a-z0-9+.-]*:\/\/\S+$/i.test(text) || /^(localhost|[\w-]+(\.[\w-]+)+)(:\d+)?(\/\S*)?$/i.test(text);
}
function plan(text) {
  const [first, ...rest] = text.split(/\s+/);
  const query = rest.join(" ");
  const link = shortcuts.get(first);
  if (link && !query) return { link, describe: `open ${link.url}`, url: link.url };
  if (link && link.search) {
    return { link, describe: `search ${link.name} for "${query}"`, url: link.search.replace("%s", encodeURIComponent(query)) };
  }
  if (looksLikeAddress(text)) {
    const url = /^[a-z][a-z0-9+.-]*:\/\//i.test(text) ? text : `https://${text}`;
    return { describe: `open ${url}`, url };
  }
  return { describe: `search ${engine.toLowerCase()} for "${text}"`, query: text };
}

function update() {
  const text = input.value.trim();
  for (const { element } of shortcuts.values()) element.classList.remove("match");
  if (!text) {
    status.textContent = "type a shortcut (gh, gh helix), an address or a search · esc clears";
    return;
  }
  const next = plan(text);
  next.link?.element.classList.add("match");
  status.textContent = `enter: ${next.describe}`;
}

input.addEventListener("input", update);
$("cmdline").addEventListener("submit", async (event) => {
  event.preventDefault();
  const text = input.value.trim();
  if (!text) return;
  const next = plan(text);
  if (next.url) {
    location.href = next.url;
  } else if (browser.search?.query) {
    browser.search.query({ text: next.query, disposition: "CURRENT_TAB" });
  } else if (browser.search) {
    browser.search.search({ query: next.query, tabId: (await browser.tabs.getCurrent()).id });
  } else {
    location.href = `https://duckduckgo.com/?q=${encodeURIComponent(next.query)}`;
  }
});

// Typing anywhere on the page goes to the prompt; Esc clears it.
document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    input.value = "";
    update();
    input.blur();
  } else if (document.activeElement !== input && event.key.length === 1 && !event.ctrlKey && !event.altKey && !event.metaKey) {
    input.focus();
  }
});

// Hovering a link shows where it goes, like a terminal's status line.
document.addEventListener("mouseover", (event) => {
  const a = event.target.closest?.(".ls a");
  if (a) status.textContent = a.href;
});
document.addEventListener("mouseout", (event) => {
  if (event.target.closest?.(".ls a")) update();
});

update();

// Extension APIs last: the page still works if they aren't there.
browser.runtime?.getBrowserInfo().then(({ name, version }) => {
  $("browser").textContent = `${name.toLowerCase()} ${version}`;
});
browser.search?.get().then((engines) => {
  engine = engines.find((e) => e.isDefault)?.name ?? engine;
  $("engine").textContent = engine.toLowerCase();
  update();
});
