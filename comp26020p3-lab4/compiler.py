import sys
    
class Graph:
    def __init__(self, node_num, edges):
        # initialise Graph 
        self.neighbors = [[] for _ in range(node_num + 1)]
        for a, b in edges:
            self.neighbors[a].append(b)
            self.neighbors[b].append(a)

        # save each node's neighbor 
        self.sub_neighbors_len = [len(neighbor) for neighbor in self.neighbors]

        # Rank nodes (that is, live ranges) of the interference graph according to the number of neighbours in descending order.
        self.ordered = sorted(range(len(self.sub_neighbors_len)), key= lambda k: (self.sub_neighbors_len[k], -k), reverse = True)

        # pop out the last line 
        self.ordered.pop()

def coloring(graph):
    # set up an empty dictionary
    nodes_colors = {}
    # Iterate
    for u in graph.ordered:
        current_colors = set()

        # check if it is colored
        for i in graph.neighbors[u]:
            if i in nodes_colors:
                current_colors.add(nodes_colors.get(i))

        # find the 1st which is uncolored 
        selected_color = 0
        for color in current_colors:
            if selected_color != color:
                break
            selected_color += 1

        # assign colors to 
        nodes_colors[u] = selected_color
 
    # 打印节点颜色（调试用）
    # for v in range(len(nodes_colors)):
    #     print("{}{}".format(v + 1, colors[nodes_colors[v + 1]]))

    return nodes_colors

try:
    # read input and output files' names
    input_file, output_file = sys.argv[1], sys.argv[2]
    try:
        # read the input and clean the source data
        with open(input_file, 'r') as reader:
            lines = [line.strip().split()[1:] for line in reader.readlines()]
            reader.close()

            # calculate how many nodes
            node_num = len(lines)
            edges = []
            for i in range(node_num):
                for j in range(len(lines[i])):
                    edges.append((i+1, int(lines[i][j])))

            # draw the graph
            graph = Graph(node_num, edges)
            # shade the color
            nodes_colors = coloring(graph)
    except FileNotFoundError:
        print("*******Can not find this file!*******")
        
except IndexError:
    print("Input wrong")


# write into output file
try:
    with open(output_file, 'w') as writer:
        for m in range(1, len(nodes_colors)+1):
            # deal with the last line's space
            ending = '' if m == len(nodes_colors) else '\n'
            print("{}{}".format(m, chr(ord('A') + nodes_colors[m])), file= writer, end= ending)
    writer.close()
    print("============Output successfully!============")
except:
    print("*******Can not write into file!*******")


# eedges =[]
# for i in range(10):
#     for j in range(50):
#         eedges.append((i, int(lines[i][j])))