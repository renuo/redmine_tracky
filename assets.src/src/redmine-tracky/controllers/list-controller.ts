import { Controller } from '@hotwired/stimulus'
import { CompletionResult } from '@interfaces/completion-result'

export default class extends Controller {
  declare readonly tableTarget: Element

  static targets = ['table']

  addItem(item: CompletionResult) {
    this.tableTarget.querySelector('tbody')!.appendChild(this.buildItem(item))
  }

  removeItem({ target }: Event) {
    const item = target as Element
    item.closest('[data-form-target="issue"]')?.remove()
  }

  private buildItem(item: CompletionResult) {
    const issue = this.tableTarget
      .querySelector('template')!
      .content.cloneNode(true) as DocumentFragment
    const link = issue.querySelector('a')!
    const input = issue.querySelector('input')!

    link.href = `/issues/${item.id}`
    link.innerHTML = `${item.project} - ${item.id}: `
    input.id = `timer_session_issue_id_${item.id}`
    input.value = item.id.toString()
    issue.querySelector('tr')!.setAttribute('data-issue-id', item.id.toString())
    issue.querySelector('[data-issue-subject]')!.innerHTML = item.subject

    return issue
  }
}
