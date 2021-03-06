% COMP 9414 assignment3 option2 Prolog(BDI agent)
% written by Bianca Tong



% q1 Update Goals


% Goals(Goal_rest,Goal_truff)
% Base case : Goal for rest and truff both empty.
goals([],[]).

% Trigger(Event, Goals)
% Base case : In case no new event, goal for rest and truff stay empty
trigger([], goals([],[])) :- !.

% In case event restaurant, update goal for Goal_rest
trigger([truffle(X,Y,S)|Percepts], goals(Goals_rest,[goal(X,Y,S)|Goals_truff])) :-
        trigger(Percepts, goals(Goals_rest,Goals_truff)).

% In case event truffle, update goal for Goal_truff
trigger([restaurant(X,Y,S)|Percepts], goals([goal(X,Y,S)|Goals_rest], Goals_truff)) :-
        trigger(Percepts, goals(Goals_rest,Goals_truff)).



% q2 Update Intentions


% incorporate_goals(Goal, Belief, Intentions, Intentions1)
% Base case : In case no new goals for both rest and truff, Intentions
% stay same.
incorporate_goals(goals([],[]), beliefs(at(_,_),stock(_)), Intentions, Intentions):-!.


% In case only new rest goal
% In case existed goal, loop to next rest goal
incorporate_goals(goals([goal(X,Y,S)|Goal_rest],[]), Beliefs, intents(Int_sell,Int_pick), Intentions1) :-
        member([goal(X,Y,S),_], Int_sell),
        incorporate_goals(goals(Goal_rest,[]), Beliefs, intents(Int_sell,Int_pick), Intentions1),!.

% Or Insert new rest goal to correct position in Int_sell
incorporate_goals(goals([goal(X,Y,S)|Goal_rest],[]), Beliefs, intents(Int_sell,Int_pick), Intentions1) :-
        update_intents_goal(goal(X,Y,S), Beliefs, Int_sell, NewInt_sell),
        incorporate_goals(goals(Goal_rest,[]), Beliefs, intents(NewInt_sell,Int_pick), Intentions1).

% In case only new truff goal
% In case existed goal, loop to next truff goal
incorporate_goals(goals([],[goal(X1,Y1,S1)|Goal_truff]), Beliefs, intents(Int_sell,Int_pick), Intentions1) :-
        member([goal(X1,Y1,S1),_], Int_pick),
        incorporate_goals(goals([],Goal_truff), Beliefs, intents(Int_sell,Int_pick), Intentions1),!.

% Or Insert new truff goal to correct postion
incorporate_goals(goals([],[goal(X1,Y1,S1)|Goal_truff]), Beliefs, intents(Int_sell,Int_pick), Intentions1) :-
        update_intents_goal(goal(X1,Y1,S1), Beliefs, Int_pick, NewInt_pick),
        incorporate_goals(goals([],Goal_truff), Beliefs, intents(Int_sell,NewInt_pick), Intentions1).

% In case new goal for both rest and truff
% In case both existed goals, loop to next goal for both
incorporate_goals(goals([goal(X,Y,S)|Goal_rest], [goal(X1,Y1,S1)|Goal_truff]), Beliefs, intents(Int_sell,Int_pick), Intentions1) :-
        member([goal(X,Y,S),_], Int_sell),
        member([goal(X1,Y1,S1),_], Int_pick),
        incorporate_goals(goals(Goal_rest,Goal_truff), Beliefs, intents(Int_sell,Int_pick), Intentions1),!.

% In case only new truff goal existed goal, insert only new  rest goal into correct position in Int_rest
incorporate_goals(goals([goal(X,Y,S)|Goal_rest], [goal(X1,Y1,S1)|Goal_truff]), Beliefs, intents(Int_sell,Int_pick), Intentions1) :-
        member([goal(X1,Y1,S1),_], Int_pick),
        update_intents_goal(goal(X,Y,S), Beliefs, Int_sell, NewInt_sell),
        incorporate_goals(goals(Goal_rest, Goal_truff), Beliefs, intents(NewInt_sell,Int_pick), Intentions1), !.

% In case only new rest goal existed goal, insert only new truff goal into correct position in Int_pick
incorporate_goals(goals([goal(X,Y,S)|Goal_rest], [goal(X1,Y1,S1)|Goal_truff]), Beliefs, intents(Int_sell,Int_pick), Intentions1) :-
        member([goal(X,Y,S),_], Int_sell),
        update_intents_goal(goal(X1,Y1,S1), Beliefs, Int_pick, NewInt_pick),
        incorporate_goals(goals(Goal_rest, Goal_truff), Beliefs, intents(Int_sell,NewInt_pick), Intentions1), !.

% Or both not existed goals, insert both into correct position in Int_rest and Int_pick
incorporate_goals(goals([goal(X,Y,S)|Goal_rest], [goal(X1,Y1,S1)|Goal_truff]), Beliefs, intents(Int_sell,Int_pick), Intentions1) :-
        update_intents_goal(goal(X,Y,S), Beliefs, Int_sell, NewInt_sell),
        update_intents_goal(goal(X1,Y1,S1), Beliefs, Int_pick, NewInt_pick),
        incorporate_goals(goals(Goal_rest,Goal_truff), Beliefs, intents(NewInt_sell,NewInt_pick), Intentions1).


% Insert intention of new goal to the correct position in the Intentions list


% Base case : Insert first new goal to list as intention in the form of [goal(X,Y,S),[]]
update_intents_goal(goal(X,Y,S),_, [], [[goal(X,Y,S),[]]]):-!.


% Find one item of intentions list, compare Stock S1 of its goal with Stock S of new goal
% In case S1 < S, in other words new goal has higher stock, insert the intention of new goal before that item
update_intents_goal(goal(X,Y,S),beliefs(at(_,_),stock(_)),[[goal(X1,Y1,S1),Plan]|Tail],[[goal(X,Y,S),[]]|Tail1]):-
        S>S1,
        Tail1 = [[goal(X1,Y1,S1),Plan]|Tail],!.


% In case S1 > S, in other words current goal has lower stock, loop to the next item of intentions list
update_intents_goal(goal(X,Y,S),beliefs(at(X0,Y0),stock(_)),[[goal(X1,Y1,S1),Plan]|Tail],[[goal(X1,Y1,S1),Plan]|Tail1]):-
        S1>S,
        update_intents_goal(goal(X,Y,S), beliefs(at(X0, Y0),stock(_)), Tail, Tail1),!.


% In case S1 = S, compare their distance to current location
% In case D1 < D, in other words new goal has longer distance, loop to next item of intentions list
update_intents_goal(goal(X,Y,S), beliefs(at(X0,Y0),stock(_)), [[goal(X1,Y1,S1), Plan]|Tail],[[goal(X1,Y1,S1), Plan]|Tail1]) :-
        S = S1,
        distance((X,Y), (X0,Y0), D),
	distance((X1,Y1), (X0,Y0), D1),
        D > D1,
        update_intents_goal(goal(X,Y,S), beliefs(at(X0,Y0),stock(_)), Tail,Tail1),!.


% In case D1 >= D, in other words new goal has shorter distance, insert the intention of new goal before that item
update_intents_goal(goal(X,Y,S), beliefs(at(X0,Y0),stock(_)), [[goal(X1,Y1,S1), Plan]|Tail],[[goal(X,Y,S), []]|Tail1]) :-
        S = S1,
        distance((X,Y), (X0,Y0), D),
        distance((X1,Y1), (X0,Y0), D1),
        D =< D1,
        Tail1 = [[goal(X1,Y1,S1),Plan]|Tail],!.


% q3 Select Intention and corresponding Action to fulfill


% get_action(Belief, Intentions, Intentions1, Action)
% Base case: at starting point, set Action to move(6,5)
get_action(beliefs(at(5,5),stock(0)),intents([],[]),intents([],[]),move(6,5)) :-!.

% Base case: in case no new goals for both rest and truff, stay there
get_action(beliefs(at(X,Y),stock(_)),intents([],[]),intents([],[]),move(X,Y)) :-!.

% If Int_sell is not empty and first item satisfies S<=T. Select this intention.
% If first action in this plan is applicable, select this action, update intention.
get_action(beliefs(at(_,_),stock(T)),intents([Int_sell|Int_sell_rest],Int_pick),intents([[Goal,RestofActions]|Int_sell_rest],Int_pick),Action) :-
        first_action(Int_sell,Goal,[Action|RestofActions]),
        Goal=goal(_,_,S),
        S=<T,
        applicable(Action).


% If first action is not applicable,
% Construct a new plan
% Select the first action, update intention .
get_action(beliefs(at(X,Y),stock(T)),intents([Int_sell|Int_sell_rest],Int_pick),intents([[Goal,New_rest_actions1]|Int_sell_rest],Int_pick),Action) :-
        first_action(Int_sell,Goal,[Wrong_Action|_]),
        Goal=goal(_,_,S),
        S=<T,
        not(applicable(Wrong_Action)),
        new_action_sell(Goal,beliefs(at(X,Y),stock(T)),New_action),
        new_first_action(New_action,New_rest_actions1,Action).


% If there is no plan for the goal,
% Construct a new plan
% Select the first action, update intention.
get_action(beliefs(at(X,Y),stock(T)),intents([[Goal,[]]|Int_sell_rest],Int_pick),intents([[Goal,New_rest_action1]|Int_sell_rest],Int_pick), Action) :-
        Goal=goal(_,_,S),
        S=<T,
        new_action_sell(Goal,beliefs(at(X,Y),stock(T)),New_action),
        %first_action([Goal, New_action], Goal, [Action|_]),
        new_first_action(New_action,New_rest_action1,Action).


% If not enough stock to sell, throw it.
get_action(beliefs(at(X,Y),stock(T)),intents([[Goal,Plan]|Int_sell],[]),intents([[Goal,Plan]|Int_sell],[]),move(X,Y)) :-
        Goal=goal(_,_,S),
        S>T.


% If Int_pick is not empty. Select this intention.
% If first action in this plan is applicable, select this action, update intention.
get_action(beliefs(at(_,_),stock(_)),intents(Int_sell,[Int_pick|Int_pick_rest]),intents(Int_sell,[[Goal,RestofActions]|Int_pick_rest]),Action) :-
        first_action(Int_pick,Goal,[Action|RestofActions]),
        applicable(Action).


% If first action is not applicable
% Construct a new plan
% Select the first action, update intention.
get_action(beliefs(at(X,Y),stock(T)),intents(Int_sell,[Int_pick|Int_pick_rest]),intents(Int_sell,[[Goal,New_action1]|Int_pick_rest]),Action) :-
        first_action(Int_pick, Goal,[Wrong_Action|_]),
        not(applicable(Wrong_Action)),
        new_action_pick(Goal,beliefs(at(X,Y),stock(T)),New_action),
        new_first_action(New_action,New_action1,Action).


% If there is no plan for the goal
% Construct a new plan
% Select the first action, update intention.
get_action(beliefs(at(X,Y),stock(T)),intents(Int_sell,[[Goal,[]]|Int_pick_rest]),intents(Int_sell,[[Goal, New_action1]|Int_pick_rest]),Action) :-
        new_action_pick(Goal,beliefs(at(X,Y),stock(T)),New_action),
        %first_action([Goal, New_action], Goal, [Action|_]),
        new_first_action(New_action,New_action1,Action).


% Distinguish goals and actions in a list to select the first action.
first_action([Goal|Actions],Goal,Actions).


% Select a new first action from a new actions list.
new_first_action([Action|New_action1],New_action1,Action).


% Construct new plan for Int_sell.
new_action_sell(Goal,Beliefs,Actions) :-
        new_action_sell(Goal,Beliefs,[],Actions).
new_action_sell(goal(X,Y,_),beliefs(at(X,Y),stock(_)),Partial_action,Actions) :-
        reverse([sell(X,Y)|Partial_action],Actions).
new_action_sell(Goal,beliefs(at(X,Y),stock(_)),Partial_action,Actions) :-
        right_move(X,Y,move(X2,Y2)),
        right_direction(move(X2,Y2),Goal,at(X,Y)),
        new_action_sell(Goal,beliefs(at(X2,Y2),stock(_)),[move(X2,Y2)|Partial_action],Actions).


% Construct new plan for Int_pick.
new_action_pick(Goal,Beliefs,Actions) :-
        new_action_pick(Goal,Beliefs,[],Actions).
new_action_pick(goal(X,Y,_),beliefs(at(X,Y),stock(_)),Partial_action,Actions) :-
        reverse([pick(X,Y)|Partial_action],Actions).
new_action_pick(Goal,beliefs(at(X,Y),stock(_)),Partial_action,Actions) :-
        right_move(X,Y,move(X2,Y2)),
        right_direction(move(X2,Y2),Goal,at(X,Y)),
        new_action_pick(Goal,beliefs(at(X2,Y2),stock(_)),[move(X2,Y2)|Partial_action],Actions).
/*
% Reverse a list.
reverse(List,Reverse) :-
        reverse(List,[],Reverse).
reverse([],Reverse,Reverse).
reverse([Head|Tail],Rest_Reverse,Reverse) :-
        reverse(Tail,[Head|Rest_Reverse],Reverse).
*/

% Construct a correct move.
right_move(X,Y,Move) :-
        X1 is X+1,Move=move(X1,Y);
        X2 is X-1,Move=move(X2,Y);
        Y1 is Y+1,Move=move(X,Y1);
        Y2 is Y-1,Move=move(X,Y2).

% Determine whether the direction is towards goal.
right_direction(move(X1,Y1),goal(X2,Y2,_),at(X,Y)) :-
        distance((X1,Y1),(X2,Y2),Current_dis),
        distance((X,Y),(X2,Y2),Plan_dis),
        Current_dis<Plan_dis.


% q4 Update Beliefs After Action


% After pick(X,Y), update stock level by adding the picked truff number on current stock level
update_beliefs(picked(X,Y,S),beliefs(at(X,Y),stock(T)),beliefs(at(X,Y),stock(U))) :-
        U is T+S.

% After sell(X,Y), update stock level by subtracting the sold truff number from current stock level
update_beliefs(sold(X,Y,S),beliefs(at(X,Y),stock(T)),beliefs(at(X,Y),stock(U))) :-
        U is T-S.

% After move(X,Y), update new location position by setting beliefs(at(X,Y),stock(T))
update_beliefs(at(X1,Y1),beliefs(at(_,_),stock(T)),beliefs(at(X1,Y1),stock(T))).


% q5 Update Intentions


% After sell(X,Y), update intentions by drop that intention from list
update_intentions(sold(X,Y,S),intents([[goal(X,Y,S)|_]|Int_rest],Int_truf),intents(Int_rest,Int_truf)).

% After pick(X,Y), update intentions by drop that intention from list
update_intentions(picked(X,Y,S),intents(Int_rest,[[goal(X,Y,S)|_]|Int_truf]),intents(Int_rest,Int_truf)).

% After move(X,Y), intentions stay same
update_intentions(at(_,_),Intentions,Intentions).
