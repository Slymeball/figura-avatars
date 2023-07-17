<p align="center"><img src="https://github.com/Slymeball/figura-avatars/blob/main/Icons/patpat%20icon.png?raw=true" width=25%></p>
<h1 align="center">Patpat - Patting Script for Figura</h1>

A patting script that allows you to pat others (if they allow, more on that later) in-game!

## Petpet Compatibility

Patpat is completely compatible with Petpet, being able to call functions on Petpet scripts and have Petpet scripts call functions on itself. Functions in Patpat also share the same variable names so that conversion is as simple as a copy and paste.

I wanted this to be a simple script to get away from the one made by someone who no longer works for the mod (in lightest terms possible), so everything is made to be compatible with it.

## Multiple Patpat Functions Support

With the library supplied by Patpat, you are able to add multiple functions to one event in Patpat, including:

- `togglePat` (whenever you're patted or no longer patted, returned in `beingPetted` to maintain compatibility)
- `onPat` (whenever you're patted)
- `onUnpat` (whenever you're no longer patted)
- `whilePat` (runs each tick you're patted, returns a list of each patter in `petters`, named to maintain compat.)
- `oncePat` (runs each time a patter swings their arm, returns the `entity` that caused it)

## Disabling Patpat for Self

Maybe you don't enjoy pats, that's fair too. You're able to make sure those using Patpat cannot pat you by adding the following to your avatar:

```lua
avatar:store("patpat.noPats", true)
```

or by uncommenting line 23 in the script. You can also allow patpat but disable particles by adding the following to your avatar:

```lua
avatar:store("patpat.noHearts", true)
```

or by uncommenting line 26.

## Download

You can download Patpat @ <https://github.com/Slymeball/figura-avatars/blob/main/Rewrite/Patpat/Patpat.lua>.