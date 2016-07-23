2 constant: LED    
512 constant: buffer-size
buffer-size buffer: line-buffer
0 init-variable: irc-con

6000 constant: IRC_ECLOSED

: connect ( -- )
    6667 str: "irc.freenode.net" netcon-connect irc-con ! ;

: send ( str -- )
    irc-con @ swap netcon-writeln ;
    
: register ( -- )
    str: "NICK hodor179" send
    str: "USER hodor179 hodor179 bla :hodor179" send ;
    
: join ( -- ) str: "JOIN #somechan" send ;
: greet ( -- ) str: "PRIVMSG #somechan :Hooodoor!" send ;
: quit ( -- ) str: "QUIT :hodor" send ;
    
: readln ( -- str )
    irc-con @ buffer-size line-buffer netcon-readln -1 = if
        IRC_ECLOSED throw
    then    
    line-buffer ;
        
: processline ( str -- )
    dup type cr
    dup str: "PING" str-starts? if
        str: "PONG" send
        random 200 % 0= if
            greet
        then
    then
    dup str: "PRIVMSG" str-in? if
        LED blink
    then 
    drop ;

0 task: ircbot-task

: run ( -- )    
    connect 
    register 
    join
    begin
        readln processline        
    again ;

: bot-start ( -- )
    multi
    ircbot-task activate
    begin    
        println: "Starting IRC bot"
        ['] run catch dup 0<> if            
            print: 'Exception in irc bot: ' . cr
        else
            drop
        then
        irc-con @ 0<> if
            irc-con @ netcon-dispose
            0 irc-con !
        then        
        5000 delay
    again
    deactivate ;
