export default class UpdateIssuesList {
	static issueContainer() {
		return '[data-update-issue-selection-container]'
	}

	static elementID() {
		return 'timer_session[issue_ids]';
	}

	static issueDeletionButton() {
		return 'data-update-issue-deletion-action';
	}

	static bind() {
		$(document).ready(() => {
			$('[data-update-issue-deletion-action]').off('click');
			$('[data-update-issue-deletion-action]').on('click', function() {
				UpdateIssuesList.removeIssue($(this));
			});
		});
	}

	static removeIssue(element) {
		const parent = element.parent();
		parent.remove();
	}

	static addIssue(item) {
		$(UpdateIssuesList.issueContainer()).append(UpdateIssuesList.buildNewIssueElement(item.id,
			item.label));
		UpdateIssuesList.bind();
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
