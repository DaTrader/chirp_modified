defmodule ChirpWeb.PostLive.Index do
  use ChirpWeb, :live_view

  alias Chirp.Timeline
  alias Chirp.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    posts = fetch_posts()
    {:ok, socket
          |> assign( :some_data, generate_some_data( :mounted))
          |> assign( :posts, posts), temporary_assigns: [posts: []]}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, assign(socket, :posts, fetch_posts())}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, socket
               |> assign( :some_data, generate_some_data( :post_created, post))
               |> update( :posts, fn posts -> [post | posts] end)}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, socket
               |> assign( :some_data, generate_some_data( :post_updated, post))
               |> update( :posts, fn posts -> [post | posts] end)}
  end

  defp fetch_posts do
    Timeline.list_posts()
  end


  defp generate_some_data( event, post \\ nil)

  defp generate_some_data( event, nil),
       do: %{ event: event, id: nil, likes: nil, reposts: nil, print: generate_print()}

  defp generate_some_data( event, post),
       do: %{ event: event, id: post.id, likes: post.likes_count, reposts: post.reposts_count, print: generate_print()}

  defp generate_print(),
       do: make_ref() |> :erlang.ref_to_list() |> List.to_string()
end
