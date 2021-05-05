import './jquery.datetimepicker.full.js';
import ActionBinder from './action_binder.js';
import IssueListHandler from './issue_list_handler.js';

ActionBinder.bind();
IssueListHandler.bind();

window.ActionBinder = ActionBinder;
window.IssueListHandler = IssueListHandler;
