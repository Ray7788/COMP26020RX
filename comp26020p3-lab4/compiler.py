import sys

class Graph:
    def __init__(self, node_num,  edges):
        # initialise a 2D list Graph 
        self.neighbors = [[] for _ in range(node_num + 1)]
        # add neighbor node for each other
        for a, b in edges:
            self.neighbors[a].append(b)
            self.neighbors[b].append(a)

        # save each node's neighbor 
        self.sub_neighbors_len = [len(neighbor) for neighbor in self.neighbors]
        # Rank nodes (that is, live ranges) of the interference graph according to the number of neighbours in descending order.
        self.ordered = sorted(range(len(self.sub_neighbors_len)), key= lambda x: (self.sub_neighbors_len[x], -x), reverse = True)
        # pop out the node with the fewest neighbor 
        self.ordered.pop()

def coloring(graph):
    # set up an empty dictionary
    colors_of_nodes = {}

    for k in graph.ordered:
        # unique elements stored in it
        temp_colors = set()

        # check if it is colored
        for i in graph.neighbors[k]:
            if i in colors_of_nodes:
                temp_colors.add(colors_of_nodes.get(i))

        # find the 1st which is uncolored 
        assigned_color = 0
        for color in temp_colors:
            if assigned_color != color:
                break
            assigned_color += 1

        # assign colors to 
        colors_of_nodes[k] = assigned_color
    
    # print(len(graph.ordered), len(set(colors_of_nodes.values())))
    if len(graph.ordered) >= 27 and len(set(colors_of_nodes.values())) > 26:
        print("*******Cannot color the graph using 26 or fewer colors in this situation!*******")
        sys.exit(1)

    return colors_of_nodes

# check input arguments
if len(sys.argv) != 3:
    print("*******Input wrong arguments!*******")
    sys.exit(1) 
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
                # append a tuple for each node
                edges.append((i+1, int(lines[i][j])))

        # draw the graph
        graph = Graph(node_num, edges)
        # color the graph
        colors_of_nodes = coloring(graph)

except FileNotFoundError:
    print("*******Can not find this file!*******")
    sys.exit(1)    

# encapsulate
# write into output file
try:
    with open(output_file, 'w') as writer:
        for m in range(1, len(colors_of_nodes)+1):
            # deal with the last line's space
            ending = '' if m == len(colors_of_nodes) else '\n'
            
            letter = chr(ord('A') + colors_of_nodes[m])
            # Check if the character is not an alphabet   
            if not letter.isalpha():
                print("*******Input wrong characters!*******")
                sys.exit(1)
            else:
                print("{}{}".format(m, letter), file= writer, end= ending)
    writer.close()
    print("============Output successfully!============")

except:
    print("*******Can not write into file!*******")
    sys.exit(1)    
