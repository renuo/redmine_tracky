export default class IssueListHandler {
    static issueContainer() {
        return '[data-issue-selection-container]'
    }

    static elementID() {
        return 'timer_session[issue_ids]';
    }

    static issueDeletionButton() {
        return 'data-issue-deletion-action';
    }

    static bind() {
        $(document).ready(() => {
            $('[data-issue-deletion-action]').off('click');
            $('[data-issue-deletion-action]').on('click', function() {
                IssueListHandler.removeIssue($(this));
            });
        });
    }

    static removeIssue(element) {
        const parent = element.parent();
        parent.remove();
        window.ActionBinder.timerUpdate().updateIssue();
    }

    static addIssue(item) {
        $(IssueListHandler.issueContainer()).append(IssueListHandler.buildNewIssueElement(item.id,
            item.label));
        IssueListHandler.bind();
    }

    static buildNewIssueElement(id, label) {
        return $(`
        <div class="issue-container">
					<label for='timer_session_issue_id_${id}'>${label}</label>
          <input hidden data-issue-element='${id}'
					id='timer_session_issue_id_${id}'
          class="ml-10 form-control" readonly name="${IssueListHandler.elementID()}[]" value="${id}"/>
					<div class="input-group-text" ${IssueListHandler.issueDeletionButton()}="">
						<i class="icon-only icon-del"></i>
					</div>
        </div>
    `);
    }
}