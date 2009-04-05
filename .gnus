;; Red�finition de programmes � utiliser pour les urls
;; certains gestionnaires de ML ajoutent un champs mailto pour obtenir des infos
;; et gnus par d�faut utilise les r�glages de emacs soit netscape...
;; donc on red�finit le mailto pour l'attribuer � gnus.

;; Pour pouvoir browser les URL avec Opera
;; (custom-set-variables
;;  '(browse-url-browser-function (quote browse-url-generic) t)
;;  '(browse-url-generic-program "opera" t)
;;  (custom-set-faces))


(custom-set-variables
 '(browse-url-browser-function (quote browse-url-generic) t)
 '(browse-url-generic-program "firefox" t)
 (custom-set-faces))

;; **********************************
;; les VARIABLES � FIXER
;; **********************************
(setq eole-bbdb t)
(setq number-type 'euro)

;TOTO;(setq emacs-lisp-dir "~/.elisp/")

;; Votre nom
(setq user-full-name "Philippe FAURE")

;; l'adresse email � mettre dans le cas g�n�ral
;; on peut �galement utiliser les "posting-styles"
;; pour cela, allez voir vers la fin
(setq user-mail-address "faure_p@epita.fr")

;; je me fais une copie cach�e de tous les messages que j'envoie
;; ce qui me permet de garder une trace et de les trier dans les bonnes boites
;; changer le 'XXX' pour votre nom d'utilisateur local.
;; (setq message-default-mail-headers "Bcc: XXXXXXXXX\n")

(setq
 ;; le serveur de news � utiliser
 ;; remplacer 'localhost' par le nom de votre serveur de news si vous
 ;; n'�tes pas en local
 gnus-select-method '(nntp "news.epita.fr"))

;; ne mets pas dans le 'Cc:' les adresses matchant la regexp
;; quand on fait un "reply to all"
;; Changez le nom puis d�commenter
;;; (setq message-dont-reply-to-names "chuche")

;; le r�pertoire o� vous avez install� les diff�rents fichiers
;; sp�cifiques � gnus comme les filtres (filtre.gnus)...
;TOTO;(setq nbc-gnus-dir "~/.elisp/gnus/")

;(setq gnus-version "5.8")
;; pour ceux qui veulent cliquer sur des boutons plut�t que d'utiliser
;; les raccourcis clavier cette option rajoute une esp�ce de barre
;; d'outil sur laquelle on peut cliquer.
(setq gnus-carpal nil)

;; **********************************
;; Fin des VARIABLES � FIXER
;; **********************************

;; on teste la version de gnus et on sort en erreur si elle est trop ancienne
(if (string-match "5.5" gnus-version)
    (error "Ce fichier ne marche pas avec votre version de gnus"))



(load-library "smtpmail")

;; news server's address
(setq gnus-select-method '(nntp "news.epita.fr"))
;(setq gnus-select-method '(nnspool ""))
;(setq gnus-select-method '(nnmh ""))

;; defined domain
(setq gnusx1-local-domain "epita.fr")

;; user's name, don't forget to change it !
(setq user-full-name "Philippe FAURE")

;; user's e-mail address, don't forget to change it !
(setq user-mail-address "faure_p@epita.fr")

;(defvar my-signature-file "~/.sig/default.sig"
 ; "Default signature file")

;; **********************************
;; Param�tres par d�faut des en-t�tes
;; **********************************

;(setq
 ;; header par d�faut des news qui indique de ne pas m'envoyer de copie courrier
;;;  message-default-news-headers "Mail-Copies-To: never\n"
 ;; le champ organisation
;;;  message-user-organization "home sweet home"
; )


;; param�tres globaux
(setq
 ;; moins dangereux que gnus-expert mais bon...
 ;; pour l'occasion j'ai mis un param�tres plus conservateur.
 ;; Vous pourrez le changer quand vous serez plus grand ;-)
 gnus-novice-user t
 ;; sans commentaire, mais � manier avec pr�caution...
;;  gnus-expert-user t
 ;; pas de demande de confirmation pour quitter gnus
 gnus-interactive-exit nil
 ;; indique si la ligne de mode (la ligne noire en bas des buffers)
 ;; est coup�e ou non.
 ;; 'nil' indique qu'elle n'est pas coup�e
 ;; la valeur 40 permet, chez moi, de toujours voir les infos suppl�mentaires (buffer, lignes...)
 gnus-mode-non-string-length 40
 ;; pas de demande de confirmation pour sauver un article
 gnus-prompt-before-saving nil
 ;; limite la signature � 4 lignes
 gnus-signature-limit '(4.0 "^---*Forwarded article")
 )

(setq
 ;; v�rifie les nouveaux groupes � chaque d�marrage
 ;; si votre serveur est lent, vous avez int�r�t � mettre cette variable � 'nil'
 gnus-check-new-newsgroups t
 ;; Ne lit le active que pour les groupes abonn�s
 gnus-read-active-file 'some
 ;; ne sauve pas la liste des groupes tu�s
 gnus-save-killed-list nil
 ;; pas de newsrc,
 ;; donc PAS de compatibilit� avec d'autres lecteurs de news
 gnus-save-newsrc-file t
 ;; que faire des nouveaux groupes
 gnus-subscribe-newsgroup-method 'gnus-subscribe-hierarchically)

;; g�n�re le maximum de header � la cr�ation du message
;; plut�t qu'au moment de l'envoyer
;; si vous ne voyez pas � quoi �a sert, laisser donc le commentaire
;;; (setq message-generate-headers-first t)


;; *******************************************
;; retirer les mail
;; *******************************************

(setq
 ;; la methode � utiliser en second (les news �tant la premi�re)
 ;; si on ne d�finit pas enti�rement cette m�thode, on risque
 ;; de retrouver des mails dans nnml.archive ; ce qui peut, pour
 ;; quelqu'un de mauvaise foi, �tre consid�r� comme un bug
 ;; la fa�on de faire a changer en 5.8, mais je reste � celle-ci
 ;; pour la compatibilit� avec la 5.6.45
 gnus-secondary-select-methods '((nnml ""
				       ;; le r�pertoire par d�faut pour les mails
				       (nnml-directory "~/Mail/")
				       ;; le fichier active par d�faut pour les mails
				       (nnml-active-file "~/Mail/active")))

 ;; le nombre de jour de l'expire
 nnmail-expiry-wait 2
 ;; les groupes � faire expirer automatiquement
 ;; les autres mailboxes ne sont JAMAIS expir�es
 gnus-auto-expirable-newsgroups "mail.\\(root\\|delete\\)"
 ;; utilise les noms longs plut�t que les sous r�pertoires
 nnmail-use-long-file-names t
 ;; les mails marqu�s ne sont pas mis dans le cache
 ;; (ce n'est pas la peine puisque je n'expire pas les mails)
 gnus-uncacheable-groups "^nnml")

;; De base, gnus r�cup�re les mails dans le r�pertoire
;; d�finit par la variable $MAIL mais si vous �tes sous windows
;; ou que vous voulez r�cup�rer directement votre mail sur un
;; serveur POP , un truc comme ci-dessous devrait faire l'affaire.

;;;(setq mail-sources
;;;      (pop :server "votre.serveur.mail" :user "login" :password "mot_de_passe"))

;; Vous pouvez aussi d�clarer plusieurs boites comme ceci :
;;;(setq mail-sources
;;;      (pop :server "votre.serveur.mail" :user "login" :password "mot_de_passe")
;;;      (apop :server "votre.secondserveur.mail" :user "login2" :password "mot_de_passe2"))


;; ********************************************
;; le buffer de selection des groupes
;; ********************************************

;; Tri par les topics d�finis
;; pour mettre en place les topics, voir dans :
;; info gnus - The Group Buffer - Group Topics
(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

(setq
 ;; ne montre que le premier message de chaque thread quand on ouvre un groupe
 gnus-thread-hide-subtree t
 ;; n'affiche que dans un groupe les articles crosspost�s
 gnus-suppress-duplicates t
 ;; ne selectionne pas d'article au d�marrage
 gnus-auto-select-first nil)

(setq
 ;; le fichier de scoring utilis�
 gnus-home-score-file "all.SCORE"
 ;; la liste des groupes toujours visibles
 gnus-permanently-visible-groups "^nndoc"
 ;; � partir de combien d'articles demander la confirmation
 ;; d'ouverture d'un forum.

 ;; si vous n'utilisez pas un serveur local vous avez peut-�tre
 ;; int�r�t � baisser cette valeur.
 gnus-large-newsgroup 1000)

;; *******************************************
;; le buffer "summary" (affichage des threads...)
;; *******************************************

;; Tri et les groupes de news par :
;;      - score du thread
;;      - sujet
;; Tri les groupes de mails par ordre de
;;      - dates
;; ATTENTION, le tri �crit en dernier est le dernier effectu�
;; donc si vous voulez trier principalement par score puis pour des
;; scores �gaux par sujet, il faut d'abord mettre le tri par
;; sujet puis celui par score

;; (add-hook 'gnus-summary-mode-hook
;; 	  (lambda ()
;; 	    (if (or (gnus-news-group-p gnus-newsgroup-name)
;; 		    (string-match "^nnml:list" gnus-newsgroup-name))
;; 		(setq gnus-thread-sort-functions
;; 		      '(gnus-thread-sort-by-subject
;; 			gnus-thread-sort-by-total-score))
;; 	      (setq gnus-thread-sort-functions
;; 		    '(gnus-thread-sort-by-date)))))
(add-hook 'gnus-summary-mode-hook
	  (lambda ()
	    (if (or (gnus-news-group-p gnus-newsgroup-name)
		    (string-match "^nnml:list" gnus-newsgroup-name))
		(setq gnus-thread-sort-functions
		      '(gnus-thread-sort-by-date))
	      (setq gnus-thread-sort-functions
		    '(gnus-thread-sort-by-date)))))


;; A la demande de certaine, la description de chaque article inclue la date.
;; Comme dis dans la doc, il faut garder les param�tres %U, %R et %z le plus
;; � gauche possible de l'expression pour des raisons de rapidit�

;; Pour le groupe d'archivage des mes posts, je ne veux pas voir le posteur
;; (puisque c'est forc�ment moi) mais le newsgroup dans lequel cela a �t� post�.
;; D'o� le truc suivant.
;; Attention, si vous n'�tes pas en gnus 5.8.*, vous ne verrez rien

;; ATTENTION, si vous venez d'une version 5.6, il faudra refaire l'overview
;; des groupes pour que cela soit pris en compte. Pour �a, lancer la commande :
;; `nnml-generate-nov-databases'
;; depuis n'importe quel buffer

;; Fonction qui g�n�re la variable gnus-summary-line-format suivant ce que je veux
(defun nbc-gnus-summary-format ()
  "Change le format suivant le groupe utilis�. Utilisable uniquement sous gnus-5.8.*"
  (if (and (string-match "archive" gnus-newsgroup-name)
	   (string-match "5.8" gnus-version))
      (setq gnus-summary-line-format "%U%R%z%I %d %(%[%4L: %-20,20f%]%) %s\n")
    (setq gnus-summary-line-format "%U%R%z%I %d %(%[%4L: %-20,20n%]%) %s\n")))

;; l�, si on est en gnus 5.8 (...) on appelle la fonction d�finie supra.
;; (if (or (string-match "5.8" gnus-version) (string-match "5.11" gnus-version))
(if (string-match "5.8" gnus-version)
    (progn
      (setq
       ;; ajoute le newsgroup dans le .overview
       gnus-extra-headers '(Newsgroups)
       ;; appelle la bonne fonction
       nnmail-extra-headers gnus-extra-headers
       ;; affiche le newsgroup plut�t que l'adresse mail quand celle-ci matche
       ;; l'expression suivant
       ;; remplacez le XXXXXXXXX par votre nom
       gnus-ignored-from-addresses "Anthony PERARD")
      ;; j'appelle la fonction � chaque fois que je rentre dans un groupe
      (add-hook 'gnus-summary-mode-hook 'nbc-gnus-summary-format))
  ;; SINON, (gnus 5.6 par exemple) on fixe d�finitivement la variable
  (setq gnus-summary-line-format "%U%R%z%I %d %(%[%4L: %-20,20n%]%) %s\n"))

;; *****************************************************************************
;; *******************************************
;; l'affichage des articles
;; *******************************************

(setq
 ;; la liste des champs � afficher tout le temps
 nbc-gnus-visible-headers
 '("^From:\\|^Organization:\\|^To:\\|^Cc:\\|^Reply-To:\\|^Subject:\\|^Sender:"
   ;; ne montre le champ newsgroups que quand il y a un crosspost
   ;; cette ligne peut-�tre supprim� en mettant 'newsgroups' dans gnus-boring-... dans gnus-5.8
   "^Newsgroups:.+[,]+.*$"
   ;; pour ceux qui veulent voir avec quoi les gens postent
   "^X-Mailer:\\|^X-Newsreader:\\|^user-Agent\\|^X-Posting-Agent"
   "^Followup-To:\\|^Date:"
))

(defun nbc-add-approved ()
  "ajoute le champ approved dans la liste des headers
visibles uniquement pour fmbd cette fonction se sert de nbc-gnus-visible headers"
  (if (string-match "dinosaures" gnus-newsgroup-name)
      (setq gnus-visible-headers
	    (append nbc-gnus-visible-headers (list '"^Approved:\\|^Summary:")))
    (setq gnus-visible-headers nbc-gnus-visible-headers)))

(setq
 ;; la liste des headers � cacher s'ils sont vides
 ;; c'est la valeur par d�faut, mais j'aime bien le voir
 gnus-boring-article-headers '(empty followup-to reply-to))

;; cette partie active certaines fonctions � l'affichage des articles
;; gnus-article-display-hook ayant disparu, j'utilise � la place gnus-article-mode-hook.
(add-hook 'gnus-article-mode-hook
	;; on ajoute le champ approved grace � la fonction d�finit supra
      'nbc-add-approved)

;; pfff, pour faire plaisir � certaine, je suis pass� du setq au add-hook.
;; �a fait quand m�me moins propre vous trouvez pas ?
;; cf <news:m3n1o8qc9y.fsf@bandini.teaser.fr> et pr�c�dent

;; la coloration des articles
(add-hook 'gnus-article-display-hook 'gnus-article-highlight)
;; cache les cles PGP
(add-hook 'gnus-article-display-hook 'gnus-article-hide-pgp)
;; cache les headers ind�sirables
(add-hook 'gnus-article-display-hook 'gnus-article-hide-headers-if-wanted)
;; vire certains headers s'ils sont vides
(add-hook 'gnus-article-display-hook 'gnus-article-hide-boring-headers)
;; vire le QP
(add-hook 'gnus-article-display-hook 'gnus-article-de-quoted-unreadable)
;; vire les lignes blanches en t�te
(add-hook 'gnus-article-display-hook 'gnus-article-strip-leading-blank-lines)
;; vire les lignes blanches en queue
(add-hook 'gnus-article-display-hook 'gnus-article-remove-trailing-blank-lines)
;; vire les lignes blanches en doubles
(add-hook 'gnus-article-display-hook 'gnus-article-strip-multiple-blank-lines)
;; met en valeur les *machins* et autres _trucs_
(add-hook 'gnus-article-display-hook 'gnus-article-emphasize)

;; la liste des flags d�biles (et que je ne veux pas voir)
;; utilis�s par les mailings-listes
;; n'aura un effet que sous gnus 5.8. Vous voyez que vous devriez y passer.
(setq gnus-list-identifiers '("\\[CRR\\]" "{bb}" "\\[deadlands_fr\\]" "\\[DL\\]"))

;; *******************************************
;; la gestion du mime
;; *******************************************

;; ajoute le charset ISO-8859-1 si besoin est
;; (pratique en version 5.6 et inutile en 5.8)
(when (string-match "5.6.*" gnus-version)
  (add-hook 'message-header-hook 'gnus-inews-insert-mime-headers))

;; je red�finis ces variables parce que je REFUSE de voir mes mails
;; partir en qp.  Est-ce que c'est le plus propre. C'est une tr�s
;; bonne question. �a marche c'est tout.
(setq gnus-group-posting-charset-alist
      '(("^\\(no\\|fr\\|dk\\)\\.[^,]*\\(,[ \t\n]*\\(no\\|fr\\|dk\\)\\.[^,]*\\)*$"
	 iso-8859-1 (iso-8859-1))
	(message-this-is-mail nil t)
	(message-this-is-news nil t)))
(setq mm-body-charset-encoding-alist '((iso-2022-jp . 7bit)
				       (iso-2022-jp-2 .7bit)
				       (iso-8859-1 . 8bit)
				       ))


;; La suite de cette partie est sp�cifique � gnus 5.8.*
;; je vous ai d�j� dit qu'il �tait bien le nouveau gnus ?

;; les types mime � ignorer : directement pomp� dans la doc
(setq gnus-ignored-mime-types '("text/x-vcard"))

;; je ne VEUX pas voir les messages en html ni en richtext :
;; je pr�f�re la version texte brute si elle existe
(setq mm-discouraged-alternatives '("text/html" "text/richtext"))




;; *******************************************
;; les "posting-styles"
;; *******************************************
;; changing my identity depending the newsgroup
;(setq gnus-posting-styles
;        '(
; 	  (".*"
;  	   (name "Phil")
;  	   (address "faure_p@epita.fr")
;	   (X-Outplook "Please enhance you Outlook with : [ http://flash.to/oe-quotefix/ ]")
;	   )

;	  (message-this-is-mail
;	   (name "Phil")
;	   (address "faure_p@epita.fr")
;	   (organization "Secrete")
;	   (signature "Philippe Faure"))


;	  (message-this-is-news
;	   (name "Phil")
;	   (address "faure_p@epita.fr")

;; 	  (message-this-is-news
;; 	   (name "Eole")
;; 	   (address "eole@ipsa.fr")
;; 	   (organization "Megarezo")
;; 	   (face `(gnus-convert-png-to-face "~/x-faces/bush.png")))
;; 	   (face '(gnus-face-from-file "~/x-faces/bush.jpg")))

;	  ("nn.+:perso.*"
;	   (name "Phil")
;	   (address "faure_p@epita.fr")
;	   (signature "Faure Philippe"))

; 	  (".*perl.*"
; 	   (organization "Perl Delegation")
; 	   (signature "PHP suxx"))

; 	  (".*emacs.*"
; 	   (organization "GNU rox")
;	   )

;	  (".*delire.*"
;	   (name "Phil")
;	   (address "faure_p@epita.fr")
;	   (organization "Brouzouf 'n Co")

;	  (".*epita\\.delation.*"
;	   (name "delationator")
;	   (address "faure_p@epita.fr")
;	   (organization "Delationne toi et la delation t'aidera !"))
; 	  )
;	)

;;put hierachic display
(add-hook 'gnus-group-mode-hook 'gnus-topic-mode)


;; je red�finis ces variables parce que je REFUSE de voir mes mails
;; partir en qp.  Est-ce que c'est le plus propre. C'est une tr�s
;; bonne question. �a marche c'est tout.
(setq gnus-group-posting-charset-alist
      '(("^\\(no\\|fr\\|dk\\)\\.[^,]*\\(,[ \t\n]*\\(no\\|fr\\|dk\\)\\.[^,]*\\)*$"
	 iso-8859-1 (iso-8859-1))
	(message-this-is-mail nil t)
	(message-this-is-news nil t)))
(setq mm-body-charset-encoding-alist '((iso-2022-jp . 7bit)
				       (iso-2022-jp-2 .7bit)
				       (iso-8859-15 . 8bit)
				       (iso-8859-1 . 8bit)))


;; La suite de cette partie est sp�cifique � gnus 5.8.*
;; je vous ai d�j� dit qu'il �tait bien le nouveau gnus ?

;; les types mime � ignorer : directement pomp� dans la doc
(setq gnus-ignored-mime-types '("text/x-vcard"))

;; je ne VEUX pas voir les messages en html ni en richtext :
;; je pr�f�re la version texte brute si elle existe
(setq mm-discouraged-alternatives '("text/html" "text/richtext"))

(add-hook 'gnus-article-prepare-hook 'gnus-article-highlight-signature)

;;(setq gnus-thread-sort-functions 'gnus-thread-sort-by-score
;;      gnus-summary-thread-gathering-function 'gnus-gather-threads-by-references)

(add-hook 'message-sent-hook '(lambda ()
				(gnus-score-followup-thread 500)))


(setq gnus-default-adaptive-score-alist
  '((gnus-unread-mark)
    (gnus-ticked-mark (from 4))
    (gnus-dormant-mark (from 5))
    (gnus-del-mark (from -4) (subject -1))
    (gnus-read-mark (from 4) (subject 2))
    (gnus-expirable-mark (from -1) (subject -1))
    (gnus-killed-mark (from -1) (subject -3))
    (gnus-kill-file-mark)
    (gnus-ancient-mark)
    (gnus-low-score-mark)
    (gnus-catchup-mark (from -1) (subject -1))))



;;; This is simply GREAT ! EXCELLENT !! WONDERFULL !!! :-)

;; Archives are marked as read when I send a message.
(setq gnus-gcc-mark-as-read t)

;; automatic mail scan without manual effort.
;; emacs presses (g) for you ;-)
;; level-specified group scanner by using demon
(defun gnus-demon-scan-mail-or-news-and-update (level)
"Scan for new mail, updating the *Group* buffer."
  (let ((win (current-window-configuration)))
    (unwind-protect
        (save-window-excursion
          (save-excursion
            (when (gnus-alive-p)
              (save-excursion
                (set-buffer gnus-group-buffer)
                (gnus-group-get-new-news level)))))
      (set-window-configuration win))))
;;
;; level 2: only mail groups are scanned.
(defun gnus-demon-scan-mail-and-update ()
"Scan for new mail, updating the *Group* buffer."
  (gnus-demon-scan-mail-or-news-and-update 2))
(gnus-demon-add-handler 'gnus-demon-scan-mail-and-update 5 nil)

; level 3: mail and local news groups are scanned.
(defun gnus-demon-scan-news-and-update ()
"Scan for new mail, updating the *Group* buffer."
  (gnus-demon-scan-mail-or-news-and-update 3))
(gnus-demon-add-handler 'gnus-demon-scan-news-and-update 1 1)



;; *******************************************
;; cr�ation de l'archive des news envoy�es :
;; je veux garder une trace de tous les posts que j'envoie
;; *******************************************

(setq
 ;; Backend utilis�
 gnus-message-archive-method
 '(nnml "archive"
	;; pas d'expiration de l'archive (je veux garder ind�finiment ma prose)
	(nnml-inhibit-expiry t)
	;; le fichier active de l'archive
	(nnml-active-file "~/News/archive/active")
	;; le repertoire ou mettre les archives
	(nnml-directory "~/News/archive/"))
 ;; n'archiver que les news (les mails sont archiv�s diff�rement)
 ;; et dans un seul groupe nomm� "news"
 gnus-message-archive-group
 '((if (message-news-p)
       "news")))



;; *******************************************
;; l'affichage des buffers
;; *******************************************

;; s�pare la fen�tre emacs en deux buffer. Le message d'origine est
;; affich� en haut et la r�ponse en bas quand on r�pond sans citer
;; (touche r)
(gnus-add-configuration
 '(reply
   (vertical 1.0
	     (article 0.5)
	     (message 1.0 point))))

;; NOUVEAU

;; on change la configuration du buffer sommaire pour conserver
;; l'affichage des groupes sur la gauche et l'affichage du sommaire
;; � droite
(gnus-add-configuration
 '(summary
   (horizontal 1.0
	       (vertical 0.3 (group 1.0))
	       (vertical 1.0 (summary 1.0 point)))))

;; on change la configuration du buffer article pour conserver
;; l'affichage des groupes sur la gauche, l'affichage du sommaire en
;; haut � droite et l'affichage des messages en bas � droite

;; (gnus-add-configuration
;;  '(article
;;    (horizontal 1.0
;; 	       (vertical 50 (group 1.0))
;; 	       (vertical 1.0
;; 			 (summary 0.16 point)
;; 			 (article 1.0)))))

;; Vous voulez une pr�sentation � la MacSoup avec le Zolie arbre ?
;; Et bien essayez remplacer le paragraphe pr�c�dent par �a :
;; (setq gnus-use-trees t
;;       gnus-generate-tree-function 'gnus-generate-horizontal-tree
;;       gnus-tree-minimize-window nil)

(gnus-add-configuration
 '(article
   (horizontal 1.0
	       (vertical 0.3
			 ("*BBDB*" 0.15)
			 (group 1.0))
	       (vertical 1.0
			 (summary 0.15)
			 (article 1.0)))))

;;Agencement des fen�tres, � partir de go�ts personnel et d'un 19''
;; (gnus-add-configuration
;;  '(article
;;    (horizontal 1.0
;;   	       (vertical 0.33
;;   			 (tree 0.15)
;;   			 (group 1.0))
;;   	       (vertical 1.0
;;   			 (summary 0.15)
;;   			 (vertical 1.0
;; 				   (article 0.85)
;; 				   ("*BBDB*" 1.0))))))


;; a expliquer
(add-hook 'display-time-hook
	  (lambda () (setq gnus-mode-non-string-length
			   (+ 21
			      (if line-number-mode 5 0)
			      (if column-number-mode 4 0)
			      (length display-time-string)))))

;; colorier le buffer de r�ponse utilis� le hook
;; gnus-message-setup-hook n'est document� que dans gnus-msg.el
;; comme quoi, il faut lire les sources parfois
(add-hook 'gnus-message-setup-hook 'font-lock-fontify-buffer)

;; *******************************************
;; la gestion des couleurs des buffers
;; *******************************************

;; cette partie n'est pas propre dans la mesure o�, entre autre elle
;; ne prend pas en compte le fond d'�cran utilis� mais bon...  D'autre
;; part, les commentaires datent d'un autre age donc les couleurs ne
;; correspondent pas avec

;; les groupes mails non vides
;(set-face-foreground 'gnus-group-mail-3-face "firebrick4")
;; les groupes mails vides
;(set-face-foreground 'gnus-group-mail-3-empty-face "firebrick3")

;; les groupes de news :
;; non vides
;(set-face-foreground 'gnus-group-news-3-face "NavajoWhite3")
;; vides
;(set-face-foreground 'gnus-group-news-3-empty-face "salmon1")

;; les anciens messages
;(set-face-foreground 'gnus-summary-normal-ancient-face "grey61")

;; les messages lus (scor�s et non scor�s)
;(set-face-foreground 'gnus-summary-normal-read-face "mediumpurple3")
;(set-face-foreground 'gnus-summary-high-read-face "darkochid4")
;(set-face-foreground 'gnus-summary-low-read-face "purple4")

;; les messages scor�s
;(set-face-foreground 'gnus-summary-high-unread-face "firebrick4")

;; les messages marqu�s
;(set-face-foreground 'gnus-summary-normal-ticked-face "green4")
;(set-face-foreground 'gnus-summary-high-ticked-face "green4")

;; *******************************************
;; l'envoi d'articles
;; *******************************************

;; coupe les lignes � 72 caract�res par d�faut dans la composition des messages
;; pour changer : C-u 72 C-xf
(add-hook 'message-mode-hook 'turn-on-auto-fill)
(add-hook 'message-mode-hook 'iso-accents-mode)
(add-hook 'message-mode-hook 'footnote-mode)
;;(add-hook 'message-mode-hook 'flyspell-mode)


;; Highlight summary-mode
(add-hook 'gnus-summary-mode-hook 'my-setup-hl-line)
(add-hook 'gnus-group-mode-hook 'my-setup-hl-line)

(defun my-setup-hl-line ()
  (hl-line-mode 1)
  (setq cursor-type nil) ; Comment this out, if you want the cursor to
                         ; stay visible.
  )

;; Auto-activateGroup mode
(add-hook 'gnus-article-mode-hook 'auto-fill-mode)


(setq
 ;; coupe la signature des messages cit�s
 message-cite-function 'message-cite-original-without-signature
 ;; d�finition des s�parateurs de signatures
 ;; directement r�cup�r�e de la doc de gnus
 gnus-signature-separator '(
			    "^-- $"         ; The standard
			    "^--$"	    ; Loosers who don't know RFCs
			    "^-- *$"        ; A common mangling
			    "^-------*$"    ; Many people just use a looong line of dashes.  Shame!
			    "^ *--------*$" ; Double-shame!
			    "^________*$"   ; Underscores are also popular
			    "^MORTREUX.*$"  ; one relou
			    "^========*$"))



;; *******************************************
;; quelques fonctions diverses et bien pratiques
;; *******************************************


;; permet de d�velopper, respectivement r�duire les threads en appuyant
;; sur la touche "fl�che gauche", respectivement "fl�che droite"
;; Sur une id�e de Ingo Ruhnke <grumbel@gmx.de>
(defun my-gnus-summary-show-thread ()
  "Show thread without changing cursor positon."
  (interactive)
  (gnus-summary-show-thread)
  (beginning-of-line)
  (forward-char 1))
(define-key gnus-summary-mode-map [(right)] 'my-gnus-summary-show-thread)
(define-key gnus-summary-mode-map [(left)]  'gnus-summary-hide-thread)



;; Cette partie demande � l'utilisateur s'il veut vraiment
;; r�pondre � l'auteur quand il est dans un groupe de news
;; (trouv� sur gnu.emacs.gnus. Que l'auteur en soit mille fois
;; remerci�...)
(defadvice gnus-summary-reply (around reply-in-news activate)
  (interactive)
  (when (or (not (gnus-news-group-p gnus-newsgroup-name))
            (y-or-n-p "Vraiment repondre a l'auteur ? "))
    ad-do-it))
;; *******************************************
;; Les archives de messages int�ressants
;;
;; L'archivage d'un message se fait de deux fa�ons simples :
;;   - en s�lectionnant le message et en appuyant sur 'o'
;;   - en marquant (touche '#') plusieurs messages et en appuyant sur 'o'
;;
;; gnus propose alors les groupes possibles. Choisissez le bon et validez.
;;
;; Pour voir ces groupes dans le buffer "Group",
;; par le menu : faites "Groups/foreign groups/make a doc group"
;; ou bien "G f" et entrez le nom du groupe d�sir�
;; *******************************************

(setq
 ;; demande la confirmation du nom de groupe � utiliser pour les articles
 gnus-prompt-before-saving t
 ;; sauvegarde les articles au format rmail par d�faut
 gnus-default-article-saver  'gnus-summary-save-in-rmail
 ;; propose le groupe ou sauvegard� comme je le veux
 gnus-split-methods
 ;; les messages venant de *linux* ou *unix* ou *bsd* dans unix-stuff
      '(("^Newsgroups:.*\\(unix\\|linux\\|bsd\\)"                       "unix-stuff")
	("^Newsgroups:.*\\(tex\\|xml\\)"                                 "xml-stuff")
        ;; les messages de *perl* dans perl-stuff...
        ("^Newsgroups:.*perl"                                           "perl-stuff")
        ("^Newsgroups:.*jdr"                                             "jdr-stuff")
	;; les messages contenants *emacs* ou *gnus dans emacs-stuff
	("^Newsgroups:.*emacs\\|^Newsgroups:.*gnus"                     "emacs-stuff")))

;;------------------;;
;; MAIL PREFERENCES ;;
;;------------------;;

;; Mails parameters
(setq mail-default-reply-to "perard_a@epita.fr"
      mail-default-from "Anthony PERARD"

      gnus-secondary-select-methods '((nnml ""))
					    ;; le r�pertoire par d�faut pour les mails
;;					    (nnml-directory "~/Mail/")
;;					    ;; le fichier active par d�faut pour les mails
;;					    (nnml-active-file "~/Mail/active")))


      ;; Mails filter
      nnmail-split-methods
      '(
	("mail.megarezo"		"^Subject:.*megarezo.*")
	("epitech.soiree.conf"		"^Subject:.*\\[?confnight\\]?.*")
	("bde.forward"			"^To:.*bde@epita\\.fr.*")
	("epitech.delegue"		"^To:.*delegue.*\\(ept4\\|epth_d|\\ept4_d.*\\)")
	("epitech.intra"		"^From:.*from_intra_noreply")
	("perso.epitech_power"		"^Subject:.*\\({EPITECH\.}\\|\\[potes\\]\\).*")
	("perso.famille"		"^From:.*\\([Pp]ierre\\|[Pp]apa\\|[Aa]nnie\\|[Mm]aman\\|[Aa]urelia\\|[Cc]houpi\\)")
	("perso.toutencartron"		"^From:.*\\(cartro_n\\|cartron\\).*")
	("perso.guitou"			"^From:.*\\(guitou\\|thibau_g\\).*")
	("perso.slamslam"		"^From:.*\\(sam\\|legros_s\\).*")
	("perso.sly"			"^From:.*\\(ruel_s\\|sly\\).*")
	("perso.winni"			"^From:.*\\(windar\\|bardet_h\\).*")
	("projs.intra"			"^From:.*intra@epitech\.net.*")
	("mail.episkopat"		"^Subject:.*episkopat.*")
	("mail.julien@maison"		"^From:.*julien@avarre.com.*")
	("mail.moi-qui-me-chie"		"^From:.*\\(avarre_j\\|eole\\)@epita.fr")
	("mail.sys-adm"			"sys.*adm.*<sadm@epita.fr>.*")
	("ML.kataproof"			"^\\(Subject:.*\\[Kataproof\\].*\\|\\(From\\|To\\|Cc\\):.*kataproof@epitech42\\.net\\)")
	("ML.epx"			"^\\(To:.*epx@epita.fr\\|Subject:.*\\[\\(linuxecoles\\|epx\\)\\]\\).*")
	("ML.Activ"			"^To:.*activ@*.\..*")
	("mail.misc"			""))

      ;; le nombre de jour de l'expire
      nnmail-expiry-wait 2
      ;; les groupes � faire expirer automatiquement
      ;; les autres mailboxes ne sont JAMAIS expir�es
      gnus-auto-expirable-newsgroups
      "mail.\\(megarezo\\|bde\\|bde_epitatek\\|moi-qui-me-chie\\|delegue\\)"

;; Way send mails
      smtpmail-local-domain		"epita.fr"
      send-mail-function		'smtpmail-send-it
      message-send-mail-function	'smtpmail-send-it)


      ;; Pour ne pas se r�pondre � sois m�me.
;;      message-dont-reply-to-names
;;      "\\(eole\\|avarre_j\\)@\\(ipsa\\|epita\\|epitech\\|)\.\\(net\\|fr\\)"
;;      bbdb-user-mail-names         message-dont-reply-to-names
;;    gnus-ignored-from-addresses  message-dont-reply-to-names


;; Std variables
(custom-set-variables
 '(mail-yank-prefix "> ")
 '(smtpmail-smtp-server "smtp.epita.fr")
 '(rmail-enable-mime t)
 '(mail-signature t)
 '(smtpmail-default-smtp-server "smtp.epita.fr")
 '(smtpmail-smtp-service 25)
 '(display-time-24hr-format t))


;; RMAIL's backup dir
(setq rmail-file-name "~/Mail/RMAIL")

;; --------------------------------- ;;
;; ARCHIVE SENT MAIL AND SENT  NEWS  ;;
;; --------------------------------- ;;

;; This generates fake groups where your sent mail (classed by month)
;; and news are stored.

(setq gnus-message-archive-group
      '((if (message-news-p)
	      "sent-news"
	  (concat "sent-mail-" (format-time-string
				  "%Y-%m" (current-time))))))

(setq gnus-message-archive-method
      '(nnfolder "archive"
		    (nnfolder-inhibit-expiry t)
		       (nnfolder-active-file "~/Mail/sent-mail/active")
		          (nnfolder-directory "~/Mail/sent-mail/")
			     (nnfolder-get-new-mail nil)))

(setq gnus-message-archive-group
      '((if (message-news-p)
	      "sent-news"
	  (concat "sent-mail-" (format-time-string
				  "%Y-%m" (current-time))))))
;; ---------------------- ;;
;; Implementation Of BBDD ;;
;; ---------------------- ;;

;;TONY: This section don't run with my session.

;; ;;; Which a data-base very usefull for gnus.
;; ;;; Don't wait and get it at http://bbdb.sourceforge.net/
;; (when eole-bbdb
;;   (require 'bbdb)
;;   (bbdb-initialize 'gnus 'sendmail)
;;   ;; (bbdb-initialize 'gnus 'message 'sendmail)
;;   (add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)

;;  (bbdb-insinuate-message)

;;   ;; on d�finit o� se trouve le fichier de bbdb
;;   (setq bbdb-file (concat emacs-lisp-dir "gnus/bbdb"))

;;   (add-hook 'message-setup-hook 'bbdb-define-all-aliases)
;;   (add-hook 'mail-mode-hook 'bbdb-insinuate-message)
;;   (add-hook 'message-mode-hook 'bbdb-insinuate-message)
;;   (add-hook 'mail-setup-hook 'bbdb-insinuate-sendmail)
;;   (add-hook 'mail-setup-hook 'bbdb-define-all-aliases)
;;   (add-hook 'gnus-startup-hook 'bbdb-insinuate-gnus)


;;   (setq
;;    bbdb-offer-save 'yes
;;    bbdb-electric-p t
;;    bbdb-pop-up-target-lines 5
;;    bbdb-use-pop-up t
;;    ;; pour pas que bbdb teste la validite du numero...
;;    ;; par rapport au format americain...
;;    bbdb-north-american-phone-numbers-p nil)

;;   ;; M-TAB permet d'avoir la compl�tion des adresses � partir du d�but d'un nom.
;;   (add-hook 'message-mode-hook
;; 	    (lambda () (local-set-key [(meta tab)] 'bbdb-complete-name)))

;; ;; To force bbdb to cite the name *and* address of people when
;; ;; completing address.
;; ;; Expl : Matthieu Moy <matthieu.moy@imag.fr>
;; (setq bbdb-dwim-net-address-allow-redundancy t)

;; (defadvice bbdb-complete-name
;;   (after bbdb-complete-name-default-domain activate)
;;   (let* ((completed ad-return-value))
;;     (if (null completed)
;; 	(expand-abbrev))))


;; ;;; end of BBDB configuration
;; )

;;--------------;;
;; MAIL ALIASES ;;
;;--------------;;

;; handle for make your mail aliases becoming abbrevs
(add-hook 'mail-mode-hook 'mail-abbrevs-setup)
(add-hook
 'mail-mode-hook
 (lambda ()
   (substitute-key-definition 'next-line 'mail-abbrev-next-line
			      mail-mode-map global-map)
   (substitute-key-definition 'end-of-buffer 'mail-abbrev-end-of-buffer
			      mail-mode-map global-map)))
