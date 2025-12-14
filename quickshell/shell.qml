import Quickshell
import qs.Modules.Home
import qs.Modules.Hyperixon
// import qs.Modules.Bar
import qs.Services.Lock

ShellRoot {
    Scope {
        Hyperixon {}  // ovelay
        // Lemme try Hyperixon [TopJesus as a Bar for some month and decide to scrape it or not, will further modify if I decided to nuke Bar and use topjesus for bar....]
        // Bar {}
        Home {} // background
        Locker {}//Lock service
    }
}
