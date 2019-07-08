def schema: path(..)|map(tostring)|join("/");
#def nvp(): to_entries|map("\(.key)=\(.value|tostring)")|join(" ");
def nvp(keys): . as $h|keys|split(",")|map([.,($h[.]|tostring)]|join("="))|join(",");
def csv(keys): . as $h|keys|split(",")|map($h[.]|if .==null then "" else (.|tostring) end)|join(",");
def hostgroup: gsub("^(slcsb|slc|phx|lvs|[dc]cg[0-9]+(b[0-9]+)?|[tr]az[0-9]+|cfbt[0-9]+)|([0-9]+[ab]?)$";"");
def pool2app: ascii_downcase|gsub("[.-]";"_")|gsub("^pool[._-]|merged[._-]|[._-]vip|[._-]pool|[._-]servers?|[._-][0-9]+|__.*";"")|gsub("ca[._-](?<name>.*)";"\(.name)_ca");
