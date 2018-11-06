 # input file 
file = open("sample.gr", "r")                        

with open("sample.gr") as f:
    content = f.readlines()

content = [x.strip() for x in content] 

head = content[7]
head = head.replace('p sp ','')
head = [int(s) for s in head.split() if s.isdigit()]

graph = []
edge_set = set()
for line in content[8:]:
    line = line.replace('a ', '')
    edge = [int(s) for s in line.split() if s.isdigit()]
    edge_pair = edge[0:2]
    edge_pair.sort()
    edge_pair = tuple(edge_pair)
    if edge_pair not in edge_set:
        graph.append(edge)
        edge_set.add(edge_pair)

file.close()

# output file
new_graph_file = open("new_graph.txt", "w")

title = " ".join(str(x) for x in head) + "\n"
new_graph_file.write(title)

for edge in graph:
    edge = " ".join(str(x) for x in edge) + "\n"
    new_graph_file.write(edge)

new_graph_file.close()