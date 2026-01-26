#lang dssl2
let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]
# HW3: Dictionaries

import sbox_hash

# A signature for the dictionary ADT. The contract parameters `K` and
# `V` are the key and value types of the dictionary, respectively.
interface DICT[K, V]:
    # Returns the number of key-value pairs in the dictionary.
    def len(self) -> nat?
    # Is the given key mapped by the dictionary?
    # Notation: `key` is the name of the parameter. `K` is its contract.
    def mem?(self, key: K) -> bool?
    # Gets the value associated with the given key; calls `error` if the
    # key is not present.
    def get(self, key: K) -> V
    # Modifies the dictionary to associate the given key and value. If the
    # key already exists, its value is replaced.
    def put(self, key: K, value: V) -> NoneC
    # Modifes the dictionary by deleting the association of the given key.
    def del(self, key: K) -> NoneC
    # The following method allows dictionaries to be printed
    def __print__(self, print)


class AssociationList[K, V] (DICT):

    let _head
    let _size
    #   ^ ADDITIONAL FIELDS HERE

    def __init__(self):
        self._head = None
        self._size = 0

    # See above.
    def __print__(self, print):
        print("#<object:AssociationList head=%p>", self._head)

    # Other methods you may need can go here.
    def len(self) -> nat?:
        # len must be O(1), save length value instead of traversal
        return self._size
        
    def mem?(self, key: K) -> bool?:
        let node = self._head
        while (node != None):
            if node[0] == key:
                return True
            node = node[2]
        return False
    
    def get(self, key: K) -> V:
        let node = self._head
        while (node != None):
            if node[0] == key: 
                return node[1]
            node = node[2]
        error('key not found')
        
        
    def put(self, key: K, value: V) -> NoneC:
        let node = self._head
        while (node != None):
            # existing key
            if node[0] == key:
                node[1] = value
                return None
            node = node[2]
         
        # new node
        self._head = [key, value, self._head]
        self._size = self._size + 1
        return None
            
    
    def del(self, key: K) -> NoneC:
        let node = self._head
        let last_node = None
        
        while (node != None):
            if node[0] == key:
                
                # head
                if last_node == None:
                    self._head = node[2]  
                #other nodes
                else:
                    let next = node[2]
                    last_node[2] = next
                
                # length update
                self._size = self._size -1
                return None    
                
            last_node = node    
            node = node[2]
            
        return None


test 'yOu nEeD MorE tEsTs':
    let a = AssociationList()
    assert not a.mem?('hello')
    a.put('hello', 5)
    assert a.len() == 1
    assert a.mem?('hello')
    assert a.get('hello') == 5  

test 'length of empty dict':
    let d = AssociationList()
    assert d.len() == 0

test 'empty dict get':
    let d = AssociationList()
    assert_error d.get('Hi')

test 'delete key-value pair length 1':
    let d = AssociationList()
    d.put('hi', 'world')
    assert d.len() == 1
    d.del('hi')
    assert d.len() == 0
    assert_error d.get('hi')
    
test 'delete head':
    let d = AssociationList()
    d.put('lala', 'dida')
    d.put('hi', 'world')
    assert d.len() == 2
    d.del('hi')
    assert d.len() == 1
    assert_error d.get('hi')
    assert d.mem?('hi') == False
    assert d.get('lala') == 'dida'
    
test 'delete non-head key-value':
    let d = AssociationList()
    d.put('hey', 'everybody')
    d.put('lala', 'dida')
    d.put('hi', 'world')
    assert d.len() == 3
    d.del('lala')
    assert d.len() == 2
    assert_error d.get('lala')
    assert d.mem?('lala') == False
    assert d.get('hi') == 'world'
    assert d.get('hey') == 'everybody'
    
test 'update key':
    let d = AssociationList()
    d.put('lala', 'dida')
    assert d.get('lala') == 'dida'
    d.put('lala', 'deedee')
    assert d.len() == 1
    assert d.get('lala') == 'deedee'
    
test 'delete missing key':
    let d = AssociationList()
    d.put('hi', 'world')
    d.del('hello')
    assert d.len() == 1
    assert d.get('hi') == 'world'
    
test 'multiple deletes':
    let d = AssociationList()
    d.put('hi', 1)
    d.del('hi')
    assert d.len() == 0
    d.del('hi')
    assert d.len() == 0
    
    
class HashTable[K, V] (DICT):
    let _hash
    let _size
    let _data
    # keep track of number of buckets to use for indexing
    let _nbuckets

    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash
        self._size = 0
        self._data = vec(nbuckets)
        self._nbuckets = nbuckets
    #   ^ WRITE YOUR IMPLEMENTATION HERE

    # This avoids trying to print the hash function, since it's not really
    # printable and isn’t useful to see anyway:
    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)

    # Other methods you may need can go here.
    # helper to get the bucket index (ensures fit to size n)
    def _index(self, key: K) -> nat?:
        return (self._hash(key) % self._nbuckets)
        
    def len(self):
        return self._size
        
    def mem?(self, key: K) -> bool?:
        let index = self._index(key)
        let bucket = self._data[index]
        
        while bucket != None:
            if key == bucket[0]:
                return True
            bucket = bucket[2]
        return False
        
    def get(self, key: K) -> V:
        let index = self._index(key)
        let bucket = self._data[index]
        
        while bucket != None:
            if key == bucket[0]:
                return bucket[1]
            bucket = bucket[2]
        error('key not found')
        
    def put(self, key:K, value: V) -> NoneC:
        let index = self._index(key)
        let bucket = self._data[index]
        
        # existing key -> update value
        while bucket != None:
            if bucket[0] == key:
                bucket[1] = value
                return None
            bucket = bucket[2]
        
        # new entry
        self._data[index] = [key, value, self._data[index]]
        self._size = self._size + 1
        return None
                
            
            
        
    def del(self, key: K) -> NoneC:
        let index = self._index(key)
        let bucket = self._data[index]
        let prev_bucket = None
        
        while bucket != None:
            if bucket[0] == key:
                # head of bucket
                if prev_bucket == None:
                    self._data[index] = bucket[2]
                # other nodes
                else:
                    prev_bucket[2] = bucket[2]
                self._size = self._size - 1
                return None
            prev_bucket = bucket
            bucket = bucket[2]
        
        return None
        

# first_char_hasher(String) -> Natural
# A simple and bad hash function that just returns the ASCII code
# of the first character.
# Useful for debugging because it's easily predictable.
def first_char_hasher(s: str?) -> int?:
    if s.len() == 0:
        return 0
    else:
        return int(s[0])

test 'yOu nEeD MorE tEsTs, part 2':
    let h = HashTable(10, make_sbox_hash())
    assert not h.mem?('hello')
    h.put('hello', 5)
    assert h.len() == 1
    assert h.mem?('hello')
    assert h.get('hello') == 5

test 'empty dict get':
    let h = HashTable(10, first_char_hasher)
    assert h.len() == 0

test 'delete key-value pair length 1':
    let h = HashTable(10, first_char_hasher)
    h.put('hi', 'world')
    assert h.len() == 1
    h.del('hi')
    assert h.len() == 0
    assert_error h.get('hi')
    
test 'delete in other bucket':
    let h = HashTable(10, first_char_hasher)
    h.put('a', 'hello')
    h.put('b', 'bye')
    h.put('c', 'aloha')
    assert h.len() == 3
    h.del('b')
    assert_error h.get('b')
    assert h.mem?('b') == False
    assert h.get('a') == 'hello'
    assert h.get('c') == 'aloha'
    
test 'update key':
    let h = HashTable(10, first_char_hasher)
    h.put('a', 'hello')
    h.put('al', 'hi')
    assert h.get('a') == 'hello'
    h.put('a', 'bye')
    assert h.get('a') == 'bye'
    assert h.len() == 2

test 'delete missing entry':
    let h = HashTable(10, first_char_hasher)
    h.put('hi', 'world')
    h.del('hello')
    assert h.len() == 1
    assert h.mem?('hello') == False
    

    


# hashtable dict implementation specific tests, testing collisions (same bucket)
test 'delete head':
    let h = HashTable(10, first_char_hasher)
    h.put('hi', 'world')
    h.put('hello', 'grader')
    assert h.len() == 2
    h.del('hello')
    assert h.len() == 1
    assert_error h.get('hello')
    assert h.mem?('hello') == False
    assert h.get('hi') == 'world'

test 'delete middle':
    let h = HashTable(10, first_char_hasher)
    h.put('a', 1)
    h.put('apple', 2)
    h.put('arsenal', 3)
    h.del('apple')
    assert h.len() == 2
    assert h.mem?('apple') == False
    assert h.get('a') == 1
    assert h.get('arsenal') == 3

test '1 bucket':
    let h = HashTable(1, first_char_hasher)
    h.put('a', 1)
    h.put('b', 2)
    h.put('c', 3)
    h.put('d', 4)
    assert h.len() == 4
    h.del('c')
    assert h.len() == 3
    assert h.mem?('c') == False

# test w/ sbox_hash
test 'mixed types collision test':
    let h = HashTable(1, make_sbox_hash())
    h.put('hello', 1)
    h.put(42, 'answer')
    h.put(True, 'bool')
    h.put([1,2,3], 'vec')
    assert h.len() == 4
    assert h.get('hello') == 1
    assert h.get(42) == 'answer'
    assert h.get(True) == 'bool'
    assert h.get([1,2,3]) == 'vec'
    h.del(42)
    assert h.len() == 3
    assert_error h.get(42)


test 'mixed operations with sbox hash':
    let h = HashTable(16, make_sbox_hash())
    
    h.put('x', '1')
    h.put('y', '2')
    assert h.get('x') == '1'
    assert h.len() == 2
    h.del('x')
    assert h.len() == 1
    assert_error h.get('x')
    h.put('z', '3')
    assert h.get('z') == '3'
    h.put('y', '20')
    assert h.get('y') == '20'

test 'multiple puts':
    let h = HashTable(10, make_sbox_hash())
    h.put('a', 1)
    h.put('a', 2)
    h.put('a', 3)
    assert h.len() == 1
    assert h.get('a') == 3

# test 'for fun':
    # let h = HashTable(10, make_sbox_hash())
    # h.put('a', 1)
    # h.put('a', 2)
    # h.put('eight_principles', 3)
    # assert h.len() == 2
    # assert h.get('a') == 2
    # assert h.get('eight_principles') == 3

def compose_phrasebook(d: DICT!) -> DICT?:
    d.put('Unjani?', ['How are you?', 'oon-jah-nee?'])
    d.put('Qaphela!', ['Be careful!', 'kah-peh-lah!'])
    d.put('Uxolo', ['Sorry/Excuse Me', 'oo-xo-loh'])
    d.put('Kuphi?', ['Where is it?', 'koo-pee'])
    d.put('Angiqondi', ["I don't understand", 'ahn-gee-kohn-dee'])
    return d
    
#   ^ WRITE YOUR IMPLEMENTATION HERE
def get_pronounciation(d: DICT!, key: str?) -> str?:
    return d.get(key)[1]
test "AssociationList phrasebook":
    let a = AssociationList()
    let phrasebook = compose_phrasebook(a)
    assert get_pronounciation(phrasebook, 'Unjani?') == 'oon-jah-nee?'

test "HashTable phrasebook":
    let h = HashTable(5, first_char_hasher)
    let phrasebook = compose_phrasebook(h)
    assert get_pronounciation(phrasebook, 'Unjani?') == 'oon-jah-nee?'

test "HashTable phrasebook w/ ":
    let h = HashTable(5, make_sbox_hash())
    let phrasebook = compose_phrasebook(h)
    assert get_pronounciation(phrasebook, 'Unjani?') == 'oon-jah-nee?'