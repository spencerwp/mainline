class EventPresenter

  class CreateTagEvent < self

    def action
      project = event.target.project

      action_for_event(:event_tagged) {
        view.link_to(h(project.slug), view.project_path(project))  + "/" +
        view.link_to(h(target.name), view.project_repository_url(project, target))
      }
    end

    def body
      view.link_to(
        view.ref(branch),
        view.tree_entry_url(target.repository_plain_path, h(branch))
      )
    end

    def category
      'commit'
    end

    private

    def branch
      data
    end

  end

end