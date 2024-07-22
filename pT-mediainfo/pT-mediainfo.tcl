bind pub - !mediainfo pub:mediainfo
bind pub - !mi pub:mediainfo

proc pub:mediainfo {nick output binary chan text} {
    global botdir
    set botdir "/glftpd/bin"  ;# Adjust the bot's directory if needed
    set binary "/glftpd/bin/mediainfo.sh"
    
    if {[llength $text] != 2} {
        putquick "PRIVMSG $chan :Usage: !mediainfo SECTION releasename : Example -> !mediainfo MOVIES-X264 Big.Sky.River.2022.1080p.WEB.H264-SKYFiRE"
        return
    }
    
    # Run the media info command asynchronously
    set section [lindex $text 0]
    set release [lindex $text 1]
    set cmd "$binary $section $release"

    # Use open with a command pipeline for non-blocking I/O
    set pipe [open "|$cmd" "r"]

    fileevent $pipe readable [list handle_mediainfo_output $pipe $chan $section $release]
}

proc handle_mediainfo_output {pipe chan section release} {
    if {[eof $pipe]} {
        close $pipe
        return
    }
    set line [gets $pipe]
    if {$line ne ""} {
        # Check if the section is APPS, GAMES-PC, GAMES-NSW, or PS5
        if {[string equal $section "APPS"] || \
            [string equal $section "GAMES-PC"] || \
            [string equal $section "GAMES-NSW"] || \
            [string equal $section "PS5"]} {
            return  ;# Skip announcing for these sections
        }
        
        if {[string match "Skipped .m2ts file: *" $line]} {
            putquick "PRIVMSG $chan :\x02SKIPPED\x02 - [string range $line 19 end]"
        } else {
            putquick "PRIVMSG $chan $line"  ;# Change color or formatting as needed
        }
    }
}

# Infinite loop to read the log file every 10+ milliseconds
proc check_log {} {
    global last_checked_log
    set log_file "/glftpd/ftp-data/logs/mediainfo.log"

    # Read the log file only if modified after the last check
    set current_mtime [file mtime $log_file]
    if {$current_mtime > $last_checked_log} {
        set last_checked_log $current_mtime
        set log_content [exec tail -n 1 $log_file]
        
        # Example condition to announce changes in the log
        # Adjust this based on your needs and format
        if {[string match {*VIDEO-INFO*} $log_content]} {
            # Announce to a specific channel
            putquick "PRIVMSG $channel :$log_content"
        }
    }
    
    # Check again after 10 milliseconds
    after 10 check_log
}

# Initialize the last checked time for the log file
set last_checked_log [clock seconds]
after 10 check_log  ;# Start checking after 10 milliseconds
