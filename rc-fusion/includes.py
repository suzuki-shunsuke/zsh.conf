def run(*args) -> str:
    ret = []
    for arg in args:
        if isinstance(arg, str):
            ret.append("{% include '{}' %}".format(arg))
        elif isinstance(arg, list):
            ret.append(run(*arg))
        elif isinstance(arg, tuple):
            ret.append("{% include '{}' {} %}".format(arg))
        else:
            raise TypeError("arg must be str or List[str] or tuple")
