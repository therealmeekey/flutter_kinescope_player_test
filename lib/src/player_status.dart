enum PlayerStatus {
  init,
  ready,
  playing,
  waiting,
  pause,
  ended,
  unknown,
}

PlayerStatus playerStatusFromString(String status) {
  switch (status) {
    case 'init':
      return PlayerStatus.init;
    case 'ready':
      return PlayerStatus.ready;
    case 'playing':
      return PlayerStatus.playing;
    case 'waiting':
      return PlayerStatus.waiting;
    case 'pause':
    case 'paused':
      return PlayerStatus.pause;
    case 'ended':
      return PlayerStatus.ended;
    default:
      return PlayerStatus.unknown;
  }
}
