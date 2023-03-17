import sys

# check input arguments
if len(sys.argv) != 3:
    print("*******Input wrong arguments!*******")
    sys.exit(1) 

# read input and output files' names
input_file, output_file = sys.argv[1], sys.argv[2]

def coloring(nodes_input):
    # rank nodes (that is, live ranges) of the interference graph according to the number of neighbours in descending order.
    nodes_input.sort(key = len, reverse = True)
    length = len(nodes_input)
    # save available colors which are unused
    edge_constraints = {}
    for j in range(length):
        available_colors = set(range(26))
        edge_constraints[j] = available_colors

    # save the final answer: colors assigned for each node
    colors_of_nodes = {}

    for k in range(length):
        if edge_constraints[k]:
            # pop out the 1st element 
            color = edge_constraints[k].pop()
            colors_of_nodes[nodes_input[k][0]] = chr(color + ord('A'))
            
            for neighbor in nodes_input[k][1:]:
                for i, node in enumerate(nodes_input):
                    if node[0] == neighbor:
                        neighbor_idx = i
                        break
                edge_constraints[neighbor_idx].discard(color)
        else:
            # if there are no available colors for anything.
            return None
    return colors_of_nodes

temp = []
node = []
try:
    # read the input and clean the source data
    with open(input_file, 'r') as reader:
        for line in reader:
            line_clean = line.strip().split()
            line = list(map(int, line_clean))
            node_idx = line[0]

            # check illegal inputs: if it's not bidirection connected 
            for i in (line[1:]):
                if(node_idx,i) in temp:
                    temp.remove((node_idx, i))
                elif(i,node_idx) in temp:
                    temp.remove((i,node_idx))
                else:
                    temp.append((node_idx, i))

            node.append(line)
except Exception:
    print("*******Can not find this file! / Invalid Input file!*******")
    sys.exit(1)

if temp:
    print("Wrong input!!")
    sys.exit(1)
else:
    idx = [i[0] for i in node]
    # assign colors for different nodes
    result = coloring(node)
    if result is not None:
        # write into output file
        with open(output_file, 'w') as writer:
            for i in range(len(idx)):
                    # check with the last line's empty space
                    ending = '' if i == len(idx)-1 else '\n'
                    print("{}{}".format(str(idx[i]), str(result[idx[i]])), file= writer, end= ending)
                    
            writer.close()
            print("============Output successfully!============")

    else:
        print("*******Cannot color the graph using 26 or fewer colors in this situation!*******")
        sys.exit(1)

