def schema: path(..)|map(tostring)|join("/");
#def nvp(): to_entries|map("\(.key)=\(.value|tostring)")|join(" ");
def nvp(keys): . as $h|keys|split(",")|map([.,($h[.]|tostring)]|join("="))|join(",");
def csv(keys): . as $h|keys|split(",")|map($h[.]|if .==null then "" else (.|tostring) end)|join(",");
#def slack: [.user,.ts,.text]|join(",");
def hostgroup: gsub("^(slcsb|slc|phx|lvs|[dc]cg[0-9]+(b[0-9]+)?|[tr]az[0-9]+|cfbt[0-9]+)|([0-9]+[ab]?)$";"");
def pool2app: ascii_downcase|gsub("[.-]";"_")|gsub("^pool[._-]|merged[._-]|[._-]vip|[._-]pool|[._-]servers?|[._-][0-9]+|__.*";"")|gsub("ca[._-](?<name>.*)";"\(.name)_ca");
def renamekey(o;n): with_entries(.key|=gsub(o;n));
def trimaws(s): s|tostring|gsub(".us-east-..*.amazonaws.com";".AWS");
def same(a;b):  a|=if a==b then "same" else a end;
def map1(f):    [.[1:]|f];
def hide(h):    if .==h then null else . end;
def har:        .log.entries[]|(.response.content)+={url:.request.url,status:.response.status}|.response.content| .text = if .encoding=="base64" then (.text|@base64d) else .text end | .text = if .mimeType=="application/json" and .text? and (.text|length)>3 then (.text|fromjson) else .text end;
def harslack:   har|select(.url|test("convers"));
def trim(s):    s|gsub("\\s+";" ")|gsub("^\\s+|\\s+$";"");
def crc(s):     (s|explode|reduce .[] as $c ( 0 ; (.+$c)|floor ));
# re-order object keys by a specific list
def order(ord)  . as $obj|ord|split(" ")|reduce .[] as $k ( {}; .+([{key:$k,value:$t[$k]}]|from_entries) );
