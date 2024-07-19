# Command handler for !gtop
bind pub -|- !gtop bot:pretop
bind pub -|- !prestats bot:pretop

proc bot:pretop {nick uhost hand chan text} {
    global botnick

    # Remove the command part (!pretop) from the text
    set cmd_length [string length "!gtop"]
    set release [string trimleft $text [expr {$cmd_length + 1}]]

    # Path to pretop.sh script
    set script_path "/glftpd/bin/pretop.sh"

    # Send initial response to the channel
    putnow "PRIVMSG $chan :Fetching Top for AFFiLS, Please wait..."

    # Schedule the execution of the pretop script asynchronously
    after 0 [list bot:run_pretop_script $chan $script_path $release]
}

proc bot:run_pretop_script {chan script_path release} {
    global botnick

    # Execute the pretop script with the entire release name as argument
    set script_output [exec /bin/bash $script_path {*}[split $release]]

    # Send the output to the channel
    foreach line [split $script_output "\n"] {
        putnow "PRIVMSG $chan :$line"
    }
}
