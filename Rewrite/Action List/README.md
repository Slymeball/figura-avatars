<p align="center"><img src="https://github.com/Slymeball/figura-avatars/blob/main/Icons/actionlist%20icon.png?raw=true" width=25%></p>
<h1 align="center">Action List - Alternative Frontend for the Action Wheel</h1>

Action List gives you a different way to access your Action Wheel. It replaces the keybind used by it and shows a scrollable list of your actions.

![A picture of Action List being used.](https://github.com/Slymeball/figura-avatars/blob/main/preview/Action%20List.png?raw=true)

# Known Flaws
- Action texture icons are ignored.
  - However, I could probably implement this just like I did with item icons, just with sprite tasks instead of item tasks.
- Some item icons are not loaded.
  - This is an issue with the way grabbing action items are handled. What it does is replace the metatable function for setting an action's items (including hover and toggle). Unfortunately, I have no way to guaruntee that the metatable replacement will be done before all other scripts that deal with the action wheel, thus causing some to slip by. The icons for those will be Yellow Concrete as a fallback.

# Download
You can download Action List @ <INSERT LINK>
