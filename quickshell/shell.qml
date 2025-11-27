import Quickshell
import qs.Modules.Home
import qs.Modules.Bar
import qs.Services.Lock
import qs.Services.Notification

ShellRoot {
    Scope {
        Bar {}
        Home {}
        Locker {}//Lock service

    }
    // Notification system
    NotificationWindow {
        id: notifWindow
    }
}
