(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (and custom-file
           (file-exists-p custom-file))
  (load custom-file nil :nomessage))

(load "~/crafted-emacs/modules/crafted-init-config")

;; Add package definitions for completion packages
;; to `package-selected-packages'.
(require 'crafted-completion-packages)
(require 'crafted-ide-packages)
(require 'crafted-lisp-packages)
(require 'crafted-org-packages)
(require 'crafted-ui-packages)
(require 'crafted-workspaces-packages)
(require 'crafted-writing-packages)

;; Manually select "ef-themes" package
(add-to-list 'package-selected-packages 'ef-themes)

;; Install the packages listed in the `package-selected-packages' list.
(package-install-selected-packages :noconfirm)

;; Load configuration for the completion module
(require 'crafted-completion-config)
(require 'crafted-defaults-config)
(require 'crafted-ide-config)
(require 'crafted-lisp-config)
(require 'crafted-org-config)
(require 'crafted-package-config)
(require 'crafted-startup-config)
(require 'crafted-ui-config)
(require 'crafted-workspaces-config)
(require 'crafted-writing-config)
