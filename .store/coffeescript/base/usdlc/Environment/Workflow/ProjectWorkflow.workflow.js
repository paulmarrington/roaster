

var owners;

owners = {
  Project: '',
  Vision: '',
  Goal: '',
  Capability: '',
  Feature: '',
  Scenario: '',
  Script: '',
  Data: '',
  Guide: '',
  Page: '',
  General: '',
  Issue: '',
  Bug: '',
  Idea: '',
  Tasks: ''
};
var default_actions, default_workflow;

default_actions = {
  "new": function() {
    return mark('New', assign(editor));
  },
  edit: function() {
    return mark('Updated', assign(editor));
  },
  "delete": function() {
    return mark('Deleted', assign(owner));
  },
  pass: function() {
    return mark('Passed', clear(assignment));
  },
  fail: function() {
    return mark('Failed', assign(owner));
  },
  "default": function() {
    return mark(target.state, assign(owner));
  },
  Reject: function() {
    return assign(editor, requiring(note));
  },
  Review: function() {
    return mark('Review', assign(owner));
  },
  Accepted: function() {
    return clear(assignment, requiring(owner));
  },
  Issue: function() {
    return assign(owner, requiring(note));
  },
  Delete: function() {
    return section(deleted);
  }
};

default_workflow = {
  New: {
    buttons: 'Delete'
  },
  Updated: {
    buttons: 'Review Issue Delete'
  },
  Deleted: {
    buttons: 'Issue'
  },
  Passed: {
    buttons: 'Issue Delete'
  },
  Failed: {
    buttons: 'Issue Delete'
  },
  Reject: {
    buttons: 'Review Issue Delete'
  },
  Review: {
    buttons: 'Accepted Reject'
  },
  Accepted: {
    buttons: 'Issue Delete'
  },
  "default": {
    buttons: 'Issue Delete'
  }
};
var workflows;

workflows = {
  Project: nothing,
  Vision: nothing,
  Goal: nothing,
  Capability: nothing,
  Feature: nothing,
  Scenario: nothing,
  Script: nothing,
  Data: nothing,
  Guide: nothing,
  Page: nothing,
  General: nothing,
  Issue: nothing,
  Bug: nothing,
  Idea: nothing,
  Tasks: nothing
};
var assign, assignment, clear, deleted, editor, exported, form, mark, note, owner, prior, requiring, section, sectionType, _ref,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

form = usdlc.getWorkflowFormProcessor();

sectionType = usdlc.getSectionType(usdlc.inFocus);

owner = {
  name: (_ref = owners[sectionType]) != null ? _ref : '',
  required: function() {
    var _ref1;
    if (_ref1 = owner.name, __indexOf.call(form.fieldMap.Users, _ref1) >= 0) {
      return true;
    }
    alert("Must be assigned to " + owner.name + " for this operation");
    return false;
  }
};

note = {
  contents: form.fieldMap.Notes,
  required: function() {
    if (note.contents) {
      return true;
    }
    alert("This operation requires a note of explanation.\nDon't press 'Add Note'");
    return false;
  }
};

editor = usdlc.userName();

section = function(action, allowed) {
  if (allowed == null) {
    allowed = true;
  }
  if (!allowed) {
    return;
  }
  switch (action) {
    case 'deleted':
      return usdlc.deleteSectionInFocus();
  }
};

deleted = 'deleted';

requiring = function(field_name) {
  return field_name.required();
};

assign = function(person, allowed) {
  if (allowed == null) {
    allowed = true;
  }
  if (!allowed) {
    return;
  }
  return form.setField('Users', person);
};

prior = function() {};

clear = function(field, do_clear) {
  if (do_clear == null) {
    do_clear = true;
  }
  return form.setField(field, '');
};

assignment = 'Users';

mark = function(state, allowed) {
  if (!allowed) {
    return;
  }
  return usdlc.changeState(form, state);
};

exported = {
  workflows: workflows,
  default_workflow: default_workflow,
  default_actions: default_actions
};

return exported;

