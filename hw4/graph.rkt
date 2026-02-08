#lang dssl2

# HW4: Graph

import cons
import 'hw4-lib/dictionaries.rkt'


###
### REPRESENTATION
###

# A Vertex is a natural number.
let Vertex? = nat?

# A VertexList is either
#  - None, or
#  - cons(v, vs), where v is a Vertex and vs is a VertexList
let VertexList? = Cons.ListC[Vertex?]

# A Weight is a real number. (It’s a number, but it’s neither infinite
# nor not-a-number.)
let Weight? = AndC(num?, NotC(OrC(inf, -inf, nan)))

# An OptWeight is either
# - a Weight, or
# - None
let OptWeight? = OrC(Weight?, NoneC)

# A WEdge is WEdge(Vertex, Vertex, Weight)
struct WEdge:
    let u: Vertex?
    let v: Vertex?
    let w: Weight?

# A WEdgeList is either
#  - None, or
#  - cons(w, ws), where w is a WEdge and ws is a WEdgeList
let WEdgeList? = Cons.ListC[WEdge?]

# A weighted, undirected graph ADT.
interface WUGRAPH:
    # Returns the number of vertices in the graph. (The vertices are
    # numbered 0, 1, ..., k - 1.)
    def n_vertices(self) -> nat?
    # Returns the number of edges in the graph.
    def n_edges(self) -> nat?
    # Sets the weight of the edge between u and v to be w.
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?) -> NoneC
    # Gets the weight of the edge between u and v, or None if there
    # is no such edge.
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?
    # Gets a list of all vertices adjacent to v.
    def get_adjacent(self, v: Vertex?) -> VertexList?
    # Gets a list of all edges in the graph.
    def get_all_edges(self) -> WEdgeList?

class WUGraph (WUGRAPH):
    let num_vert
    let num_edges
    let adjacency_matrix
    
    #   ^ ADD YOUR FIELDS HERE

    def __init__(self, n_vert: nat?):
        self.num_vert = n_vert
        self.num_edges = 0
        
        # self.adjancency_matrix = vec(self.num_vert)
        # for i in range(self.num_vert):
            # self.adjacency_matrix[i] = vec(self.num_vert)
        
        # lambda function implementation
        self.adjacency_matrix = vec(self.num_vert, lambda i : vec(self.num_vert))
    #   ^ WRITE YOUR IMPLEMENTATION HERE
        
        
    def n_vertices(self) -> nat?:
        return self.num_vert
    
    def n_edges(self) -> nat?:
        return self.num_edges
    
    def _out_of_bounds(self, v: Vertex?) -> bool?:
        if ((v < 0) or (v >= self.num_vert)):
            return True
        else:
            return False
        
    def set_edge(self, u: Vertex?, v: Vertex?, w: OptWeight?):
        if (self._out_of_bounds(u) or self._out_of_bounds(v)):
            error('out of bounds')
        
        
        if w is None:
            # weight none, remove existing edge
            if self.adjacency_matrix[u][v] != None:
                # symmetry
                self.adjacency_matrix[u][v] = None
                self.adjacency_matrix[v][u] = None
                self.num_edges = self.num_edges - 1
        else:
            # weight exists, check if edge alr exists, update edge
            if self.adjacency_matrix[u][v] == None:
                self.num_edges = self.num_edges + 1
                
            self.adjacency_matrix[u][v] = w
            self.adjacency_matrix[v][u] = w
            
        
    def get_edge(self, u: Vertex?, v: Vertex?) -> OptWeight?:
        if (self._out_of_bounds(u) or self._out_of_bounds(v)): 
            error('out of bounds')   
        return self.adjacency_matrix[u][v]
         
        
    def get_adjacent(self, v: Vertex?) -> VertexList?:
        # needs to error on out of bound v o/w accesses wrong
        if (self._out_of_bounds(v)): 
            error('out of bounds')
            
        let result = None
        for i in range(self.num_vert):
            if self.adjacency_matrix[i][v] != None:
                # linked list of vertices
                result = cons(i, result)
        return result
        
        
    def get_all_edges(self) -> WEdgeList?:
        let result = None
        for i in range(self.num_vert):
            # avoid double counting w/ dynamic inner-loop range
            for j in range(i, self.num_vert):
                if self.adjacency_matrix[i][j] != None:
                    result = cons(WEdge(i, j, self.adjacency_matrix[i][j]), result)
        return result
            

# Other methods you may need can go here.

    
###
### List helpers
###

# When testing, you should normalize the results of methods that produce
# results in an unspecified order. We provide these functions to help you
# do that; see details in the handout.

# normalize_vertices : ListOf[Vertex] -> ListOf[Vertex]
# Sorts a list of numbers.
def normalize_vertices(lst: Cons.list?) -> Cons.list?:
    def vertex_lt?(u, v): return u < v
    return Cons.sort[Vertex?](vertex_lt?, lst)

# normalize_edges : ListOf[WEdge] -> ListOf[WEdge]
# Sorts a list of weighted edges, lexicographically.
def normalize_edges(lst: Cons.list?) -> Cons.list?:
    def normalize_edge(e: WEdge?) -> WEdge?:
        if e.u > e.v: return WEdge(e.v, e.u, e.w)
        else: return e
    def edge_lt?(e1, e2):
        return e1.u < e2.u or (e1.u == e2.u and e1.v < e2.v)
    lst = Cons.map(normalize_edge, lst)
    return Cons.sort[WEdge?](edge_lt?, lst)

    
test 'nowhere near enough':
    let g = WUGraph(2)
    g.set_edge(0,1,1)
    assert g.get_edge(0,1) == 1

test 'empty':
    let g = WUGraph(5)
    assert g.n_vertices() == 5
    assert g.n_edges() == 0
    
    for i in range(5):
        assert g.get_adjacent(i) == None
        
test 'out of bounds':
    let g = WUGraph(2)

    assert_error g.get_edge(-1, 0)
    assert_error g.get_edge(0, 2)

    assert_error g.set_edge(0, 5, 3)
    assert_error g.set_edge(-1, 0, 1)

    assert_error g.get_adjacent(10)
    
test 'one edge':
    let g = WUGraph(2)
    g.set_edge(0,1, 67)
    assert g.get_edge(0,1) == 67
    assert g.get_edge(1,0) == 67
    
    assert g.n_edges() == 1
    
    assert normalize_vertices(g.get_adjacent(0)) == cons(1, None)
    assert normalize_vertices(g.get_adjacent(1)) == cons(0, None)
    
test 'update edge':
    let g = WUGraph(2)
    g.set_edge(0,1, 67)
    g.set_edge(1,0, 76)
    
    assert g.get_edge(0,1) == 76
    assert g.get_edge(1,0) == 76
    
    assert g.n_edges() == 1    
 
test 'delete edge':
    let g = WUGraph(2)
    
    g.set_edge(0, 1, None)
    assert g.n_edges() == 0
    
    assert g.get_all_edges() == None
    
    g.set_edge(0,1, 3)
    g.set_edge(1, 0, None)
    
    assert g.n_edges() == 0
    assert g.get_edge(0, 1) == None
    assert g.get_edge(1, 0) == None
    
    
test 'two edges from same node':
    let g = WUGraph(4)
    g.set_edge(0, 1, 10)
    g.set_edge(0, 2, 11)
    
    assert g.n_edges() == 2
    assert normalize_vertices(g.get_adjacent(0)) == cons(1, cons(2, None))
    
    
    g.set_edge(0, 2, None)
    assert g.n_edges() == 1
    
    assert g.get_edge(1, 0) == 10
    assert g.get_edge(0, 2) == None
    assert normalize_vertices(g.get_adjacent(0)) == cons(1, None)
    
test 'self- edge':
    let g = WUGraph(4)
    g.set_edge(1, 1, 10)
    
    
    assert g.n_edges() == 1
    assert g.get_edge(1, 1) == 10
    assert normalize_edges(g.get_all_edges()) == cons(WEdge(1, 1, 10), None)
    
###
### BUILDING GRAPHS
###

def example_graph() -> WUGraph?:
    let result = WUGraph(6) # 6-vertex graph from the assignment
    pass
#   ^ WRITE YOUR IMPLEMENTATION HERE

struct CityMap:
    let graph
    let city_name_to_node_id
    let node_id_to_city_name

def my_home_region():
    pass
#   ^ WRITE YOUR IMPLEMENTATION HERE

###
### DFS
###

# dfs : WUGRAPH Vertex [Vertex -> any] -> None
# Performs a depth-first search starting at `start`, applying `visit`
# to each vertex once as it is discovered by the search.
def dfs(graph: WUGRAPH!, start: Vertex?, visit: FunC[Vertex?, AnyC]) -> NoneC:
    pass
#   ^ WRITE YOUR IMPLEMENTATION HERE

###
### DFS helpers
###

# dfs_to_list : WUGRAPH Vertex -> ListOf[Vertex]
# Performs a depth-first search starting at `start` and returns a
# list of all reachable vertices.
# This function uses your `dfs` function to build a list in the
# order of the search.
def dfs_to_list(graph: WUGRAPH!, start: Vertex?) -> VertexList?:
    let list = None
    # Add to the front when we visit a node
    dfs(graph, start, lambda new: list = cons(new, list))
    # Reverse to the get elements in visiting order.
    return Cons.rev(list)

# one_of : AnyC? VecC[AnyC] -> bool?
# Returns true is `x` is one of the elements of `vec`.
def one_of(x, vec):
    for y in vec:
        if x == y: return True
    return False

## You should test your code thoroughly. Here is one test to get you started:

test 'my first DFS test':
    let g = WUGraph(4)
    g.set_edge(0,1,1)
    g.set_edge(0,2,10)
    g.set_edge(1,3,12)
    g.set_edge(2,3,-4)

    # Cons.from_vec is a convenience function from the `cons` library that
    # allows you to write a vector (using the nice vector syntax), and get
    # a linked list with the same elements.
    assert one_of(dfs_to_list(g, 0),
                  [Cons.from_vec([0,1,3,2]),
                   Cons.from_vec([0,2,3,1])])