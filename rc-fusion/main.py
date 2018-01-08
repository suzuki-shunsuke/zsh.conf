import os

from jinja2 import Environment, FileSystemLoader
import yaml

from plugins.globs import Globs


CFG_FILE_NAME = "rc-fusion.yml"


def get_cfg_dir():
    return os.path.realpath(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))


CFG_DIR = get_cfg_dir()

with open(os.path.join(CFG_DIR, CFG_FILE_NAME)) as r:
    cfg = yaml.load(r)
    cfg.setdefault("root", CFG_DIR)
    if not os.path.isabs(cfg["root"]):
        cfg["root"] = os.path.realpath(os.path.join(CFG_DIR, cfg["root"]))

globs = Globs(cfg)

loader = FileSystemLoader([
    cfg["root"], os.path.dirname(__file__)])

env_globals = {}
env_globals["globs"] = globs.run

env = Environment(
    loader=loader, autoescape=False, trim_blocks=True, lstrip_blocks=True)
env.globals.update(env_globals)

for src, item in cfg["entry"].items():
    template = env.get_template(src)
    dest = item["dest"] if os.path.isabs(item["dest"]) else os.path.join(CFG_DIR, item["dest"])
    with open(os.path.join(os.path.dirname(__file__), dest), "w") as w:
        w.write(template.render())
