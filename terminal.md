# Terminal

## Terminal fonts

- Glass TTY VT220
- VT323
- IBM VGA 8x16 / 9x16
- Fixedsys Excelsior
- IBM Plex Mono
- White Rabbit
- Terminus

## Color Schemes

(simulating old cathode-ray tube monitors).

- Green on black
- Amber on black

Old terminals were green or amber on black because of phosphor screens, human vision, and hardware limits

Old terminals used Cathode-ray tube

How it worked:

- electron beam hits screen
- screen coated with phosphor
- phosphor glows

The color you see = type of phosphor

Green phosphor (P1) was used because:

✅ Very efficient
	•	bright with low energy
	•	easier to read

✅ High contrast
	•	green on black = very sharp

✅ Good for eyes
	•	human eye is most sensitive to green

Amber phosphor came later:

✅ Less eye strain
	•	softer than green
	•	warmer tone

✅ Better for long sessions
	•	especially for text-heavy work

Why NOT white?

Early CRT limitations:
	•	white phosphor was:
	•	less sharp
	•	more flicker
	•	more eye fatigue

👉 monochrome colors were actually better

## Neovim as markdown editor

- Copy text to system clipboard: press 3 keys one by one: "+y


## Midnight Commander

- Configure file assosiations the same as in finder
- `/Users/Philipp.Philippov/.config/mc`
- Delete eveything
- Add the following:

```
[Default]
Open=(open %f &)
```

## Launch neovim from midnight commander on Mac OS

- Launch Automator app
- Create a new app - Run Shell Script

```
for f in "$@"; do
  osascript -e "
  tell application \"iTerm2\"
    activate
    tell current window
      create tab with default profile command \"/opt/homebrew/bin/nvim \\\"$f\\\"\"
    end tell
  end tell"
done
```

- Save it as a new application
- Assosiate this new app with .md files
- When you press enter on .md file in mc, file will be opened `in a new tab` in iTerm in Neovim
