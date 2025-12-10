import Quickshell
import qs.Modules.Home
import qs.Modules.Hyperixon
import qs.Modules.Bar
import qs.Services.Lock

ShellRoot {
    Scope {
        Hyperixon {}  // ovelay 
        Bar {}
        Home {} // background
        Locker {}//Lock service
    }
}
