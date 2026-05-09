pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.LocalStorage

QtObject {
    id: root

    readonly property var db: LocalStorage.openDatabaseSync("malDB", "1.0", "MAL Database", 1000000)

    function init() {
        db.transaction(tx => {
            tx.executeSql("CREATE TABLE IF NOT EXISTS events (month INT, day INT, title TEXT, description TEXT)");
        });
    }

    function get(month, day) {
        var result = null;
        db.readTransaction(tx => {
            const r = tx.executeSql("SELECT title, description FROM events WHERE month = ? AND day = ?", [month, day]);
            if (r.rows.length > 0)
                result = {
                    title: r.rows.item(0).title,
                    description: r.rows.item(0).description
                };
        });
        return result;
    }

    function save(month, day, title, desc) {
        db.transaction(tx => {
            tx.executeSql("DELETE FROM events WHERE month = ? AND day = ?", [month, day]);
            tx.executeSql("INSERT INTO events VALUES (?, ?, ?, ?)", [month, day, title, desc]);
        });
    }

    function remove(month, day) {
        db.transaction(tx => {
            tx.executeSql("DELETE FROM events WHERE month = ? AND day = ?", [month, day]);
        });
    }
}
