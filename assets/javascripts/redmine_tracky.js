import './jquery.datetimepicker.min.js';
import ActionBinder from './action_binder.js';
import IssueListHandler from './issue_list_handler.js';
import UpdateIssuesList from './update_issues_list.js';

ActionBinder.bind();
IssueListHandler.bind();

window.ActionBinder = ActionBinder;
window.IssueListHandler = IssueListHandler;
window.UpdateIssuesList = UpdateIssuesList;
