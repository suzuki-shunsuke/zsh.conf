"""
https://github.com/git/git/blob/v2.10.2/Documentation/gitignore.txt#L70
"""

import glob
import os

from .base import Base


class Globs(Base):
    def run(self, *patterns, recursive=True):
        """
        priority of patterns
        the number of '**'
        whether '*' is included or not
        For example, '**/zprofile' and 'foo/*' have same score
        """
        includes = {}
        for i, pattern in enumerate(patterns):
            pattern = pattern.strip()
            if not pattern:
                continue
            included = True
            if pattern[0] == "!":
                pattern = pattern[1:]
                included = False
            matches = set(glob.glob(
                os.path.join(self.cfg["root"], pattern),
                recursive=recursive))
            dirname, basename = os.path.split(pattern)
            score = - dirname.count("**") - basename.count("*")
            for m in matches:
                if m in includes and includes[m][1] >= score:
                    continue
                includes[m] = (i, score, included)
        ret = sorted(
            (item[0], os.path.relpath(path, self.cfg["root"]))
            for (path, item) in includes.items() if item[2])
        return [item[1] for item in ret]
