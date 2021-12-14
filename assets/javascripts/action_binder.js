import DateTimePickerRegister from "./datetime_picker_register.js";
import IssueCompleter from "./issue_completer.js";
import TimerUpdater from "./timer_updater.js";
import HoursTracker from "./hours_tracker.js";

// A rebinder that is passed to window to be used in .js.erb files.
// Combines multiple Binders and wraps them in document.ready
export default class ActionBinder {
  static bind() {
    $(document).ready(this.runBind);
  }

  static runBind() {
    DateTimePickerRegister.bind();
    IssueCompleter.bind();
    TimerUpdater.bind();
    HoursTracker.bind();
    IssueListHandler.bind();
  }

  static issueCompleter() {
    return IssueCompleter;
  }

  static timerUpdate() {
    return TimerUpdater;
  }

  static datetimePicker() {
    return DateTimePickerRegister;
  }

  static hoursTracker() {
    return HoursTracker;
  }
}
