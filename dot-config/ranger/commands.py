# -*- coding: utf-8 -*-
# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

from __future__ import (absolute_import, division, print_function)

# You can import any python module as needed.
import os

# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command

# Any class that is a subclass of "Command" will be integrated into ranger as a
# command.  Try typing ":my_edit<ENTER>" in ranger!


class my_edit(Command):
    # The so-called doc-string of the class will be visible in the built-in
    # help that is accessible by typing "?c" inside ranger.
    """:my_edit <filename>

    A sample command for demonstration purposes that opens a file in an editor.
    """

    # The execute method is called when you run this command in ranger.
    def execute(self):
        # self.arg(1) is the first (space-separated) argument to the function.
        # This way you can write ":my_edit somefilename<ENTER>".
        if self.arg(1):
            # self.rest(1) contains self.arg(1) and everything that follows
            target_filename = self.rest(1)
        else:
            # self.fm is a ranger.core.filemanager.FileManager object and gives
            # you access to internals of ranger.
            # self.fm.thisfile is a ranger.container.file.File object and is a
            # reference to the currently selected file.
            target_filename = self.fm.thisfile.path

        # This is a generic function to print text in ranger.
        self.fm.notify("Let's edit the file " + target_filename + "!")

        # Using bad=True in fm.notify allows you to print error messages:
        if not os.path.exists(target_filename):
            self.fm.notify("The given file does not exist!", bad=True)
            return

        # This executes a function from ranger.core.acitons, a module with a
        # variety of subroutines that can help you construct commands.
        # Check out the source, or run "pydoc ranger.core.actions" for a list.
        self.fm.edit_file(target_filename)

    # The tab method is called when you press tab, and should return a list of
    # suggestions that the user will tab through.
    # tabnum is 1 for <TAB> and -1 for <S-TAB> by default
    def tab(self, tabnum):
        # This is a generic tab-completion function that iterates through the
        # content of the current directory.
        return self._tab_directory_content()


class emptytrash(Command):
    """:emptytrash

    清空垃圾箱 ~/.Trash 和 ~/.local/share/Trash 的命令
    """

    def execute(self):
        # ! Warning: 注意 [^.] 是必要的，否则会删除所有 ..* 形式的文件和目录，
        # ! 即 HOME 目录的所有数据，也即保护父目录
        #
        # ! Bug !
        # 1. 当回收站只有隐藏文件时，可能因为 * 匹配不到文件而中断命令执行
        #    self.fm.run("rm -rf ~/.Trash/{*,.[^.]*}")
        # 2. 一些系统/情况下即使用 -rf 还会有强制确认,因此用 \rm,同时转义要用 \\
        # 3. 交给另一个 sh 去执行，就看不见恼人的 not found 消息了
        self.fm.run("sh -c '\\rm -rf ~/.Trash/*;yes|rm -rf ~/.Trash/.[^.]*'")
        self.fm.run(
            "sh -c '\\rm -rf ~/.local/share/Trash/expunged/*;\\rm -rf ~/.local/share/Trash/expunged/.[^.]*'")
        self.fm.run(
            "sh -c '\\rm -rf ~/.local/share/Trash/files/*;\\rm -rf ~/.local/share/Trash/files/.[^.]*'")
        self.fm.run(
            "sh -c '\\rm -rf ~/.local/share/Trash/info/*;\\rm -rf ~/.local/share/Trash/info/.[^.]*'")
