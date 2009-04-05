;;;

;;;### (autoloads (netsoul-quit netsoul) "netsoul" "netsoul.el" (17774
;;;;;;  12935))
;;; Generated autoloads from netsoul.el

(defconst netsoul-version "0.6.2")

(defconst netsoul-version-name "SoLong")

(defalias (quote netsoul-start) (quote netsoul))

(autoload (quote netsoul) "netsoul" "\
Launch Emacs Netsoul, setting user's location to LOCATION." t nil)

(autoload (quote netsoul-quit) "netsoul" "\
End Netsoul process." t nil)

;;;***

;;;### (autoloads (netsoul-customize netsoul-write-contacts netsoul-load-configuration
;;;;;;  netsoul-port netsoul-host netsoul-user-data netsoul-pass
;;;;;;  netsoul-login netsoul-location) "netsoul-configuration" "netsoul-configuration.el"
;;;;;;  (17700 63884))
;;; Generated autoloads from netsoul-configuration.el

(defvar netsoul-location (system-name) "\
Location of the user.")

(defvar netsoul-login nil "\
User's login.")

(defvar netsoul-pass nil "\
User's password (use nil to be asked password on connect).")

(defvar netsoul-user-data (concat "Using Emacs-" emacs-version " (" system-configuration ")") "\
User's informations.")

(defvar netsoul-host "ns-server.epita.fr" "\
Netsoul server.")

(defvar netsoul-port 4242 "\
Netsoul server port.")

(autoload (quote netsoul-load-configuration) "netsoul-configuration" "\
Netsoul configuration loading, using LOCATION as the user's location." nil nil)

(autoload (quote netsoul-write-contacts) "netsoul-configuration" "\
Write the contacts file." nil nil)

(autoload (quote netsoul-customize) "netsoul-configuration" "\
Customization of the `netsoul' group." t nil)

;;;***

;;;### (autoloads (netsoul-connect netsoul-send-server netsoul-events-buffer)
;;;;;;  "netsoul-connection" "netsoul-connection.el" (17744 65478))
;;; Generated autoloads from netsoul-connection.el

(defvar netsoul-process nil "\
Netsoul connection.")

(defvar netsoul-connection-state nil "\
Connection state, could be nil, 'connecting, 'connected or 'authentified.")

(defvar netsoul-delta 0 "\
Time difference between local time and server one.")

(defvar netsoul-ping-timer nil "\
Ping timer.")

(autoload (quote netsoul-events-buffer) "netsoul-connection" "\
Return the Netsoul Events buffer, if it exists." nil nil)

(autoload (quote netsoul-send-server) "netsoul-connection" "\
Send STR to the netsoul server.
If WITH-PREFIX is set, add the command prefix to STR." nil nil)

(autoload (quote netsoul-connect) "netsoul-connection" "\
External/internal connection to the netsoul server." nil nil)

;;;***

;;;### (autoloads (netsoul-who-result netsoul-get-contact-property
;;;;;;  netsoul-update-contact-list netsoul-login-to-connections
;;;;;;  netsoul-login-to-nick netsoul-watch-log netsoul-who-list
;;;;;;  netsoul-update-contacts netsoul-add-contacts netsoul-contacts-buffer)
;;;;;;  "netsoul-contact" "netsoul-contact.el" (17763 19757))
;;; Generated autoloads from netsoul-contact.el

(defvar netsoul-contacts-hash nil "\
Hash table used for contacts storing.")

(defvar netsoul-login-pattern "^\\([a-z-]+_[a-zA-Z0-9_-]\\{,25\\}\\|[a-z0-9-]\\{,25\\}\\)$" "\
Pattern for valid logins.")

(autoload (quote netsoul-contacts-buffer) "netsoul-contact" "\
Return the Netsoul Contact buffer, if it exists." nil nil)

(autoload (quote netsoul-add-contacts) "netsoul-contact" "\
Add new contacts to the netsoul contact list." t nil)

(autoload (quote netsoul-update-contacts) "netsoul-contact" "\
Check the state of every contact." nil nil)

(autoload (quote netsoul-who-list) "netsoul-contact" "\
Send a who request of the user LIST formated as {login_x,login_y,...}." nil nil)

(autoload (quote netsoul-watch-log) "netsoul-contact" "\
Send a watch_log command to netsoul-server for all contacts." nil nil)

(autoload (quote netsoul-login-to-nick) "netsoul-contact" "\
Return the nickname associated with LOGIN or nil." nil nil)

(autoload (quote netsoul-login-to-connections) "netsoul-contact" "\
Return the connection list associated with LOGIN." nil nil)

(autoload (quote netsoul-update-contact-list) "netsoul-contact" "\
Update the contact list buffer." nil nil)

(autoload (quote netsoul-get-contact-property) "netsoul-contact" "\
Get the property PROPERTY on the contact under the point." nil nil)

(autoload (quote netsoul-who-result) "netsoul-contact" "\
Parse STRING as a who message.
If the group is `exam', the state of the user will not be considered." nil nil)

;;;***

;;;### (autoloads (netsoul-see-chat netsoul-warn-chats netsoul-next-chat-buffer
;;;;;;  netsoul-show netsoul-chat-height netsoul-chat-width) "netsoul-ergonomic"
;;;;;;  "netsoul-ergonomic.el" (17774 13643))
;;; Generated autoloads from netsoul-ergonomic.el

(defvar netsoul-chat-width 66 "\
Width of the chat window, in percent of full screen.")

(defvar netsoul-chat-height 83 "\
Height of the chat window, in percent of full height.")

(autoload (quote netsoul-show) "netsoul-ergonomic" "\
Show/Hide netsoul's interface." t nil)

(autoload (quote netsoul-next-chat-buffer) "netsoul-ergonomic" "\
Return the next chat buffer in the uid order.
If NOT-SAME is set, create a buffer when there's only one chat buffer." t nil)

(autoload (quote netsoul-warn-chats) "netsoul-ergonomic" "\
Say that chats are closed." nil nil)

(autoload (quote netsoul-see-chat) "netsoul-ergonomic" "\
User switched to buffer BUFFER, so she had read the message." nil nil)

;;;***

;;;### (autoloads (with-selected-window netsoul-puthash-after netsoul-current-chat-window
;;;;;;  netsoul-id-to-buffer netsoul-send-to-buffer-id netsoul-get-time
;;;;;;  insert-in-buffer fill-simple netsoul-event-message url-decode
;;;;;;  url-encode call-if-exists) "netsoul-generic" "netsoul-generic.el"
;;;;;;  (17755 23846))
;;; Generated autoloads from netsoul-generic.el

(autoload (quote call-if-exists) "netsoul-generic" "\
Call FUNC if its car is an existing function." nil (quote macro))

(autoload (quote url-encode) "netsoul-generic" "\
URL-Encode STRING." nil nil)

(autoload (quote url-decode) "netsoul-generic" "\
URL-Decode STRING." nil nil)

(autoload (quote netsoul-event-message) "netsoul-generic" "\
Print TEXT to the netsoul-events buffer." nil nil)

(autoload (quote fill-simple) "netsoul-generic" "\
Fill adding \\n's every AT chars, trying to not break words." t nil)

(autoload (quote insert-in-buffer) "netsoul-generic" "\
Insert TEXT in BUFFER.
CLEAR-BEFORE means clear the buffer before inserting text.
WFACE is a face that will be set for text from WFROM of len WLEN." nil nil)

(autoload (quote netsoul-get-time) "netsoul-generic" "\
Get time with delta." nil nil)

(autoload (quote netsoul-send-to-buffer-id) "netsoul-generic" "\
Insert in chat buffer which `netsoul-user-id' is ID a MESSAGE.
If DESTROY is t, set the buffer to a disconnected state." nil nil)

(autoload (quote netsoul-id-to-buffer) "netsoul-generic" "\
Get the active buffer corresponding to ID." nil nil)

(autoload (quote netsoul-current-chat-window) "netsoul-generic" "\
Get the current chat window." nil nil)

(autoload (quote netsoul-puthash-after) "netsoul-generic" "\
Insert after PREV-KEY the pair (NEW-KEY, NEW-DATA) in HASH.
HASH is a symbol.
If PREV-KEY is nil the pair is inserted at the beginning.
If PREV-KEY is not found in HASH, the pair is inserted
at the end of the hash table." nil nil)

(autoload (quote with-selected-window) "netsoul-generic" "\
Taken from `subr' in case of not defined (Emacs ~< 21.3).
See the original doc for WINDOW and BODY." nil (quote macro))

;;;***

;;;### (autoloads (netsoul-log-message) "netsoul-log" "netsoul-log.el"
;;;;;;  (17701 15833))
;;; Generated autoloads from netsoul-log.el

(autoload (quote netsoul-log-message) "netsoul-log" "\
Save (LOGIN,NICKNAME)'s MESSAGE in a log file.
See `netsoul-log' and `netsoul-log-path' for more customization." nil nil)

;;;***

;;;### (autoloads (netsoul-receive-mail) "netsoul-mail" "netsoul-mail.el"
;;;;;;  (17676 9505))
;;; Generated autoloads from netsoul-mail.el

(autoload (quote netsoul-receive-mail) "netsoul-mail" "\
A mail from FROM titled SUBJECT has been received." nil nil)

;;;***

;;;### (autoloads (netsoul-away-timer netsoul-contact-state netsoul-contact-connected
;;;;;;  netsoul-contact-disconnected netsoul-set-state netsoul-away-message)
;;;;;;  "netsoul-state" "netsoul-state.el" (17745 32))
;;; Generated autoloads from netsoul-state.el

(defvar netsoul-away-message "Auto: I'm away. Use Emacs' Netsoul, that's the future" "\
Auto away message. nil for nothing.")

(defvar netsoul-away-timer nil "\
Timer used to away the user.")

(defvar netsoul-state nil "\
Current state.")

(autoload (quote netsoul-set-state) "netsoul-state" "\
Change your state to STATE." t nil)

(autoload (quote netsoul-contact-disconnected) "netsoul-state" "\
A contact (ID LOGIN) has disconnected." nil nil)

(autoload (quote netsoul-contact-connected) "netsoul-state" "\
A contact (ID LOGIN) has connected." nil nil)

(autoload (quote netsoul-contact-state) "netsoul-state" "\
A contact (ID LOGIN GROUP) changed his state to STATE since TIME.
This change is not taken into account if GROUP is `exam'." nil nil)

(autoload (quote netsoul-away-timer) "netsoul-state" "\
Set the away timer." nil nil)

;;;***

;;;### (autoloads (netsoul-send-typing netsoul-send-message netsoul-commit-message
;;;;;;  netsoul-textbox-buffer) "netsoul-textbox" "netsoul-textbox.el"
;;;;;;  (17755 25341))
;;; Generated autoloads from netsoul-textbox.el

(autoload (quote netsoul-textbox-buffer) "netsoul-textbox" "\
Return the Netsoul Textbox buffer, if it exists." nil nil)

(autoload (quote netsoul-commit-message) "netsoul-textbox" "\
Commit to ID a MESSAGE, writting the message in CHAT-BUFFER." nil nil)

(autoload (quote netsoul-send-message) "netsoul-textbox" "\
Send to ID a MESSAGE.
If ID is a string, use it as a login.  Otherwise, use it as an NS-ID." t nil)

(autoload (quote netsoul-send-typing) "netsoul-textbox" "\
Send the typing message to the current chat buffer.
If START is t, send a start, a stop otherwise." nil nil)

;;;***

;;;### (autoloads (netsoul-receive-typing netsoul-message-insert-in-buffer
;;;;;;  netsoul-receive-message netsoul-unignore-contact netsoul-ignore-contact
;;;;;;  netsoul-chat-create-buffer netsoul-current-chat-buffer netsoul-chat-mode
;;;;;;  netsoul-cut-method netsoul-self-name netsoul-smiley netsoul-ignore-logins)
;;;;;;  "netsoul-chat" "netsoul-chat.el" (17755 25607))
;;; Generated autoloads from netsoul-chat.el

(defvar netsoul-ignore-logins nil "\
List of logins to ignore messages from.
The messages are still logged.")

(defvar netsoul-smiley t "\
Display smileys.")

(defvar netsoul-self-name "You" "\
Your name, will be written as <name> your text.")

(defvar netsoul-cut-method (quote fill) "\
Method to cut the text in a chat buffer.
'fill means use `fill' like method, so break at words (default),
'cut means cut at point, so break at chars (Emacs default for buffers).")

(defvar netsoul-user-id nil "\
Netsoul user id of the destination.")

(defvar netsoul-user-connected nil "\
Set to t if the destination is connected.")

(defvar netsoul-user-login nil "\
Current netsoul login of the destination.")

(defvar netsoul-unread nil "\
Read/unread flag for the last messages received.")

(defvar netsoul-away-sent nil "\
Sent/not sent flag for the away message.")

(autoload (quote netsoul-chat-mode) "netsoul-chat" "\
Mode for netsoul chat buffers." t nil)

(autoload (quote netsoul-current-chat-buffer) "netsoul-chat" "\
Return the current chat buffer." nil nil)

(autoload (quote netsoul-chat-create-buffer) "netsoul-chat" "\
Create a chat buffer for ID LOGIN HOST.
It inserts a photo if we are in graphic mode." nil nil)

(autoload (quote netsoul-ignore-contact) "netsoul-chat" "\
Add LOGIN to the ignore list." t nil)

(autoload (quote netsoul-unignore-contact) "netsoul-chat" "\
Remove LOGIN from the ignore list." t nil)

(autoload (quote netsoul-receive-message) "netsoul-chat" "\
The user ID LOGIN HOST from group GROUP has send MESSAGE." nil nil)

(autoload (quote netsoul-message-insert-in-buffer) "netsoul-chat" "\
Insert in CHAT-BUFFER NICKNAME's MESSAGE.
The sender is colored with FACE." nil nil)

(autoload (quote netsoul-receive-typing) "netsoul-chat" "\
ID LOGIN HOST has sent a typing event.
TYPING is either `start' or `stop'." nil nil)

;;;***
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; netsoul-loaddefs.el ends here
