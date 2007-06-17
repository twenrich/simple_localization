# = Shortcut module
# 
# This module makes the contens of the ArkanisDevelopment::SimpleLocalization
# module accessable in a module named <code>Localization</code>. This saves
# some typing work.
# 
# If the <code>Language</code> module conflicts with another one just don't
# load it by excluding it from the feature list:
# 
#   simple_localization :de, :except => :shortcut_module
# 
# or
# 
#   simple_localization :de, :shortcut_module => false
# 
# 
# == Used sections of the language file
# 
# This feature does not use sections from the lanuage file.
# 

module Localization
  include ArkanisDevelopment::SimpleLocalization
end