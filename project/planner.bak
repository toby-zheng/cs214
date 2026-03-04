#lang dssl2

# Final project: Trip Planner

import cons
import sbox_hash
import 'project-lib/dictionaries.rkt'
import 'project-lib/graph.rkt'
import 'project-lib/binheap.rkt'

### Basic Types ###

#  - Latitudes and longitudes are numbers:
let Lat?  = num?
let Lon?  = num?

#  - Point-of-interest categories and names are strings:
let Cat?  = str?
let Name? = str?

### Raw Item Types ###

#  - Raw positions are 2-element vectors with a latitude and a longitude
let RawPos? = VecKC[Lat?, Lon?]

#  - Raw road segments are 4-element vectors with the latitude and
#    longitude of their first endpoint, then the latitude and longitude
#    of their second endpoint
let RawSeg? = VecKC[Lat?, Lon?, Lat?, Lon?]

#  - Raw points-of-interest are 4-element vectors with a latitude, a
#    longitude, a point-of-interest category, and a name
let RawPOI? = VecKC[Lat?, Lon?, Cat?, Name?]

### Contract Helpers ###

# ListC[T] is a list of `T`s (linear time):
let ListC = Cons.ListC
# List of unspecified element type (constant time):
let List? = Cons.list?


interface TRIP_PLANNER:

    # Returns the positions of all the points-of-interest that belong to
    # the given category.
    def locate_all(
            self,
            dst_cat:  Cat?           # point-of-interest category
        )   ->        ListC[RawPos?] # positions of the POIs

    # Returns the shortest route, if any, from the given source position
    # to the point-of-interest with the given name.
    def plan_route(
            self,
            src_lat:  Lat?,          # starting latitude
            src_lon:  Lon?,          # starting longitude
            dst_name: Name?          # name of goal
        )   ->        ListC[RawPos?] # path to goal

    # Finds no more than `n` points-of-interest of the given category
    # nearest to the source position.
    def find_nearby(
            self,
            src_lat:  Lat?,          # starting latitude
            src_lon:  Lon?,          # starting longitude
            dst_cat:  Cat?,          # point-of-interest category
            n:        nat?           # maximum number of results
        )   ->        ListC[RawPOI?] # list of nearby POIs   
    
# (euclidian) distance helper
def _distance(lat_1, long_1, lat_2, long_2):
    let d_lat = lat_2 - lat_1
    let d_long = long_2 - long_1
    return ((d_lat * d_lat) + (d_long * d_long)).sqrt()
    
def _pos_to_key(lat, long):
    return (str(lat) + ',' + str(long))

class TripPlanner (TRIP_PLANNER):
    # map (WUGraph)
    let map
    
    ## HASH TABLES ##
    # known sizing
    
    # pos to vertex dict
    let pos_to_vertex
    
    # vertex to pos
    let vertex_to_pos
    
    # vertex to poi(s)
    let vertex_to_poi
    
    
    ## ASSOCIATION LISTS ##
    # dynamically sized 
    
    # category to poi(s)
    let category_to_poi
    
    # name to poi position
    let name_to_vertex
    

    def __init__(self, roads: VecC[RawSeg?], pois: VecC[RawPOI?]):
        self.category_to_poi = AssociationList()
        self.name_to_vertex = AssociationList()
        self._map_init(roads, pois)
        
    # helper to init WUGraph 
    def _map_init(self, roads: VecC[RawSeg?], pois: VecC[RawPOI?]):
        
        # init size for graph and dicts (worst case): 
        # 2*number of roads (accounting for each end point) + 10 (arbitrary padding for safety)
        let size = 2*roads.len() + 10
        
        self.map = WUGraph(size)
        self.pos_to_vertex = HashTable(size, make_sbox_hash())
        self.vertex_to_pos = HashTable(size, make_sbox_hash())
        self.vertex_to_poi = HashTable(size, make_sbox_hash())
        
        
        
        # helper to init pos' in every dict
        # incrementing counter of vertices for initializing graph and dicts
        let next_vertex = 0
        def _add_pos(lat, long):
            let pos_key = _pos_to_key(lat, long)
            if not self.pos_to_vertex.mem?(pos_key):
                let vertex_key = str(next_vertex)
                self.pos_to_vertex.put(pos_key, next_vertex)
                self.vertex_to_pos.put(vertex_key, [lat, long])
                self.vertex_to_poi.put(vertex_key, None)
                next_vertex = next_vertex + 1
        
        # add road endpoints as positions
        for road in roads:
            _add_pos(road[0], road[1])
            _add_pos(road[2], road[3])
            
        # add edges and weights
        for road in roads:
            let vertex_1 = self.pos_to_vertex.get(_pos_to_key(road[0], road[1]))
            let vertex_2 = self.pos_to_vertex.get(_pos_to_key(road[2], road[3]))
            let weight = _distance(road[0], road[1], road[2], road[3])
            self.map.set_edge(vertex_1, vertex_2, weight)
            
        # pois 
        for p in pois:
            let category = p[2]
            let name = p[3]
            let vertex = self.pos_to_vertex.get(_pos_to_key(p[0], p[1]))
            let vertex_key = str(vertex)
            
            #separate chaining HashTable for multiple pois in one pos
            self.vertex_to_poi.put(vertex_key, cons(p, self.vertex_to_poi.get(vertex_key)))
            
            # add to association lists
            # dynamically add categories 
            if not self.category_to_poi.mem?(category):
                self.category_to_poi.put(category, None)
            self.category_to_poi.put(category, cons(p, self.category_to_poi.get(category)))
            self.name_to_vertex.put(name, vertex_key)
            
    def locate_all(self, dst_cat: Cat?) -> ListC[RawPos?]:
        # check destination
        pass
        
        
    def plan_route(self, src_lat: Lat?, src_lon:  Lon?, dst_name: Name?) -> ListC[RawPos?]:
        # Djikstra's 
         pass
         
    def find_nearby(self, src_lat: Lat?, src_lon:  Lon?, dst_cat:  Cat?, n: nat?) -> ListC[RawPOI?]: 
        pass   
#   ^ WRITE YOUR IMPLEMENTATION HERE


def my_first_example():
    return TripPlanner([[0,0, 0,1], [0,0, 1,0]],
                       [[0,0, "bar", "Ridgeville"],
                        [0,1, "food", "Kansaku"]])

test 'My first locate_all test':
    assert my_first_example().locate_all("food") == \
        cons([0,1], None)

test 'My first plan_route test':
   assert my_first_example().plan_route(0, 0, "Kansaku") == \
       cons([0,0], cons([0,1], None))

test 'My first find_nearby test':
    assert my_first_example().find_nearby(0, 0, "food", 1) == \
        cons([0,1, "food", "Kansaku"], None)
