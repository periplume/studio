# studio

studio was conceived as a digital writer's environment, or a 
digital typewriter, or a modern-day digital word-processing 
appliance.

It is merely a bunch of shell commands stitching together a 
semblance of a reliably comfortable and familiar writer's studio, 
a digital room of one's own.

It is something of a proof of concept.

It is the result of scratching my own itch.

It is the product of much thought and many false starts.

It is idisyncratic at best, or worst.

The problem this project aspires to solve is this: make the tool
for writing as simple and powerful as possible without burdening
the writer with the problems technology (ie powerful tools)
introduce.  In other words, provide power without complexity.
Questions like, what should I call this thing (that I am writing),
how should I keep it private, how shall I protect it from loss,
how can I revert to yesterday's work, what have I changed on this
piece, how does this version differ from one I printed a week ago.
The analog world offers the model of simplicity in a labor
intensive form; the power tools of today offer the means to solve
problems the analog world often used human labor to solve.  Studio
attempts to merge these two ideal worlds together, highlighting
the good and hiding the bad of each.  The goal is to make it easy
to sit down and write while the tools work to solve the messy
problems in the background.  And to put an exclamation point on
the goal, the product must be mine, owned by me, manged by me,
protected by me, in other words, the data stays local.

I believe that the tool one uses to produce something has a
profound influence on the product itself.  I believe that the
simplicity of the typewriter, just as the simplicity of the pen
and paper, has influence on the writer and therefore the written
work.  I believe technology, or more broadly, that the
environment, holds sway over the works created within.  Simply
put, the tool plays a vital role in the work they are used to
create by virtue of the tool's function, design, and use.

Writing deals with one medium, words, represented as text encoded
with the alphabet.  Most digital tools today force non-essential
abstractions into the literal view of the writer.  The fact of a
blank sheet of paper is missing, for better or worse.  For me, for
my needs, the paper must begin blank.

Thus the distraction-free environment is one of the principle
design goals.  But the visual distractions are easy to remove.
What has proven more difficult is to remove the rest of the
distractions one, as a user of digital tools, must consider.  What
to call things, where to put them, how to organize them, how to
protect them from prying eyes, how to protect them from loss and
corruption, how to maintain a history of what has been written,
and many other tasks either a secretary, a file cabinet, file
folders, scissors and glue, a research assistant, a copy editor,
an organized mind, a printer, or in reality, all of the above
provide.

This tool is meant to mitigate these problems and leave a writer,
alone in his room, without need to worry about these needful
questions.

Writing is an intellectually demanding activity, at its best. It
requires concentration, discipline, and routine.  The routine of
sitting down in the same place, being able to pick up right where
one left off last, and to do this without the clerical needs
anyone who uses computers knows computers require.  Computing
today is embarrasingly not well suited to the creative mind.

General requirements include:

- data redundancy
- local media only
- open formats
- complexity automated
- safe and secure
- easy and foolproof
- maintainable
- portable
- robust
- pleasure to use
- simple choices
- no abstractions
- appliance-like feeling
- composable

The various components in use include
- ubuntu linux (the operating environment)
- bash (the glue, or duct tape and bailing wire)
- git (the storage mechanism)
- fzf (searching and naming feedback)
- pgp (privacy)
- rsync (backup and restore)
- tig (git inspection tool)
- vipe (special editing situations)

# Installation

Use git to clone this repo into the location of your choosing.  
Then run the installer script to copy the bash script files into 
place:

```
# studio.install
```

The installer has a few options which `studio.install -h` 
explains.

The installer will report on broader dependencies but will proceed 
without those external commands which the studio suite requires.
