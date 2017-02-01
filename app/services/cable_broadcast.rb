
class CableBroadcast
  def perform(channel:, data:, extract_referrer_from:)
    ActionCable.server.broadcast(
      channel, data.merge(referrer: referrer_get(extract_referrer_from))
    )
  end

  private

  def referrer_get(referer)
    default = 'map'
    return default if !referer
    pcomps = referer.split('/')
    return default if pcomps.empty?
    last = pcomps.last
    return default if last.strip.empty?
    return last
  end
end
