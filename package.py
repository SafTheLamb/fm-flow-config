import json
import os
import shutil

# Get formatted package name
with open("info.json") as jsonfile:
    jsondata = json.load(jsonfile)
    packagename = f"{jsondata['name']}_{jsondata['version']}"
projectdir = os.getcwd()
packagedir = os.path.join(projectdir, packagename)

# Function for cleaning a directory of all files and folders
def cleandir(directory):
    if not os.path.exists(directory):
        return
    for root, dirs, files in os.walk(directory, topdown=False):
        for name in files:
            os.remove(os.path.join(root, name))
        for name in dirs:
            os.rmdir(os.path.join(root, name))

# Create the package subfolder if it doesn't exist, or otherwise clean it
if not os.path.exists(packagedir):
    os.makedirs(packagedir)
else:
    cleandir(packagedir)

# Copy all other files into the subfolder
denyfiles = { f'{packagename}.zip', 'package.py', '.gitignore', 'README.md', }
denydirs = { f'{packagename}', '.git', '.vscode', }

for root, dirs, files in os.walk(projectdir):
    newroot = os.path.join(packagedir, root.removeprefix(projectdir).removeprefix('\\'))
    for name in denyfiles:
        if name in files:
            files.remove(name)
    for name in denydirs:
        if name in dirs:
            dirs.remove(name)
    for name in files:
        shutil.copy(os.path.join(root, name), os.path.join(newroot, name))
    for name in dirs:
        os.makedirs(os.path.join(newroot, name))

# Zip the package up
packagefile = shutil.make_archive(packagename, 'zip', projectdir, packagename)
# shutil.copy(packagefile, os.path.join(os.getenv('APPDATA'), f"Factorio/mods/{packagename}.zip"))

# Copy the package directory into the mods subfolder
modsdir = os.path.join(os.getenv('APPDATA'), f'Factorio/mods/{packagename}')
if not os.path.exists(modsdir):
    os.makedirs(modsdir)
else:
    cleandir(modsdir)
for root, dirs, files in os.walk(packagedir):
    newroot = os.path.join(modsdir, root.removeprefix(packagedir).removeprefix('\\'))
    for name in files:
        shutil.copy(os.path.join(root, name), os.path.join(newroot, name))
    for name in dirs:
        os.makedirs(os.path.join(newroot, name))

# Clean up package folder
cleandir(packagedir)
os.rmdir(packagedir)
