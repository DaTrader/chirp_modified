defmodule ChirpWeb.PostLive.PostComponent do
  use ChirpWeb, :live_component

  def handle_event("like", _, socket) do
    Chirp.Timeline.inc_likes(socket.assigns.post)
    {:noreply, socket}
  end

  def handle_event("repost", _, socket) do
    Chirp.Timeline.inc_reposts(socket.assigns.post)
    {:noreply, socket}
  end

  def handle_event( "update_body", %{ "value" => value}, socket) do
    Chirp.Timeline.update_post( socket.assigns.post, %{ body: value})
    { :noreply, socket}
  end
end
