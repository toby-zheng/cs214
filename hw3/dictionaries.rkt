#lang dssl2

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

    def __init__(self, nbuckets: nat?, hash: FunC[AnyC, nat?]):
        self._hash = hash
        pass
    #   ^ WRITE YOUR IMPLEMENTATION HERE

    # This avoids trying to print the hash function, since it's not really
    # printable and isn’t useful to see anyway:
    def __print__(self, print):
        print("#<object:HashTable  _hash=... _size=%p _data=%p>",
              self._size, self._data)

    # Other methods you may need can go here.
    def len(self):
        pass
        
    def mem?(self, key: K) -> bool?:
        pass
        
    def get(self, key: K) -> V:
        pass
        
    def put(self, key:K, value: V) -> NoneC:
        pass
        
    def del(self, key: K) -> NoneC:
        pass


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


def compose_phrasebook(d: DICT!) -> DICT?:
    pass
#   ^ WRITE YOUR IMPLEMENTATION HERE

test "AssociationList phrasebook":
    pass

test "HashTable phrasebook":
    pass