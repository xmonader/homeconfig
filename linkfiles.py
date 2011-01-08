#!/usr/bin/env /usr/bin/python2
import os, sys, shutil
from optparse import OptionParser
parser = OptionParser()
parser.add_option("-r", "--root", dest="root",action="store_true", default=False,
                  help="Do root")
(options, args) = parser.parse_args()
fullpath = os.path.abspath(os.path.dirname(sys.argv[0]))
linkfolders = ['.config/awesome','.config/autostart', '.zsh.d', '.ssh']
target = os.environ['HOME']

if options.root:
    if os.getuid() != 0:
        print "Use sudo not root"
        sys.exit(1)
    else:
        fullpath = os.path.join(fullpath, 'osconfig')
        target = "/"
else:
    fullpath = os.path.join(fullpath, 'homeconfig')

striplen = len(fullpath)+1
#do folders defined in linkfolders
def createDir(folder1, folderb):
    folder = os.path.join(os.sep, folder1, folderb)
    if not os.path.exists(folder):
        os.mkdir(folder)
    return folder
#cleanuppath
def cleanuppath(targetfolder):
    if os.path.islink(targetfolder):
        os.remove(targetfolder)
    elif os.path.isdir(targetfolder):
        shutil.rmtree(targetfolder)
    elif os.path.exists(targetfolder):
        os.remove(targetfolder)
#createParentFolder
def createRecusiveFolder(folder):
    if not os.path.isdir(folder):
        #make parenttarget
        reduce(createDir, folder.split(os.sep)[1:])

def createParentFolder(targetfolder):
    parenttarget = os.path.abspath(os.path.join(targetfolder,'..'))
    createRecusiveFolder(parenttarget)

#do normal files in root
for curdir, dirs, files in os.walk(fullpath):
    relativedir = curdir[striplen:]
    targetdir = os.path.join(target, relativedir)
    if relativedir not in linkfolders:
        print 'Creating links files for folder', relativedir
        createRecusiveFolder(targetdir)
        for file in files:
            targetfile = os.path.join(targetdir, file)
            sourcefile = os.path.join(curdir, file)
            cleanuppath(targetfile)
            os.symlink(sourcefile, targetfile)
    else:
        cleanuppath(targetdir)
        createParentFolder(targetdir)
        print 'Link dir', relativedir
        os.symlink(curdir, targetdir)
        for dir in dirs[::-1]:
            dirs.remove(dir)
