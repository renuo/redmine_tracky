export default class IssueCompleter {
	static bind() {
		$(document).ready(() => {
		observeAutocompleteField('timer_session_issue_id',
			function(request, callback) {
				var url = window.RedmineTracky.issueCompletionPath;
				var data = {
					term: request.term
				};
				data['scope'] = 'all';
				$.get(url, data, null, 'json')
					.done(function(data){
						console.log(data);
						callback(data);
					})
					.fail(function(jqXHR, status, error){
						callback([]);
					});
			},
			{
				select: function(event, item) {
					window.IssueListHandler.addIssue(item.item);
				}
			}
		);
			});
	}
}
