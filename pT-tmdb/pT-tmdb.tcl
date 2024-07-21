#################################################################
#                                                               #
# TMDB Info by Petabyte                                          #
#                                                               #
# Description:                                                   #
#   Retrieves information from TMDB based on a release name.     #
#   Requires a TMDB API key for fetching data.                   #
#                                                               #
# Usage:                                                        #
#   - Command: !tmdb releasename                                 #
#     Example: !tmdb Spirit.Rangers.S03E19.1080p.WEB.h264-DOLORES#
#                                                               #
# Installation:                                                 #
#   1. Place this script in your bot's script directory.         #
#   2. Ensure your bot's TCL interpreter can execute the script.#
#   3. Obtain a TMDB API key from https://www.themoviedb.org    #
#   4. Update TMDB.sh with your API key if necessary.            #
#   5. Adjust 'botdir' variable to match your bot's script dir.  #
#                                                               #
# Adding More Features:                                         #
#   - Modify this script to handle additional commands or        #
#     functionalities related to TMDB queries.                   #
#   - Extend TMDB.sh or create new scripts for different queries.#
#                                                               #
# Changelog:                                                    #
#   Version 1.5 (YYYY-MM-DD):                                    #
#   - Directly announce full output from TMDB.sh.                #
#                                                               #
#################################################################

bind pub - !tmdb pub:tmdb
bind pub - !tmdbinfo pub:tmdb

proc pub:tmdb {nick output binary chan text} {
    global botdir
    set botdir "/glftpd/bin"  ;# Adjust thrre bot's directory if needed
    set binary "$botdir/pT-TMDB.sh"
    
    if {[llength $text] != 1} {
        putquick "PRIVMSG $chan :Usage: !tmdb releasename Example -> !tmdb Spirit.Rangers.S03E19.1080p.WEB.h264-DOLORES"
        return
    }
    
    set release_name [lindex $text 0]
    set cmd "$binary $release_name"

    # Use open with a command pipeline for non-blocking I/O
    set pipe [open "|$cmd" "r"]

    fileevent $pipe readable [list handle_tmdb_output $pipe $chan]
}

proc handle_tmdb_output {pipe chan} {
    if {[eof $pipe]} {
        close $pipe
        return
    }
    set line [gets $pipe]
    if {$line ne ""} {
        putquick "PRIVMSG $chan : TMDB-INFO -> $line"
    }
}
