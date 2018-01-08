import os

from git import Repo

from .base import Base


def relpath(path):
    """
    github.com/foo/bar
    foo/bar

    Returns:
      (url, path)
    """

    parts = path.split("/")[-3:]
    L = len(parts)
    if L <= 1:
        raise ValueError("path is invalid: {}".format(path))
    if L == 2:
        return ("https://github.com/{}".format("/".join(parts)),
                "github.com/{}".format("/".join(parts)))
    if L == 3:
        return ("https://{}".format("/".join(parts)),
                "/".join(parts))
    return "/".join(parts)


class Remote(Base):
    def run(self, path, *, version=None, patterns=None, without_contenxt=False) -> str:
        """
        """
        params = {}
        if version:
            params["branch"] = version
        url, local_path = relpath(path)
        Repo.clone_from(url, os.path.join(self.cfg["repo"], local_path), **params)
        ret = []
        return "\n\n".join(ret)
