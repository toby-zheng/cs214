#lang dssl2

# HW2: Stacks and Queues

let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]

import ring_buffer

interface STACK[T]:
    def push(self, element: T) -> NoneC
    def pop(self) -> T
    def empty?(self) -> bool?

# Defined in the `ring_buffer` library; copied here for reference.
# Do not uncomment! or you'll get errors.
# interface QUEUE[T]:
#     def enqueue(self, element: T) -> NoneC
#     def dequeue(self) -> T
#     def empty?(self) -> bool?

# Linked-list node struct (implementation detail):
struct _cons:
    let data
    let next: OrC(_cons?, NoneC)

###
### ListStack
###

class ListStack[T] (STACK):
    
    # Any fields you may need can go here.
    let head
    
    # Constructs an empty ListStack.
    def __init__ (self):
        self.head = None

    # Other methods you may need can go here.

    def push(self, element: T) -> NoneC:
        self.head = _cons(element, self.head)

    def pop(self) -> T:
        if self.head == None: error('empty stack')
        let value = self.head.data
        self.head = self.head.next
        return value
        
    def empty?(self) -> bool?:
        return (self.head == None)
    

test "woefully insufficient":
    let s = ListStack()
    s.push(2)
    assert not s.empty?()
    assert s.pop() == 2
    assert s.empty?()

test "empty stack error":
    let s = ListStack()
    assert_error s.pop()

test "LIFO behavior":
    let s = ListStack()
    s.push(1)
    s.push(2)
    s.push(3)
    assert s.pop() == 3
    assert s.pop() == 2
    assert s.pop() == 1
    assert s.empty?()

test "pop after empty":
    let s = ListStack()
    s.push(1)
    s.pop()
    assert_error s.pop()
    
test "mixed pushes and pops":
    let s = ListStack()
    s.push(1)
    s.push(2)
    assert s.pop() == 2
    s.push(3)
    assert s.pop() == 3
    assert s.pop() == 1
    assert s.empty?()

test "non-integer test":
    let s = ListStack()
    s.push('a')
    assert s.pop() == 'a'
    s.push('b')
    assert not s.empty?()
    assert s.pop() == 'b'
    

    
    



###
### ListQueue
###

class ListQueue[T] (QUEUE):

    # Any fields you may need can go here.
    let head
    let tail

    # Constructs an empty ListQueue.
    def __init__ (self):
        self.head = None
        self.tail = None

    # Other methods you may need can go here.
    def enqueue(self, element: T) -> NoneC:
        let node = _cons(element, None)
        
        # empty queue
        if self.head == None: 
            self.head = node
            self.tail = node
        else: 
            self.tail.next = node
            self.tail = node
        
    def dequeue(self) -> T:
        # dequeue on empty error
        if self.head == None:
            error('empty queue')
            
        let value = self.head.data
        self.head = self.head.next
        
        # if queue becomes empty, tail also none
        if self.head == None: self.tail = None
        
        return value
        
    def empty?(self) -> bool?:
        return (self.head == None)

test "woefully insufficient, part 2":
    let q = ListQueue()
    q.enqueue(2)
    assert q.dequeue() == 2
    assert q.empty?() == True
    
test "empty queue error":
    let q = ListQueue()
    assert_error q.dequeue()
    
test "FIFO behavior":
    let q = ListQueue()
    q.enqueue(1)
    q.enqueue(2)
    assert q.dequeue() == 1
    q.enqueue(3)
    assert q.dequeue() == 2
    assert q.dequeue() == 3
    assert q.empty?() == True

test "dequeue after empty":
    let q = ListQueue()
    q.enqueue(1)
    q.dequeue()
    assert_error q.dequeue()
    
test "non-integer":
    let q = ListQueue()
    q.enqueue('a')
    q.enqueue('b')
    assert q.dequeue() == 'a'
    assert q.dequeue() == 'b'
    assert q.empty?() == True
    

###
### Playlists
###

struct song:
    let title: str?
    let artist: str?
    let album: str?

# Enqueue five songs of your choice to the given queue, then return the first
# song that should play.
def fill_playlist (q: QUEUE!):
    let song0 = song("How to Save a Life", "The Fray", "The Fray")
    let song1 = song("Hikaru Nara", "Goose house", "Milk")
    let song2 = song("Sirivennela", "Anurag Kulakarni", "Shyam Singha Roy")
    let song3 = song("APT.", "ROSÉ, Bruno Mars", "APT.")
    let song4 = song("He Lei Pāpahi No Lilo a me Stitch", "Mark Keali’i Ho’omalu", "Lilo & Stitch")

    q.enqueue(song0)
    q.enqueue(song1)
    q.enqueue(song2)
    q.enqueue(song3)
    q.enqueue(song4)
    return q.dequeue()
#   ^ WRITE YOUR IMPLEMENTATION HERE

test "ListQueue playlist":
    let q = ListQueue()
    let first = fill_playlist(q)
    
    assert first.title == "How to Save a Life"
    assert first.artist == "The Fray"
    assert first.album == "The Fray"
    
    let next = q.dequeue()
    assert next.title == "Hikaru Nara"

# To construct a RingBuffer: RingBuffer(capacity)
test "RingBuffer playlist":
    let r = RingBuffer(5)
    let first = fill_playlist(r)
    
    assert first.title == "How to Save a Life"
    assert first.artist == "The Fray"
    assert first.album == "The Fray"
    
    let next = r.dequeue()
    assert next.title == "Hikaru Nara"
