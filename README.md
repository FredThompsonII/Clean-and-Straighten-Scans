# Clean and Straighten Scans

A Windows batch file that cleans, un-tilts, and closely crops PNG scans of documents. It uses ImageMagick for all image work.

Scanner glass residue, adhesive, and paper dust leave dirt in a scan. Placing the paper on the glass leaves it slightly tilted. This file fixes both, then crops the result to the real content.

## What it does to each PNG

1. Near-white pixels become pure white.
2. Small stray specks become white. This includes the pale yellow dots left by dirty scanner glass. Only pale pixels are removed as specks, so dark and colored content is never touched, including solid color fills in graphics.
3. The tilt is measured from the dominant near-horizontal lines in the image, then corrected by rotating. Page edges are not used. The corners exposed by the rotation are filled with white.
4. The image is cropped closely to its content, with a few pixels of white border on all four sides.

The result is saved beside the source as `name-clean.png`. The source is never changed.

## Requirements

- Windows 10 or later.
- ImageMagick 7. A portable Q16 x64 build works. Home page: http://www.imagemagick.org/
- Nothing else. No elevation is needed.

Edit `IM_DIR` in the Data section near the top of the file so it points to the folder that holds `magick.exe`.

## Usage

Drop `.png` files and/or folders onto `Clean and Straighten Scans.bat`. Or run it with no argument and type a path at the prompt. The window stays open for repeated input until you enter `Q`, `EXIT` or `QUIT`.

A folder means the `.png` files directly inside it. Subfolders are not searched.

## Rules

- A source is skipped when its `name-clean.png` already exists, so a re-run only fills gaps.
- Files whose names already end in `-clean` are ignored.
- Each result is built in the temp folder and moved beside its source only on success.
- Nothing the script writes replaces an existing file.

## Settings

All settings are in the Data section at the top of the file.

| Setting | Default | Meaning |
| --- | --- | --- |
| `IM_DIR` | `C:\Portable\- Linked\Graphics\ImageMagick\Q16 x64` | Folder that holds `magick.exe` |
| `LIGHT_PCT` | 90 | A pixel whose darkest channel is at least this percent of 255 counts as near-white. 90 is 230 |
| `PALE_PCT` | 67 | Pixels whose darkest channel is below this percent of 255 are content and are never removed as specks. 67 is 171 |
| `PROTECT_RADIUS` | 3 | Pale pixels within this many pixels of content are protected from speck removal |
| `SPECK_RADIUS` | 4 | Light specks narrower than twice this radius, plus one, are made white |
| `DESKEW_PCT` | 40 | Share of the image the tilt search looks at, in percent |
| `MARGIN` | 8 | White border left around the cropped result, in pixels |

## Line endings

The batch file must keep CRLF line endings. The included `.gitattributes` enforces that.

## How it was built

See [docs/PROMPTING-WALKTHROUGH.md](docs/PROMPTING-WALKTHROUGH.md) for an edited walkthrough of the prompts that produced this file.

## License

MIT. See `LICENSE`.
