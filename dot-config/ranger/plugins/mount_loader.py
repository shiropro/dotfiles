# 以下命令假设你正在使用 CDemu 作为你的镜像挂载器和一些挂载虚拟驱动器到指定位置 (如 '/media/virtualrom') ，
# 类似于 autofs的系统。不要忘记根据你的系统设置修改挂载路径
#
# 为了从 ranger 里把镜像挂载到 cdemud 虚拟驱动器, 需要选中镜像文件然后在终端输入 ':mount'
# 根据设置，挂载可能需要一些时间(我需要长达一分钟) 
# 以下命令使用自定义的 loader 会等待加载过程结束然后通过后台在第 9 标签打开挂载了的镜像

import os, time
from ranger.api.commands import Command
from ranger.core.loader import Loadable
from ranger.ext.signals import SignalDispatcher
from ranger.ext.shell_escape import *

class MountLoader(Loadable, SignalDispatcher):
    """
    Wait until a directory is mounted
    """
    def __init__(self, path):
        SignalDispatcher.__init__(self)
        descr = "Waiting for dir '" + path + "' to be mounted"
        Loadable.__init__(self, self.generate(), descr)
        self.path = path

    def generate(self):
        available = False
        while not available:
            try:
                if os.path.ismount(self.path):
                    available = True
            except:
                pass
            yield
            time.sleep(0.03)
        self.signal_emit('after')

class mount(Command):
    def execute(self):
        selected_files = self.fm.env.cwd.get_selection()

        if not selected_files:
            return

        space = ' '
        self.fm.execute_command("cdemu -b system unload 0")
        self.fm.execute_command("cdemu -b system load 0 " + \
                space.join([shell_escape(f.path) for f in selected_files]))
 
        mountpath = "/media/virtualrom/"

        def mount_finished(path):
            currenttab = self.fm.current_tab
            self.fm.tab_open(9, mountpath)
            self.fm.tab_open(currenttab)

        obj = MountLoader(mountpath)
        obj.signal_bind('after', mount_finished)
        self.fm.loader.add(obj)