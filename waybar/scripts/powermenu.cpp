#include <iostream>
#include <string>
#include <cstdlib>

#define ICON_SHUTDOWN ""
#define ICON_RESTART ""

int main() {
    std::string choice;

    std::cout << "Power Menu:\n";
    std::cout << "1) Shutdown " << ICON_SHUTDOWN << "\n";
    std::cout << "2) Restart " << ICON_RESTART << "\n";
    std::cout << "Enter choice number: ";
    std::cin >> choice;

    if (choice == "1") {
        std::cout << "\nShutting down...\n";
        system("systemctl poweroff");
    } 
    else if (choice == "2") {
        std::cout << "\nRestarting...\n";
        system("systemctl reboot");
    } 
    else {
        std::cout << "\nInvalid choice! Exiting.\n";
    }

    return 0;
}
