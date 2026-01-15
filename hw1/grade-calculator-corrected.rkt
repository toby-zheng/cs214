#lang dssl2
let eight_principles = ["Know your rights.",
"Acknowledge your sources.",
"Protect your work.",
"Avoid suspicion.",
"Do your own work.",
"Never falsify a record or permit another person to do so.",
"Never fabricate data, citations, or experimental results.",
"Always tell the truth when discussing your work with your instructor."]
# HW1: Grade Calculator

###
### Data Definitions
###

struct homework:
    let n_passed_test_suites: int?
    let self_eval_percentage: num?
    let mutation_percentage:  OrC(num?, NoneC) # no mutation testing for hw1

struct project:
    let n_passed_test_suites:      int?
    let design_docs_satisfactory?: VecKC[bool?, bool?, bool?]

let track_grades  = ["F","D","C","B","A"]
let letter_grades = ["F","D","D+","C-","C","C+","B-","B","B+","A-","A"]

# We will see this function again in the complexity lecture; stay tuned!
def linear_search (elements: VecC[AnyC], target):
    for x in elements:
        if x == target: return True
    return False
def track_grade?  (str): return linear_search(track_grades,  str)
def letter_grade? (str): return linear_search(letter_grades, str)

###
### Tracks
###

def integration_grade(project_score: int?) -> track_grade?:
    if ((project_score > 6) or (project_score < 0)): error('score out of range')
    if project_score == 6: return 'A'
    if project_score >= 4: return 'B'
    if project_score == 3: return 'C'
    if project_score == 2: return 'D'
    else: return 'F'

test 'first integration_grade test; you will need to add more':
    assert integration_grade(0) == 'F'
    assert integration_grade(1) == 'F'
    assert integration_grade(2) == 'D'
    assert integration_grade(3) == 'C'
    assert integration_grade(4) == 'B'
    assert integration_grade(5) == 'B'
    assert integration_grade(6) == 'A'
    
test 'score out of range test':
    assert_error integration_grade(7) 
    assert_error integration_grade(-1)
    

def implementation_grade(homework_scores: VecC[int?]) -> track_grade?:
    if (homework_scores.len() != 5): error('incorrect number of assignments')
    let total_score = 0
    for score in homework_scores:
        if ((score > 4) or (score < 0)): error('score out of range')
        total_score = total_score + score

    if total_score == 20: return 'A'
    if total_score >= 16: return 'B'
    if total_score >= 12: return 'C'
    if total_score >=10: return 'D'
    else: return 'F'
    

test 'first implementation_grade test; you will need to add more':
    assert implementation_grade([0,0,0,0,0]) == 'F'
    assert implementation_grade([4, 4, 2, 0, 0]) == 'D'
    assert implementation_grade([4, 4, 4, 0, 0]) == 'C'
    assert implementation_grade([4, 4, 4, 4, 0]) == 'B'
    assert implementation_grade([4, 4, 4, 4, 4]) == 'A'

test 'incorrect number of assignments test':
    assert_error implementation_grade([0])

test 'score out of range':
    assert_error implementation_grade([-1, 0, 0, 0, 4])

# helper
def __exam_point(exam_score: num?) -> int?:
    if ((exam_score > 1) or (exam_score < 0)): error('score out of range')
    if exam_score >=.85: return 4
    if exam_score >=.7: return 3
    if exam_score >=.55: return 2
    if exam_score >= .35: return 1
    else: return 0


def exams_theory_points(exam1_score: num?, exam2_score: num?) -> int?:
    let exam1_points = __exam_point(exam1_score)
    let exam2_points = __exam_point(exam2_score)
    return exam1_points + exam2_points



test 'first exams_theory_points test; you will need to add more':
    assert exams_theory_points(0.95, 0.86) == 8
    assert exams_theory_points(0.65, 0.86) == 6
    assert exams_theory_points(0.55, 0.55) == 4
    assert exams_theory_points(0.35, 0) == 1
    

test 'exams score out of range':
    assert_error exams_theory_points(1.1, .4)
    assert_error exams_theory_points(-0.5, .4)

def theory_grade(theory_points: int?) -> track_grade?:
    if theory_points == 12: return 'A'
    if theory_points >= 10: return 'B'
    if theory_points >= 8:  return 'C'
    if theory_points >= 7:  return 'D'
    else:                   return 'F'
    
test 'theory_grade':
    assert theory_grade(6) == 'F'
    assert theory_grade(7) == 'D'
    assert theory_grade(8) == 'C'
    assert theory_grade(10) == 'B'
    assert theory_grade(12) == 'A'

def tally_design_points(assignments: VecC[AnyC],
                        expected_n_assignments: int?,
                        counts?: FunC[AnyC, bool?]) -> int?:
    if assignments.len() != expected_n_assignments: error('incorrect number of assignments')
    let tally = 0
    for curr_assignment in assignments:
        if counts?(curr_assignment): tally = tally + 1
    return tally

# helper
def __design_score_check(score: num?) -> bool?:
    if score >= 0.5: return True
    else: return False
    
def self_evals_design_points(self_eval_scores: VecC[num?]) -> int?:
    return tally_design_points(self_eval_scores, 5, __design_score_check)

test 'self_eval test':
    assert self_evals_design_points([1, 1, 0, 1, 1]) == 4

test 'self_eval error test':
    assert_error self_evals_design_points([1, 0, 1, 1])

def mutation_testing_design_points(mutation_scores: VecC[num?]) -> int?:
    return tally_design_points(mutation_scores, 4, __design_score_check)

test 'first mutation_testing_design_points test; you will need to add more':
    assert mutation_testing_design_points([0.3, 0.6, 0.8, 1.0]) == 3
    assert mutation_testing_design_points([0.3, 0.1, 0.1, 0.4]) == 0
    assert mutation_testing_design_points([0.5, 0.5, 0.5, 0.5]) == 4

test 'mutation_testing error test':
    assert_error mutation_testing_design_points([1])
    
# helper
def __design_bool_check(result: bool?) -> bool?:
    return result

def design_docs_design_points(design_docs_scores: VecC[bool?]) -> int?:
    return tally_design_points(design_docs_scores, 3, __design_bool_check)

test 'design_docs test':
    assert design_docs_design_points([True, False, False]) == 1
    assert design_docs_design_points([True, True, True]) == 3

test 'design_docs error test':
    assert_error design_docs_design_points([True])

def design_grade(design_points: int?) -> track_grade?:
    if design_points >= 11: return 'A'
    if design_points >= 9:  return 'B'
    if design_points >= 8:  return 'C'
    if design_points >= 7:  return 'D'
    else:                   return 'F'
    
test 'design_grade test':
    assert design_grade(6) == 'F'
    assert design_grade(7) == 'D'
    assert design_grade(8) == 'C'
    assert design_grade(9) == 'B'
    assert design_grade(11) == 'A'

###
### Final Grades
###

def index_of (elt: AnyC, v: VecC[AnyC]) -> int?:
    for i, x in v:
        if elt == x: return i
    error('element not found: %p', elt)

# Returns `True` if grade `g1` is less than grade `g2`; otherwise `False`.
# This function is a *custom comparator*. We will see those again in the
# sorting lecture.
def grade_lt (g1: letter_grade?, g2: letter_grade?) -> bool?:
    return index_of(g1, letter_grades) < index_of(g2, letter_grades)

let TracksC = VecKC[track_grade?, track_grade?, track_grade?, track_grade?]

def base_grade (tracks: TracksC) -> letter_grade?:
    let lowest_grade = tracks[0]
    for grade in tracks:
        if grade_lt(grade, lowest_grade): lowest_grade = grade
        
    return lowest_grade

test 'base_grade test':
    assert base_grade(['A', 'A', 'B', 'C']) == 'C'
    assert base_grade(['A', 'A', 'A', 'A']) == 'A'
    assert base_grade(['A', 'A', 'C', 'C']) == 'C'
    assert_error base_grade(['A'])
    
def n_above_expectations (tracks: TracksC) -> int?:
    let base = base_grade(tracks)
    let n = 0
    for grade in tracks:
        if grade_lt(base, grade): n = n + 1
    return n

test 'n_above_expectations test':
    assert n_above_expectations(['A', 'A', 'B', 'C']) == 3
    assert n_above_expectations(['A', 'A', 'A', 'A']) == 0
    assert n_above_expectations(['A', 'A', 'C', 'C']) == 2

def final_grade (base_grade: track_grade?,
                 n_above_expectations: int?) -> letter_grade?:
    if base_grade == 'F': return 'F'
    if base_grade == 'A': return 'A'
    
    let base_index = index_of(base_grade, letter_grades)
    let final_index = base_index + n_above_expectations
    
    let result = letter_grades[final_index]
    if result == 'D+': return 'D'
    
    return result
    
test 'final_grade test':
    assert final_grade('C', 2) == 'B-'
    assert final_grade('C', 0) == 'C'
    
test 'final_grade special cases':
    assert final_grade('D', 1) == 'D'
    assert final_grade('F', 3) == 'F'
    assert final_grade('B', 3) == 'A'
    assert final_grade('A', 3) == 'A'


###
### Students
###

class Student:
    let name: str?
    let homeworks: VecKC[homework?, homework?, homework?, homework?, homework?]
    let project: project?
    let worksheet_scores: VecKC[num?, num?, num?, num?]
    let exam_scores: VecKC[num?, num?]

    def __init__ (self, name, homeworks, project, worksheet_scores, exam_scores):
        self.name = name
        self.homeworks = homeworks
        self.project = project
        self.worksheet_scores = worksheet_scores
        self.exam_scores = exam_scores
        
    def get_homework_grades(self) -> VecC[int?]:
        return [hw.n_passed_test_suites for hw in self.homeworks]

    def get_project_grade(self) -> int?:
        return self.project.n_passed_test_suites

    def resubmit_homework (self, n: int?, new_grade: int?) -> NoneC:
        if n < 1 or n > 5: error('no such homework')
        let index = n-1
        if new_grade > self.homeworks[index].n_passed_test_suites: self.homeworks[index].n_passed_test_suites = new_grade

    def resubmit_project (self, new_grade: int?) -> NoneC:
        if new_grade > self.project.n_passed_test_suites: self.project.n_passed_test_suites = new_grade
        

    # Determine a student's final letter grade from their body of work in the
    # class (i.e., the fields) using the helper functions you wrote earlier.
    def letter_grade (self) -> letter_grade?:
        let implementation = implementation_grade(self.get_homework_grades())
        let integration = integration_grade(self.project.n_passed_test_suites)
        # Theory grade
        let worksheets = 0
        for w in self.worksheet_scores:
            if w == 1.0: worksheets = worksheets + 1
        let exams = exams_theory_points(self.exam_scores[0], self.exam_scores[1])
        let theory = theory_grade(worksheets + exams)
        # Design grade
        let self_evals = [h.self_eval_percentage for h in self.homeworks]
        let self_eval_points = self_evals_design_points(self_evals)
        let mutation = [h.mutation_percentage for h in self.homeworks
                        if h.mutation_percentage is not None]
        let mutation_points = mutation_testing_design_points(mutation)
        let design_docs = self.project.design_docs_satisfactory?
        let doc_points = design_docs_design_points(design_docs)
        let design_points = self_eval_points + mutation_points + doc_points
        let design = design_grade(design_points)
        # Final grade
        let tracks = [implementation, integration, theory, design]
        let base = base_grade(tracks)
        let above = n_above_expectations(tracks)
        return final_grade(base, above)

###
### Another paltry couple tests
###

test 'Student#letter_grade, worst case scenario':
    let s = Student('Everyone, right now',
                    [homework(0, 0.0, None),
                     homework(0, 0.0, 0.0),
                     homework(0, 0.0, 0.0),
                     homework(0, 0.0, 0.0),
                     homework(0, 0.0, 0.0)],
                    project(0, [False, False, False]),
                    [0.0, 0.0, 0.0, 0.0],
                    [0.0, 0.0])
    assert s.letter_grade() == 'F'

test 'Student#letter_grade, best case scenario':
    let s = Student("You, if you work harder than you've ever worked",
                    [homework(4, 1.0, None),
                     homework(4, 1.0, 1.0),
                     homework(4, 1.0, 1.0),
                     homework(4, 1.0, 1.0),
                     homework(4, 1.0, 1.0)],
                    project(6, [True, True, True]),
                    [1.0, 1.0, 1.0, 1.0],
                    [1.0, 1.0])
    assert s.letter_grade() == 'A'

test 'Student#letter_grade, B+':
    let s = Student("B_student",
                    [homework(4, 1.0, None),
                     homework(4, 1.0, 1.0),
                     homework(4, 1.0, 1.0),
                     homework(4, 1.0, 1.0),
                     homework(3, 1.0, 1.0)],
                     project(5, [True, True, True]),
                     [1.0, 1.0, 1.0, 1.0],
                     [.80, 1.0])
    assert s.letter_grade() == 'B+'

test 'Student#letter_grade edge case':
    let s = Student("edge",
        [homework(2,0.5,None),
         homework(2,0.5,0.5),
         homework(2,0.5,0.5),
         homework(2,0.5,0.5),
         homework(2,0.5,0.5)],
        project(3,[True,False,False]),
        [1.0,0.0,1.0,0.0],
        [0.7,0.7])
    assert s.letter_grade() == 'C'
           
test 'get_homework_grades test':
    let s = Student("edge",
        [homework(2,0.5,None),
         homework(2,0.5,0.5),
         homework(2,0.5,0.5),
         homework(2,0.5,0.5),
         homework(2,0.5,0.5)],
        project(3,[True,False,False]),
        [1.0,0.0,1.0,0.0],
        [0.7,0.7])
    assert s.get_homework_grades() == [2,2,2,2,2]
    
test 'get_project_grade test':
   let s = Student("edge",
        [homework(2,0.5,None),
         homework(2,0.5,0.5),
         homework(2,0.5,0.5),
         homework(2,0.5,0.5),
         homework(2,0.5,0.5)],
        project(3,[True,False,False]),
        [1.0,0.0,1.0,0.0],
        [0.7,0.7])
   assert s.get_project_grade() == 3
    
test 'resubmit_homework test':
    let s = Student('resub',
        [homework(1,1.0,None),
         homework(1,1.0,None),
         homework(1,1.0,None),
         homework(1,1.0,None),
         homework(1,1.0,None)],
        project(3,[True,True,True]),
        [1.0,1.0,1.0,1.0],
        [0.8,0.8])

    s.resubmit_homework(1, 3)
    assert s.get_homework_grades()[0] == 3
    s.resubmit_homework(1,2)
    assert s.get_homework_grades()[0] == 3

test 'resubmit_project test':
    let s = Student('resub',
        [homework(1,1.0,None),
         homework(1,1.0,None),
         homework(1,1.0,None),
         homework(1,1.0,None),
         homework(1,1.0,None)],
        project(1,[True,True,True]),
        [1.0,1.0,1.0,1.0],
        [0.8,0.8])

    s.resubmit_project(3)
    assert s.get_project_grade() == 3
    s.resubmit_project(2)
    assert s.get_project_grade() == 3