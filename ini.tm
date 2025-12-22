
use patterns

_USAGE := "
    Usage: ini <filename> "[section[/key]]"
"
_HELP := "
    ini: A .ini config file reader tool.
    $_USAGE
"

func parse_ini(path:Path -> {Text:{Text:Text}})
    text := path.read() or exit("Could not read INI file: \[31;1]$(path)\[]")
    sections : @{Text:@{Text:Text}}
    current_section : @{Text:Text}

    # Line wraps:
    text = $Pat"\\{1 nl}{0+space}".replace(text, " ")

    for line in text.lines()
        line = line.trim()
        skip if line.starts_with(";") or line.starts_with("#")
        if m := $Pat"[?]".match(line)
            section_name := m.captures[1]!.trim().lower()
            current_section = @{}
            sections[section_name] = current_section
        else if m := $Pat"{..}={..}".match(line)
            key := m.captures[1]!.trim().lower()
            value := m.captures[2]!.trim()
            current_section[key] = value

    return {k:v[] for k,v in sections[]}

func main(path:Path, key:Text?)
    keys := (key or "").split("/")
    if keys.length > 2
        exit("
            Too many arguments! 
            $_USAGE
        ")

    data := parse_ini(path)

    section := (keys[1] or '*').lower()
    if section == '*'
        say("$data")
        return

    section_data := data[section] or exit("
        Invalid section name: \[31;1]$section\[]
        Valid names: \[1]$(", ".join([k.quoted() for k in data.keys]))\[]
    ")

    section_key := (keys[2] or '*').lower()
    if section_key == '*'
        say("$section_data")
        return

    value := section_data[section_key] or exit("
        Invalid key: \[31;1]$section_key\[]
        Valid keys: \[1]$(", ".join([s.quoted() for s in section_data.keys]))\[]
    ")
    say(value)
