import ranger.api
import subprocess
from ranger.api.commands import *

class fasd(Command):
    """:fasd

    Uses fasd to set the current directory.
    """

    def execute(self):
        directory = subprocess.check_output(["fasd", "-dl1", self.arg(1)])
        directory = directory.decode("utf-8", "ignore")
        directory = directory.rstrip('\n')
        self.fm.execute_console("cd " + directory)
