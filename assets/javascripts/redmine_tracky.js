import './jquery.datetimepicker.full.js';
import DateTimePickerRegister from './datetime_picker_register.js';
import IssueListHandler from './issue_list_handler.js';
import IssueCompleter from './issue_completer.js';

DateTimePickerRegister.bind();
IssueListHandler.bind();
IssueCompleter.bind();
// Export for use in reloaded partials
window.IssueListHandler = IssueListHandler;
window.IssueCompleter = IssueCompleter;
