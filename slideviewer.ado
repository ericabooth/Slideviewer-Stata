*! version 2.0.2  09nov2026  Eric A. Booth <eric.a.booth@gmail.com>
*! slideviewer.ado - manage and navigate SMCL slides in the Stata Viewer
** Version 2.0.2 : Nov 2026 - slide names keep their case (matched to the file on disk
**                 without regard to case), so next/prev work after opening a mixed-case
**                 slide by name and TOC links work on case-sensitive file systems;
**                 backslashes in subdir() are normalized; standard version line
** Version 2.0.1 : Nov 2026 - quoted subdir() kept as a path (was reset to ./ignore);
**                 a missing subdir() now errors instead of falling back; leading ~
**                 expanded from HOME/USERPROFILE; navbar copies slide text verbatim
**                 (macval), so local and global macro references and odd quotes survive
** Version 2.0   : May 2026
** Version 1.1 : Feb 2012
** Version 1.0 : Jan 2012

program define slideviewer, rclass
    version 16
    syntax [anything], [Subdir(string) Navbar Post Clear]

    *-- Handle Clear
    if "`clear'" != "" {
        global S_slideviewer_subdir ""
        global S_slideviewer_current ""
        exit
    }

    *-- Handle Subdirectory Persistence
    if `"`macval(subdir)'"' != "" {
        * Expand a leading ~ ourselves (Stata file commands do not)
        _sv_expand_home `"`macval(subdir)'"'
        loc subdir `"`r(path)'"'
        * Clean up path (ensure no trailing slashes for consistency)
        loc subdir : subinstr local subdir "\" "/", all
        loc subdir : subinstr local subdir "//" "/", all
        if substr(`"`subdir'"', -1, 1) == "/" & ustrlen(`"`subdir'"') > 1 {
            loc subdir = substr(`"`subdir'"', 1, length(`"`subdir'"')-1)
        }
        mata: st_local("svok", strofreal(direxists(st_local("subdir"))))
        if "`svok'" != "1" {
            di as err `"subdir(): directory `subdir' not found"'
            exit 601
        }
        global S_slideviewer_subdir `"`subdir'"'
        * A new deck starts fresh
        global S_slideviewer_current ""
    }

    if `"$S_slideviewer_subdir"' == "" {
        * Default to "ignore" folder in PWD if nothing specified
        global S_slideviewer_subdir `"`c(pwd)'/ignore"'
    }
    mata: st_local("svok", strofreal(direxists(st_global("S_slideviewer_subdir"))))
    if "`svok'" != "1" {
        di as err `"directory $S_slideviewer_subdir not found; specify subdir()"'
        exit 601
    }

    *-- Get File List
    loc files : dir "$S_slideviewer_subdir" files "*.smcl"
    loc files : list sort files
    loc nfiles : word count `files'

    if `nfiles' == 0 {
        di as err `"No .smcl files found in $S_slideviewer_subdir"'
        exit 601
    }

    *-- Parse Input / Keyword Logic
    loc target ""
    * lower() is used only to recognize keywords; a slide name keeps its case
    loc raw = trim(`"`anything'"')
    if lower(substr(`"`raw'"', -5, .)) == ".smcl" {
        loc raw = substr(`"`raw'"', 1, length(`"`raw'"') - 5)
    }
    loc cmd = lower(`"`raw'"')

    if inlist("`cmd'", "next", "prev", "first", "last", "toc") {
        
        * Find current index
        loc current_idx = 0
        if "$S_slideviewer_current" != "" {
            loc i = 1
            foreach f in `files' {
                if lower("`f'") == lower("$S_slideviewer_current") {
                    loc current_idx = `i'
                    continue, break
                }
                loc ++i
            }
        }

        if "`cmd'" == "first" {
            loc target : word 1 of `files'
        }
        else if "`cmd'" == "last" {
            loc target : word `nfiles' of `files'
        }
        else if "`cmd'" == "next" {
            loc next_idx = `current_idx' + 1
            if `next_idx' > `nfiles' loc next_idx = 1
            loc target : word `next_idx' of `files'
        }
        else if "`cmd'" == "prev" {
            loc prev_idx = `current_idx' - 1
            if `prev_idx' < 1 loc prev_idx = `nfiles'
            loc target : word `prev_idx' of `files'
        }
        else if "`cmd'" == "toc" {
            _sv_gen_toc `"`files'"' "`navbar'"
            exit
        }
    }
    else {
        * Treat as filename
        if "`cmd'" == "" {
            * If nothing specified, show current or first
            if "$S_slideviewer_current" != "" loc target "$S_slideviewer_current"
            else loc target : word 1 of `files'
        }
        else {
            * Resolve the name against the files on disk without regard to case,
            * and remember the on-disk spelling
            loc target "`raw'.smcl"
            foreach f in `files' {
                if lower("`f'") == lower("`raw'.smcl") {
                    loc target "`f'"
                    continue, break
                }
            }
        }
    }

    *-- Validate Target
    cap confirm file `"$S_slideviewer_subdir/`target'"'
    if _rc {
        di as err `"File `target' not found in $S_slideviewer_subdir"'
        exit 601
    }

    *-- Update State
    global S_slideviewer_current "`target'"

    *-- View File
    if "`navbar'" != "" {
        _sv_view_with_navbar `"$S_slideviewer_subdir/`target'"' "`navbar'"
    }
    else {
        view `"$S_slideviewer_subdir/`target'"'
    }

    *-- Post results
    if "`post'" != "" {
        return local lastslide "$S_slideviewer_current"
        return local totalscore "${totalscore}"
    }

end

*-- Helper: Generate TOC
program define _sv_gen_toc
    args files navbar_opt
    
    if "`navbar_opt'" != "" loc navopt ", navbar"
    
    tempfile tocfile
    tempname fh
    file open `fh' using "`tocfile'", write text
    
    file write `fh' "{smcl}" _n
    file write `fh' "{title:Table of Contents}" _n
    file write `fh' "{hline}" _n _n
    
    foreach f in `files' {
        loc fname : subinstr local f ".smcl" "", all
        file write `fh' `"{p 4 8 2}{stata "slideviewer `fname'`navopt'":`fname'}{p_end}"' _n
    }
    
    file write `fh' _n "{hline}" _n
    file write `fh' `"{p 4 8 2}{stata "slideviewer first`navopt'":[Back to Start]}{p_end}"' _n
    
    file close `fh'
    view "`tocfile'"
end

*-- Helper: View with Navigation Bar
program define _sv_view_with_navbar
    args sourcefile navbar_opt
    
    tempfile viewfile
    tempname fh_in fh_out
    
    file open `fh_out' using "`viewfile'", write text
    
    * Header
    file write `fh_out' "{smcl}" _n
    file write `fh_out' "{center:{stata slideviewer first, navbar:[First]}  {stata slideviewer prev, navbar:[Prev]}  {stata slideviewer toc, navbar:[TOC]}  {stata slideviewer next, navbar:[Next]}  {stata slideviewer last, navbar:[Last]}}" _n
    file write `fh_out' "{hline}" _n
    
    * Content
    file open `fh_in' using `"`sourcefile'"', read text
    file read `fh_in' line
    while r(eof) == 0 {
        * Skip {smcl} tag in source to avoid nested tags if possible, though Stata handles it okay
        * macval() keeps macro references and unbalanced quotes in slide text verbatim
        if trim(lower(`"`macval(line)'"')) != "{smcl}" {
            file write `fh_out' `"`macval(line)'"' _n
        }
        file read `fh_in' line
    }
    file close `fh_in'
    
    * Footer
    file write `fh_out' "{hline}" _n
    file write `fh_out' "{center:{stata slideviewer first, navbar:[First]}  {stata slideviewer prev, navbar:[Prev]}  {stata slideviewer toc, navbar:[TOC]}  {stata slideviewer next, navbar:[Next]}  {stata slideviewer last, navbar:[Last]}}" _n
    
    file close `fh_out'
    view "`viewfile'"
end

*-- Helper: expand a leading ~ from HOME (or USERPROFILE / HOMEDRIVE+HOMEPATH on Windows)
program define _sv_expand_home, rclass
    args path
    if substr(`"`macval(path)'"', 1, 1) == "~" & inlist(substr(`"`macval(path)'"', 2, 1), "", "/", "\") {
        loc home : env HOME
        if "`c(os)'" == "Windows" {
            loc up : env USERPROFILE
            loc hd : env HOMEDRIVE
            loc hp : env HOMEPATH
            if `"`up'"' != "" loc home `"`up'"'
            else if `"`hd'`hp'"' != "" loc home `"`hd'`hp'"'
        }
        if `"`home'"' == "" {
            di as err "cannot expand ~: HOME is not set"
            exit 601
        }
        loc rest = substr(`"`macval(path)'"', 2, .)
        loc path `"`home'`macval(rest)'"'
    }
    return local path `"`macval(path)'"'
end
