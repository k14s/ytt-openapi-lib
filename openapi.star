load("@ytt:data", "data")
load("@ytt:yaml", "yaml")

def process(name):
  result = []
  for doc in data.read(name).split("---\n"):
    doc = replace_file_refs(yaml.decode(doc))
    doc = replace_relative_refs(doc, doc)
    result.append(doc)
  end
  return result
end

def replace_file_refs(stuff):
  t = type(stuff)
  if t == "dict":
    new_stuff = dict()
    for k in stuff:
      if k == "$ref" and not stuff[k].startswith("#"):
        return yaml.decode(data.read(stuff[k]))
      end
      new_stuff[k] = replace_file_refs(stuff[k])
    end
  elif t == "list":
    new_stuff = list()
    for v in stuff:
      new_stuff.append(replace_file_refs(v))
    end
  else:
    new_stuff = stuff
  end
  return new_stuff
end

def replace_relative_refs(stuff, all_stuff):
  t = type(stuff)
  if t == "dict":
    new_stuff = dict()
    for k in stuff:
      if k == "$ref" and stuff[k].startswith("#"):
        return find_section(stuff[k], all_stuff)
      end
      new_stuff[k] = replace_relative_refs(stuff[k], all_stuff)
    end
  elif t == "list":
    new_stuff = list()
    for v in stuff:
      new_stuff.append(replace_relative_refs(v, all_stuff))
    end
  else:
    new_stuff = stuff
  end
  return new_stuff
end

def find_section(path, stuff):
  for x in path[2:].split("/"):
    stuff = stuff[x]
  end
  return stuff
end

def clean_file_name(name):
  if name.startswith("./"):
    return name[2:]
  elif name.startswith("/"):
    return name[1:]
  end
  return name
end
