pragma Singleton
import QtQuick
import Quickshell
import qs.Services.Paths
import Kraken

Singleton {
    id: root

    property bool hyprsunsetActive: false
    property int temperature: 4000
    property int gamma: 80

    readonly property int tempStep: 55
    readonly property int gammaStep: 1
    readonly property int tempMin: 1000
    readonly property int tempMax: 6500
    readonly property int gammaMin: 10
    readonly property int gammaMax: 100
    readonly property string configPath: PathService.home + "/.cache/safalQuick/communication-config.json"

    signal hyprsunsetToggled(bool active)

    function saveConfig() {
        configKraken.set("temperature", root.temperature);
        configKraken.set("gamma", root.gamma);
        configKraken.set("hyprsunsetActive", root.hyprsunsetActive);
        configKraken.save();
    }

    function toggle() {
        hyprsunsetActive = !hyprsunsetActive;
        saveConfig();
        hyprsunsetToggled(hyprsunsetActive);
    }

    function increaseTemperature() {
        temperature = Math.min(tempMax, temperature + tempStep);
        saveConfig();
    }

    function decreaseTemperature() {
        temperature = Math.max(tempMin, temperature - tempStep);
        saveConfig();
    }

    function increaseGamma() {
        gamma = Math.min(gammaMax, gamma + gammaStep);
        saveConfig();
    }

    function decreaseGamma() {
        gamma = Math.max(gammaMin, gamma - gammaStep);
        saveConfig();
    }

    function setTemperature(val: int) {
        temperature = Math.max(tempMin, Math.min(tempMax, val));
        saveConfig();
    }

    function setGamma(val: int) {
        gamma = Math.max(gammaMin, Math.min(gammaMax, val));
        saveConfig();
    }

    Kraken {
        id: configKraken
        filePath: root.configPath
        onDataLoaded: {
            if (loaded && isObject) {
                if (has("temperature"))
                    root.temperature = get("temperature", 4000);
                if (has("gamma"))
                    root.gamma = get("gamma", 80);
                if (has("hyprsunsetActive"))
                    root.hyprsunsetActive = get("hyprsunsetActive", false);
            }
        }
        onLoadFailed: error => {
            console.warn("communication config failed:", error);
            root.saveConfig();
        }
    }
}
