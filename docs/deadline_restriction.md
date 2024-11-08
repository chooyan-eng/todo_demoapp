# Deadline Restriction

When adding a new todo, business logic will check if the user has sufficient time to complete the todo.

For example, if the user has 10 hours to complete the todo, and the deadline is only 5 hours from now, the business logic will refuse to add the todo, and throw `DeadlineRestrictionException`.

Another example is if the user has 5 hours to complete the todo, and the deadline is 10 hours from now, BUT their is another todo that takes 6 hours to be completed before the deadline of adding new todo, then the business logic will refuse to add the todo, and throw `DeadlineRestrictionException`, too.

The logic consider all the deadlines and estimated hours of the todos, and calculate if the user has enough time to complete the todo.