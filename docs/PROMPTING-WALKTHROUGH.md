# How This Batch File Was Built: A Prompting Walkthrough

This is an edited walkthrough of a real session. The prompts are tidied and the replies are condensed. It isn't a word-for-word transcript. It's here to show how plain, direct prompts guide Claude to a simple batch file that works.

The tool: `Clean and Straighten Scans.bat`. It cleans, un-tilts, and crops PNG scans using ImageMagick.

## The pattern in one paragraph

Describe the job in plain words. Ask Claude to state its understanding. Fix what it got wrong. Give it real sample files. Answer its open questions. Say "go" only when you're ready. Then refine with short, exact instructions. Test on real data, because that's where the bugs show up.

## Round 1: Describe the job, then ask for understanding

**Prompt**

> I want a batch file that accepts a path to a folder, a file, a folder dropped on it, or a file dropped on it. Each .png will be "cleaned" and "un-tilted." Cleaning means near-white areas become white. It also means stray dots become white. The files are computer scans of documents. Residue on the scanner glass, adhesives, and paper dust cause dirt in the scan. We also want to find a near-horizontal line, then rotate the image by that small amount so what should be horizontal is nearly horizontal. When we're done, crop the image very closely to the real extents and save a .png with "-clean" appended to the filename. Please state your understanding.

**What Claude did.** It restated the job in its own words, listed what it would need to decide, and wrote no code.

**Why it worked.**

- The prompt says what the job is and why. The reason (dirty scanner glass) tells Claude what counts as "dirt."
- The last sentence, "Please state your understanding," stops Claude from running ahead. A wrong assumption costs one message to fix. In finished code it costs a rewrite.

## Round 2: Correct the misunderstandings

Claude asked about tools, output location, and thresholds. The reply was short and exact.

**Prompt**

> Do not add extra functions.
>
> A page edge cannot be used to determine tilt. Those are physical cropping. We are cropping to preserve image content.
>
> I prefer ImageMagick. It is in the system path. Output goes alongside each source image. Add a number if a "-clean" file already exists.
>
> Thresholds: you have a "raw" and a "clean" version of the same scan. The "clean" version was NOT un-tilted.
>
> Crop margin: a few pixels of white on all four sides.

**Why it worked.**

- "Do not add extra functions" keeps the file simple. Say it early.
- The page-edge correction is a rule Claude couldn't have known. A wrong assumption about the physical process gets fixed in one sentence.
- Naming the tool (ImageMagick) removes a whole branch of options.
- Handing over a raw file and a hand-cleaned file lets Claude measure what "clean" means. You don't have to guess numbers.

## Round 3: Real files beat descriptions

Claude opened the zip and found the first "raw" file was damaged. The PNG header was missing. It said so and asked for a new copy. It didn't guess.

With a good pair, it measured the difference. A pixel whose darkest color channel was 230 or higher had been made white. Nothing below about 225 had been touched. Small pale yellow specks were still in the clean copy, so Claude wrote down that they needed a separate rule.

**Prompt**

> Use these two images. It is also common for pale yellow "dots" to be created from dirty scanner glass.

**Why it worked.** Numbers came from your own data, not from Claude's habits. When a file is bad, Claude says so. Check what it reports.

## Round 4: Close the open questions

**Prompt**

> Let's make the folder processing simple. If a "-clean" variant exists, skip the source file. No recursion. The drop takes ONLY a file, multiple files, or a folder.

Claude then asked one more question: should files already ending in `-clean` be ignored? The answer was one word.

> YES

**Why it worked.** Every question Claude asks now is a rule you won't have to debug later. Short answers are fine. Claude repeated the full rule list back before writing anything.

## Round 5: Authorize the code explicitly

Claude didn't write code after "I like option A" or after answering questions. It waited for a clear directive.

**Prompt**

> go write code

**Why it worked.** The line between discussing and building is sharp. You decide when it's crossed. Claude also prototyped the image steps first on your real scans and compared the result to your reference before building the batch file.

## Round 6: Refine with short, exact instructions

Each change was one instruction.

> ImageMagick is in "C:\Portable\- Linked\Graphics\ImageMagick\Q16 x64". Make the path a variable set near the beginning of the file. The file should also have header comments about who made it, what it does, the need for ImageMagick, etc.

> Comments should state ImageMagick's home page is http://www.imagemagick.org/ . Batch structure should be similar to this: *(pasted an existing batch file)*

> Remove the comments: " & REM Rule #135 deviatio..." and ensure there are no trailing spaces on any line. There MUST be a closing line with one space.

**Why it worked.**

- Pasting a finished file of yours as the model is the fastest way to get your house style. Claude copied the header block, the section names, the drag-and-drop banner, and the prompt loop.
- Exact, checkable rules (no trailing spaces, a closing line with one space) are easy for Claude to follow and easy for you to verify.
- One change per instruction means you can see what changed.

## Round 7: Test on real data

The first version passed on the sample scan. A second scan, a color cover with solid teal ribbons, came back with white flecks all through the ribbons.

**Prompt**

> This image was corrupted by the routine. We wiped out fine text and color details inside the graphics.

Claude didn't guess. It reran the steps on that scan, found the cause, and fixed it.

- **Cause.** The speck rule decided what was "content" by gray level. The teal sat right at the cutoff, so gaps inside the teal looked like specks.
- **Fix.** Only pale pixels can be removed as specks now. Teal, dark text, and other solid colors are never candidates.
- **Check.** It compared the old and new results side by side. The ribbons stayed solid, the pale blue highlights and text stayed intact, and the dust dots were still removed.

**Why it worked.** A cleaner built from one sample scan can fail on the next. Test on a different kind of page before you trust it. Describe what's wrong in plain words ("wiped out color details") and attach the files.

## What to copy from this

1. **Ask for understanding first.** "Please state your understanding."
2. **Say what you don't want.** "Do not add extra functions."
3. **Correct wrong assumptions in one sentence.** Claude can't know your physical setup.
4. **Name your tool.** "ImageMagick, it's in my PATH."
5. **Give a before and an after.** Raw file plus hand-cleaned file gives measurable targets.
6. **Answer every open question.** Short answers are fine.
7. **Authorize code on purpose.** "Go, write code."
8. **Paste a model file for style.** Your own finished script teaches structure better than a description.
9. **Make rules checkable.** No trailing spaces. One closing line with one space.
10. **Test on a different input than you built on.** Report failures in plain words and attach the file.

## A starting prompt you can reuse

> I want a Windows batch file that [does one specific job] to [what kind of files]. It takes [a file / several files / a folder] dropped on it or passed as an argument. Here's why: [the real-world problem]. It uses [tool] at [path]. Output goes [where] named [pattern]. Skip anything that [rule]. Do not add extra functions. I'm attaching [an example before and after]. Please state your understanding, list what you still need to ask me, and don't write code yet.

## Notes on honesty

Claude can't run a Windows batch file from its own workspace. It tested the image steps with the same ImageMagick commands on a Linux copy, and it checked the batch file for parsing mistakes. The first real run of the .bat on Windows is yours. Do that run on two or three different scans and report what you see.
