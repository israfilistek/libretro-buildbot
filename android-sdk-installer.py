import subprocess,re,sys

w = subprocess.check_output(["android", "list", "sdk", "--all"])
lines = w.split("\n")
tools = filter(lambda x: "Build-tools" in x, lines)
filters = []
for tool in tools:
  m = re.search("^\s+([0-9]+)-", tool)
  tool_no = m.group(1)
  filters.append(tool_no)

if len(filters) == 0:
  raise Exception("Not found build tools")


filters.extend(['extra', 'platform', 'platform-tool', 'tool'])

filter = ",".join(filters)

expect= '''set timeout -1;
expect {
    "\[y\/\n]: " {
        send "y\r"
        expect "y\r"
        exp_continue
        }
}'''

print expect

ret = subprocess.call(["expect", "-c", expect])
sys.exit(ret)
