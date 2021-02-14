/* You can run program by calling query -> run([List],K).
Also I added example queries for testing at the bottom of the page. 
*/

/* Check the given A is the same with H otherwisedo the same thing with tail of list until list became empty.*/
list_member(A,[A|_]).
list_member(A,[_|B]):-
    list_member(A,B).
/* Append the element A to the Head of list if element not already one of the member of list.Like set */
list_append(A,T,T):-
    list_member(A,T),!.
list_append(A,Tail,[A|Tail]).
list_append(A,[],T):-
    list_append(A,[A|T],T).
/*  Add element even if it is already in it */
list_add(A,[],[A]).
list_add(A,Tail,[A|Tail]).
list_add(A,[],T):-
    list_add(A,[A|T],T).
/*  count the number of given element in list */
count(_,[],0).
count(A,[A|Tail],N) :- count(A,Tail,N2), N is 1+N2.
count(A,[_|Tail],N) :- count(A,Tail,N2), N is N2.
/* remove all occurences of given element from given list */
removeAll(_, [], []).
removeAll(X, [X|T], L):- removeAll(X, T, L), !.
removeAll(X, [H|T], [H|L]):- removeAll(X, T, L ).



n_occur_twice([],Copy,L). /* base condition is empty input list. */
/* find the number of occurence of head element if it is equal to 2 remove all H from list
   if it is not 2 append that irregular numbers to another list then remove from orginal one
   And we are holding the orginal list to count properly 
*/
n_occur_twice([Hin|Tin],Copy,L):-
    count(Hin,Copy,T), T=2 ->  removeAll(Hin,[Hin|Tin],X), n_occur_twice(X,Copy,L);
    list_append(Hin,L,F), removeAll(Hin,[Hin|Tin],S) ,n_occur_twice(S,Copy,F).
/* this is just for the reducing the required input */   
run(List,K):-
    n_occur_twice(List,List,K).    


/** <examples>
?- count(3,[3,5,8,7,6,4,9],F).
   
?- list_append(2,[3],L).
   

?- 
   member(3,[0,1,4,2,4,2,1]).
?- removeAll(3,[3,3,5,8,7,6,3,9],F).
?- list_add(3,[3],X).
   

   
?- n_occur_twice([1,1,2,3,4,5,6,7,7,8,8],[1,1,2,2,3,4,5,6,7,7,8,8],K).
?- run([1,3,4,3,7,8,5,7],X)
*/