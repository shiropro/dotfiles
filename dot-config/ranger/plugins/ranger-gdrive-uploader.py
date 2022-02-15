import ranger.api
import subprocess
from ranger.api.commands import *
# https://github.com/ilsenatorov/useful-scripts
# Allows you to upload files to Google Drive from the ranger file browser.
# Uses the gdrive package, can be issued with :gdrive: command or by binding it
# to a key. Should be added to commands.py file in the ranger config file.

class gdrive(Command):
    """
    Uploads the selected files to google drive via gdrive
    """
    def execute(self):
        file = self.fm.thisfile
        self.fm.run("gdrive upload \"{0}\" {1}".format(file.basename, self.rest(1)))
        self.fm.notify('Done!')
