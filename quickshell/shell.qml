import Quickshell
import qs.Modules.Home
import qs.Modules.Hyperixon
import qs.Services.Lock

ShellRoot {
    Scope {
        Hyperixon {}  // ovelay
        Home {} // background
        Locker {}//Lock service
    }
}
