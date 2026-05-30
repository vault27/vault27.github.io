# Terminal

## Editor requirements

- Markdown outline support as a side bar
- Markdown highlight
- Themes
- Transparent
- Markdown TOC generation
- Mouse support
- Clipboard support
- Terminal based

## Terminal requirements

- Transparency
- Themes
- Tabs
- Background control - image, color, gradient
- Fonts control
- Font color control

## Terminal fonts

- Glass TTY VT220
- VT323
- IBM VGA 8x16 / 9x16
- Fixedsys Excelsior
- IBM Plex Mono
- White Rabbit
- Terminus
- Fira Code
- Manifold Extended CF - from Severance
- Input Sans - from Severance
- Source Code Pro 
- JetBrains Mono
- IBM Plex Mono

Fallout

- Gothic 821 Condensed
- JH Fallout - dialogs
- Futura - inventory
- Brush Script - logo of Pip boy
- Gill Sans Extra Condensed Bold - perk names
- Microgramma - Skill index
- Univers 59 Condensed - Fallout Logo
- OCR-A 

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

## Color in Severance

- White
- Light blue - #4CB4E7
- Blue - #235BA8
- White and blue on light blue background
- White and light blue on blue background

## Color in Fallout

- Pip-Boy Green: #00ff00
- Wasteland Brown: #8b4513
- Steel Grey: #808080
- Nuka Cola Red: #ff0000
- Rad-X Yellow: #ffff00
- Mutant Purple: #800080 
- Classic Pip-Boy Green (Text & Lines): #1BFF80 
- Classic Amber/Gold (Highlights & Toggle): #FFB641 or #FFE242
- Alternate Pip-Boy Blue: #2ECFFF
- Vault Blue: #003399 or #325886
- Vault Yellow / Gold: #FFFF00 or #FEF265
- Base Red (Idle Button): #A52A2A or #9C1010

## Neovim as markdown editor

- Copy text to system clipboard: press 3 keys one by one: "+y


## Midnight Commander

- Configure file assosiations the same as in finder
- But open md files in neovim
- `/Users/User/.config/mc/mc.ext.ini`
- Delete eveything
- Add the following:

```
[mc.ext.ini]
Version=4.0

[markdown]
Regex=\\.(md|markdown)$
Open=nvim %f

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
