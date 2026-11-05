# Fallback packer for build.sh where zip(1) is absent, as on git-bash.
import os, sys, zipfile

work, out = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk(work):
        dirs.sort()
        for name in sorted(files):
            path = os.path.join(root, name)
            z.write(path, os.path.relpath(path, work).replace(os.sep, "/"))
