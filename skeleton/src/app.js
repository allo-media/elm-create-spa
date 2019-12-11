import { Elm } from './Main.elm';

// The localStorage key to use to store serialized session data
const storeKey = `store`;
const apiURL = process.env.API_URL || location.origin + location.pathname;

const app = Elm.Main.init({
  flags: {
    clientUrl: apiURL,
    rawStore: localStorage[storeKey] || ""
  }
});

app.ports.saveStore.subscribe((rawStore) => {
  localStorage[storeKey] = rawStore;
});

// Ensure session is refreshed when it changes in another tab/window
window.addEventListener("storage", (event) => {
  if (event.storageArea === localStorage && event.key === storeKey) {
    app.ports.storeChanged.send(event.newValue);
  }
}, false);
