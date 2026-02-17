#lang dssl2
let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

# HW5: Binary Heap

interface PRIORITY_QUEUE[X]:
    # Returns the number of elements in the priority queue.
    def len(self) -> nat?
    # Returns the smallest element; error if empty.
    def find_min(self) -> X
    # Removes the smallest element; error if empty.
    def remove_min(self) -> NoneC
    # Inserts an element; error if full.
    def insert(self, element: X) -> NoneC

# Class implementing the PRIORITY_QUEUE ADT as a binary heap.
class BinHeap[X] (PRIORITY_QUEUE):
    let _data: VecC[OrC(X, NoneC)]
    let _size: nat?
    let _lt?:  FunC[X, X, bool?]

    # Constructs a new binary heap with the given capacity and
    # less-than function for type X.
    def __init__(self, capacity, lt?):
        self._data = vec(capacity)
        self._size = 0
        self._lt? = lt?
    #   ^ WRITE YOUR IMPLEMENTATION HERE
        
    def len(self):
        return self._size
        
    def find_min(self):
        if (self._size == 0):
            error('heap is empty')
        return self._data[0]
        
    def insert(self, element: X):
        if (self._size == self._data.len()):
            error('heap is full')
        
        self._data[self._size] = element
        self._bubble_up(self._size)
        self._size = self._size + 1
        
    def remove_min(self):
        if (self._size == 0):
            error('heap is empty')
        
        self._data[0] = self._data[self._size - 1]
        self._data[self._size - 1] = None
        self._size = self._size - 1
        
        self._percolate_down(0)
        
    def get_vector(self):
        return self._data

# Other methods you may need can go here.
        
    # Broken-out helpers for sorting heap, explicit logic
        
    def _parent(self, i: nat?):
        return (i - 1)//2
        
    def _left_child(self, i: nat?):
        return 2*i + 1
        
    def _right_child(self, i: nat?):
        return 2*i + 2
        
    def _swap_elements(self, i: nat?, j: nat?):
        let temp = self._data[j]
        self._data[j] = self._data[i]
        self._data[i] = temp
        
    def _bubble_up(self, i: nat?):
        while ((i != 0) and self._lt?(self._data[i], self._data[self._parent(i)])):
            let parent = self._parent(i)
            self._swap_elements(i, parent)
            i = parent
    
    # recursive percolate down
    def _percolate_down(self, i):
        let left_child = self._left_child(i)
        let right_child = self._right_child(i)
        
        let smallest = i
        
        # find smallest
        if ((left_child < self._size) and (self._lt?(self._data[left_child], self._data[smallest]))):
            smallest = left_child
        if ((right_child < self._size) and (self._lt?(self._data[right_child], self._data[smallest]))):
            smallest = right_child
        
        # swap then recursive call
        if smallest != i:
            self._swap_elements(i, smallest)
            self._percolate_down(smallest)


# Woefully insufficient test.
test 'insert, insert, remove_min':
    # The `nat?` here means our elements are restricted to `nat?`s.
    let h = BinHeap[nat?](10, λ x, y: x < y)
    h.insert(1)
    assert h.find_min() == 1
    
test 'len':
     let h = BinHeap[nat?](5, λ x, y: x < y)
     assert h.len() == 0
     h.insert(3)
     assert h.len() == 1
     h.insert(5)
     assert h.len() == 2
     h.remove_min()
     assert h.len() == 1
     
     
test 'find min':
     let h = BinHeap[nat?](5, λ x, y: x < y)
     h.insert(1)
     h.insert(5)
     h.insert(2)
     h.insert(3)
     
     assert h.get_vector() == [1, 3, 2, 5, None]
     assert h.find_min() == 1
     
test 'order after remove':
     let h = BinHeap[nat?](5, λ x, y: x < y)
     h.insert(1)
     h.insert(2)
     h.insert(3)
     h.insert(4)
     h.insert(5)
     h.remove_min()
     
     assert h.get_vector() == [2, 4, 3, 5, None]
     assert h.find_min() == 2
     h.remove_min()
     assert h.find_min() == 3
     h.remove_min()
     h.remove_min()
     h.remove_min()
     
     assert h.get_vector() == vec(5)
     assert h.len() == 0
     
test 'lt? = gt?':
    let h = BinHeap[nat?](5, λ x, y: x > y)
    h.insert(1)
    h.insert(100)
    h.insert(99)
    h.insert(10)
    assert h.get_vector() == [100, 10, 99, 1, None]
    assert h.find_min() == 100
    h.remove_min()
    assert h.find_min() == 99
    
test 'dupe values':
    let h = BinHeap[nat?](5, λ x, y: x < y)
    h.insert(1)
    h.insert(30)
    h.insert(1)
    h.insert(2)
    
    assert h.get_vector() == [1, 2, 1, 30, None]
    
    assert h.find_min() == 1
    h.remove_min()
    assert h.find_min() == 1
    h.remove_min()
    assert h.find_min() == 2
     
test 'find/remove while empty':
    let h = BinHeap[nat?](5, λ x, y: x < y)
    assert_error h.remove_min()
    assert_error h.find_min()
    
test 'insert to full':
    let h = BinHeap[nat?](1, λ x, y: x < y)
    h.insert(100)
    assert_error h.insert(1)
    assert h.get_vector() == [100]
    assert h.find_min() == 100
    
    

# Sorts a vector of Xs, given a less-than function for Xs.
#
# This function performs a heap sort by inserting all of the
# elements of v into a fresh heap, then removing them in
# order and placing them back in v.
def heap_sort[X](v: VecC[X], lt?: FunC[X, X, bool?]) -> NoneC:
    let h = BinHeap[X](v.len(), lt?)
    
    # insert in heap
    for i in v:
        h.insert(i)
    
    # remove off heap
    for i in range(v.len()):
        v[i] = h.find_min()
        h.remove_min()
#   ^ WRITE YOUR IMPLEMENTATION HERE

test 'heap sort descending':
    let v = [3, 6, 0, 2, 1]
    heap_sort(v, λ x, y: x > y)
    assert v == [6, 3, 2, 1, 0]

test 'heap sort ascending':
    let v = [3, 6, 0, 2,1]
    heap_sort(v, lambda x, y: x < y)
    assert v == [0, 1, 2, 3, 6]
    
test 'no change':
    let v = [0, 1, 2, 3, 6]
    heap_sort(v, lambda x, y: x < y)
    assert v == [0, 1, 2, 3, 6]
    
test 'dupes':
    let v = [1, 2, 3, 1, 6]
    heap_sort(v, lambda x, y: x < y)
    assert v == [1, 1, 2, 3, 6]
    
    

# Sorting colleges

struct college:
    let name: str?
    # Where is the college located? Can be "rural", "urban" or "suburban".
    let environment: str?
    # Average salary of graduates five years after graduation.
    let salary: int?
    # Average yearly tuition.
    let tuition: int?
    # Average SAT score of last incoming freshling class: between 400 and 1600.
    let sat: int?
    # Average GPA of last incoming freshling class: between 0.0 and 4.0.
    let gpa: num?
    # Number of full-time students attending the school as of last fall.
    let students: int?
    # Student-to-faculty ratio. E.g., 7000 students and 1000 faculty => 7
    let stf_ratio: num?
    # Acceptance rate. 0.0 = accepts no one. 1.0 = accepts everyone.
    let acceptance: num?

let sample_colleges = \
  [college("Pikachu College", "urban", 70000, 30000, 1500, 3.8, 4000, 8, 0.22),
   college("Vulpix University", "rural", 100000, 70000, 1550, 4.0, 1000, 2, 0.01),
   college("Jigglypuff University", "suburban", 70000, 50000, 1530, 3.9, 8500, 6, 0.07),
   college("Ekans College", "suburban", 38000, 6000, 1410, 3.9, 1500, 9, 0.39),
   college("Bulbasaur University","rural", 54000, 10000, 1360, 3.6, 500, 13, 0.53),
   college("Togepi University", "rural", 58000, 40000, 1400, 3.7, 5000, 8, 0.44)
   ]

# Is `a` a better college than `b`?
# You decide what makes a college better than another, and you can use any
# or all of the information you have about each college to determine that.
def is_better?(a: college?, b: college?) -> bool?:
    # helper to give give colleges scores to compare (depending on various factors)
    def score(c: college?) -> num?:
        let score = 0
        
        # location needs condition for each, prefer urban
        if c.environment == "urban":
            score = 20
        elif c.environment == "suburban":
            score = 10
        elif c.environment == "rural":
            score = 5
        
        # salary and tuition matter most
        score = score + c.salary/1000
        score = score - c.tuition/1000
        
        # these matter but less
        score = score + 10*c.sat/1600
        score = score + 10*c.students/10000
        
        # lower stf ratio = better
        score = score - c.stf_ratio
        return score
        
    return score(a) > score(b)
        
    
#   ^ WRITE YOUR IMPLEMENTATION HERE

# Rank the sample colleges above, in order from "best" to "worst".
def rank_colleges() -> VecC[college?]:
    let v = sample_colleges
    heap_sort(v, is_better?)
    return v
    
#   ^ WRITE YOUR IMPLEMENTATION HERE