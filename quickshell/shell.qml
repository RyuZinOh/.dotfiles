import Quickshell
import qs.Modules.Home
// import qs.Modules.Hyperixon
import qs.Modules.Bar
import qs.Services.Lock
import qs.Services.Notification

ShellRoot {
    Scope {
        // Hyperixon {} [ts is game changer-> will only so many possibilities with ease of life]
        Bar {}
        Home {}
        Locker {}//Lock service

    }
    /* Notification system *pin
     [since Hyperixon is arrived now i dont need a panel window in this NotificationWindow, will implement it later directly to the Hyperixon ]
     */
    NotificationWindow {
        id: notifWindow
    }
}
