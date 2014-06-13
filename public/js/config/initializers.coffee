window.faye_client = new Faye.Client("http://#{window.location.hostname}:9292/faye")

# Timing task
window.setInterval ->
  group_id = $("#topic-view").data("group-id")
  if Backbone.history.fragment == "dashboard" # Get groups unread comments count
    $("#my-groups-list").children().each (i, child) ->
      group_id = _.last(child.id.split("-"))
      group_name = $(child).find("a.name").text()
      logo_url = $(child).find("img.logo").attr("src").replace("larger_logo", "normal_logo")
      group = new Group()
      group.set({_id: group_id, name: group_name, logo_url_32: logo_url})
      dashboard_view = new DashboardView()
      dashboard_view.renderNotification(group)
  else if group_id # Get online users
    topic_view = new TopicView({group_id: group_id})
    topic_view.fetchMemberList()
, 30000
