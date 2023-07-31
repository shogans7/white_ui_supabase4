abstract class FeedEvent {}

class InitFeedEvent extends FeedEvent {}

class FeedReloadEvent extends FeedEvent {}

class FeedUserUpdatedEvent extends FeedEvent {
  bool hasFriends;

  FeedUserUpdatedEvent({required this.hasFriends});
}

class LoadOlderPosts extends FeedEvent {}
