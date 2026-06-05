pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.LocalStorage

QtObject {
    id: root

    readonly property var db: LocalStorage.openDatabaseSync("soulEaterDB", "1.0", "SoulEater Database", 1000000)

    function getByDate(month, day) {
        const mm = String(month + 1).padStart(2, "0");
        const dd = String(day).padStart(2, "0");
        const dateStr = mm + "-" + dd;
        var results = [];
        db.readTransaction(tx => {
            const r = tx.executeSql("select   sprite_location from genshin where birthday = ?", [dateStr]);
            for (let i = 0; i < r.rows.length; i++) {
                const row = r.rows.item(i);
                results.push({
                    character: row.character,
                    dialogue: row.dialogue,
                    sprite: row.sprite_location
                });
            }
        });
        return results;
    }
}
