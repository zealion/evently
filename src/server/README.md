#### api

event/:id/guests - GET all guests
event/:id/guests/arrived - GET all guests arrived
event/:id/guests - PUT create a new guest
event/:id/guest/:id - GET a guest
event/:id/guest/:id - PUT update a guest
event/:id/guest/:id - DELETE a guest

#### socket events

GUEST_CHANGED (guest object)
GUEST_ADDED (guest object)
GUEST_DELETED (guest object)