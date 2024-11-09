# Share with others

In this app, users can share their todos with others belonging to the same group by configuring a visibility of each todo.

## How to share

1. Open the todo detail screen.
2. Toggle the visibility of the todo to `Public`.

# Member list screen

Because users are belonging to the same group, users may want the list of members.

`Member` has the following fields:

- `id`: The ID of the member.
- `name`: The name of the member.
- `icon`: The icon of the member. This field is a type of `IconType` which is an enum type independent from Flutter. On View side, you need to convert it to Flutter's `IconData`.

In addition, each TODO needs additional fields:

- `assignee`: The user who is assigned to the todo.
- `createdBy`: The user who created the todo.

