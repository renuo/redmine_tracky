// Setup

declare module "@hotwired/stimulus";

declare global {
    interface Window {
        Stimulus?: any;
        TimerInterval?: any;
        RedmineTracky?: any;
    }
}

// Styles

require('./redmine-tracky.scss');

// Controllers
import { Application } from "@hotwired/stimulus";
import FormController from '@controllers/form-controller';
import TimerController from '@controllers/timer-controller';
import ListController from '@controllers/list-controller';
import IssueCompletionController from '@controllers/issue-completion-controller';
import Flatpickr from 'stimulus-flatpickr';

window.Stimulus = Application.start();
window.Stimulus.register("form", FormController);
window.Stimulus.register("timer", TimerController);
window.Stimulus.register("list", ListController);
window.Stimulus.register("issue-completion", IssueCompletionController);
window.Stimulus.register('flatpickr', Flatpickr)
