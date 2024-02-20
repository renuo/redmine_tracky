import { Controller } from '@hotwired/stimulus'
import { CompletionResult } from '@interfaces/completion-result'

export default class extends Controller {
  declare readonly tableTarget: Element

  static targets = ['table']

  public addItem(item: CompletionResult) {
    const tbody = this.tableTarget.getElementsByTagName('tbody')[0]
    tbody.appendChild(this.buildItem(item))
  }

  public removeItem(event: Event) {
    const { target } = event
    const row = (target as Element).closest('[data-form-target="issue"]')
    row?.remove()
  }

  private buildItem(item: CompletionResult) {
    const row = document.createElement('tr')
    row.setAttribute('data-form-target', 'issue')
    row.classList.add('issue-container')
    row.setAttribute('data-issue-id', item.id.toString())
    ;[
      this.buildLabelColumn(item),
      this.buildSubjectColumn(item),
      this.buildDeletionButtonColumn(item),
    ].forEach((element) => row.appendChild(element))

    return row
  }

  private buildLabelColumn(item: CompletionResult) {
    const bold = document.createElement('b')
    const a = document.createElement('a')

    a.setAttribute('href', `/issues/${item.id}`)
    a.setAttribute('target', '_blank')
    a.setAttribute('rel', 'noopener')

    a.innerHTML = `${item.project} - ${item.id}: `
    bold.appendChild(a)

    return this.buildColumn([bold])
  }

  private buildSubjectColumn(item: CompletionResult) {
    return this.buildColumn([document.createTextNode(item.subject)])
  }

  private buildDeletionButtonColumn(item: CompletionResult) {
    const span = document.createElement('span')
    const icon = document.createElement('i')
    const input = document.createElement('input')

    span.classList.add('text-danger')
    span.classList.add('input-group-text')
    span.setAttribute('data-action', 'click->list#removeItem')
    icon.classList.add('icon-only')
    icon.classList.add('icon-del')
    span.appendChild(icon)
    input.setAttribute('id', `timer_session_issue_id_${item.id}`)
    input.setAttribute('readonly', '')
    input.setAttribute('hidden', '')
    input.setAttribute('name', 'timer_session[issue_ids][]')
    input.setAttribute('value', item.id.toString())

    return this.buildColumn([span, input])
  }

  private buildColumn(elements: (Element | Text)[]) {
    const column = document.createElement('td')
    elements.forEach((element) => column.appendChild(element))
    return column
  }
}
