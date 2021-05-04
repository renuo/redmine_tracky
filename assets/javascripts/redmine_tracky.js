import './jquery.datetimepicker.full.js';
import DateTimePickerRegister from './datetime_picker_register.js';
import IssueListHandler from './issue_list_handler.js';

DateTimePickerRegister.bind();

IssueListHandler.bind();
// Export for use in reloaded partials
window.IssueListHandler = IssueListHandler;
