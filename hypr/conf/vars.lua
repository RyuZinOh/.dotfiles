return {
	qs = "qs -p ~/.config/quickshell/ryu-shell",
	terminal = "kitty",
	browser = "helium-browser",

	-- update the environment variables correspondigly
	internal_keyboard = os.getenv("INTERNAL_KEYBOARD"),
	external_keyboard = os.getenv("EXTERNAL_KEYBOARD"),
	touchpad = os.getenv("TOUCHPAD_DEVICE"),
	touchpad_mouse = os.getenv("TOUCHPAD_MOUSE"),
	touch_screen = os.getenv("TOUCH_SCREEN"),
}
