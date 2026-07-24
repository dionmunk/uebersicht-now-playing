options =
  # Enable or disable the widget.
  widgetEnable : true                   # true | false

  # Choose where the widget should sit on your screen.
  verticalPosition    : "bottom"        # top | bottom | center
  horizontalPosition    : "left"        # left | right | center

  # Show the time labels next to the progress bar at all. When false the bar
  # fills the entire row and showRemainingTime/showBothTimes are ignored.
  showTime           : true             # true | false

  # Show time as -M:SS (remaining) instead of M:SS (elapsed).
  showRemainingTime  : false            # true | false

  # Show elapsed AND remaining on opposite sides of the bar (overrides the above).
  showBothTimes      : true            # true | false

  # Progress bar position.
  #   "expanded": full-width bar below album art + metadata (default).
  #   "compact":  bar tucked inside the track-info column, beneath the album/year line.
  progressBarPosition : "expanded"     # expanded | compact

command: "osascript 'now-playing.widget/lib/getMusicData.applescript'"
refreshFrequency: '1s'
style: """

// setup
// --------------------------------------------------
display: none
font-family -apple-system, BlinkMacSystemFont, system-ui, sans-serif
font-size: 10px
margin = 10px
position: absolute

// variables
// --------------------------------------------------
widgetWidth 300px
borderRadius 6px
infoHeight 72px
infoWidth @widgetWidth - 82

// screen positioning calculations
// --------------------------------------------------
if #{options.verticalPosition} == center
    top 50%
    transform translateY(-50%)
else
    #{options.verticalPosition} margin

if #{options.horizontalPosition} == center
    left 50%
    transform translateX(-50%)
else
    #{options.horizontalPosition} margin

// styles
// --------------------------------------------------
.container
    width: @widgetWidth
    text-align: left
    position: relative
    clear: both
    color var(--text, #fff)
    text-shadow: 0 1px 1px rgba(20, 1, 1, 0.10)
    background var(--panel-bg, rgba(#000, .15))
    -webkit-backdrop-filter: blur(var(--panel-blur, 48px))
    backdrop-filter: blur(var(--panel-blur, 48px))
    padding 10px
    border-radius 10px

.top-row
    height: @infoHeight
    position: relative

.bottom-row
    position: relative
    height: 12px
    margin-top: 8px
    clear: both

// Compact layout: pull the bar (and times) up into the track-info column,
// pinned to the bottom of the top-row so everything fits in the album-art's
// 72px height. Metadata margins tighten so the bar has clear space below the
// album line.
.layout-compact .bottom-row
    position: absolute
    left: 92px
    right: 12px
    top: 71px
    margin-top: 0
    height: 12px

.layout-compact .artist-name
    margin-top: 4px
    margin-bottom: 1px

.layout-compact .song-name
    margin-top: 1px
    margin-bottom: 2px

.layout-compact .bar-container
    top: 4px   // bar sits 1px above the times, which stay flush with the album-art bottom

.album-art
    width: @infoHeight
    height: @width
    border-radius @borderRadius
    background-image: url(now-playing.widget/lib/default.png)
    background-size: cover
    float: left
    position: relative

.pause-overlay
    position: absolute
    top: 0
    left: 0
    width: 100%
    height: 100%
    border-radius: @borderRadius
    display: flex
    align-items: center
    justify-content: center
    background: rgba(#000, .35)
    opacity: 0
    transition: opacity .25s ease
    pointer-events: none

.pause-icon
    width: 18px
    height: 22px
    border-left: 6px solid #fff
    border-right: 6px solid #fff
    box-sizing: border-box

.track-info
    width: @infoWidth
    height: @infoHeight
    margin-left: 10px
    position: relative
    float: left

.artist-name
    font-size: 12px
    font-weight: 300
    margin-top: 7px
    margin-bottom: 5px
    overflow: hidden
    white-space: nowrap
    text-overflow: ellipsis
    float: left
    width: 218px

.is-loved
    color: var(--loved, #e84341)
    font-size: 11px
    font-weight: bold
    -webkit-text-stroke: 1px currentColor   // thickens the star glyph (bolder look)
    position: relative
    top: -1px
    margin-left: 7px

.song-name
    font-size: 15px
    font-weight: 600
    margin-top: 0
    margin-bottom: 6px
    overflow: hidden
    white-space: nowrap
    text-overflow: ellipsis
    float: left
    width: 218px

.album-name
    font-size: 12px
    font-weight: 300
    margin-top: 0
    margin-right: 5px
    overflow: hidden
    white-space: nowrap
    text-overflow: ellipsis
    float: left
    width: 218px

.time-elapsed
    position: absolute
    top: 1px
    left: 0
    font-size: 10px
    font-weight: bold
    line-height: 1
    width: 28px
    text-align: left

.time-remaining
    position: absolute
    top: 1px
    right: 0
    font-size: 10px
    font-weight: bold
    line-height: 1
    width: 28px
    text-align: right
    display: none

.bar-container
    width: calc(100% - 30px)
    height: @borderRadius
    border-radius: @borderRadius
    background: var(--level-base, rgba(#fff, .2))
    position: absolute
    top: 4px
    left: 30px
    box-shadow: 0 1px 1px rgba(20, 1, 1, 0.10)   // base bar: matches text shadow

.mode-remaining .time-elapsed
    display: none

.mode-remaining .time-remaining
    display: block

.mode-remaining .bar-container
    left: 0

.mode-both .time-remaining
    display: block

.mode-both .bar-container
    width: calc(100% - 61px)   // 1px narrower on the right → 3px gap to time-remaining (2px on the elapsed side)

// No-time: hide both time labels and let the bar fill the row.
// Declared after the mode-* rules so it overrides them at equal specificity.
.no-time .time-elapsed,
.no-time .time-remaining
    display: none

.no-time .bar-container
    left: 0
    width: 100%

.bar
    height: @borderRadius
    border-radius: @borderRadius
    transition: width .2s ease-in-out
    box-shadow: 1px 0 3px rgba(0, 0, 0, 0.04)   // faint separation under the cap

.bar-progress
    background: var(--level-max, rgba(#fff, 1))

.marquee-text
    display: inline-block
    white-space: nowrap

.is-marquee
    text-overflow: clip

.is-marquee .marquee-text
    animation-name: marquee
    animation-duration: var(--marquee-duration, 10s)
    animation-timing-function: linear
    animation-iteration-count: infinite

.is-paused .marquee-text
    animation-play-state: paused

.is-paused .pause-overlay
    opacity: 1

.is-paused .pause-icon
    animation: bar-pulse 2s ease-in-out infinite

@keyframes bar-pulse
    0%, 100%
        opacity: 1
    50%
        opacity: 0.15

@keyframes marquee
    0%, 12%
        transform: translateX(0)
    50%, 62%
        transform: translateX(var(--marquee-distance, 0))
    98%, 100%
        transform: translateX(0)
"""

options : options

render: () -> """
<div class="container">
    <div class="top-row">
        <div class="album-art">
            <div class="pause-overlay"><div class="pause-icon"></div></div>
        </div>
        <div class="track-info">
            <div class="artist-name"></div>
            <div class="song-name"></div>
            <div class="album-name"></div>
        </div>
    </div>
    <div class="bottom-row">
        <div class="time-elapsed">0:00</div>
        <div class="bar-container">
            <div class="bar bar-progress"></div>
        </div>
        <div class="time-remaining">-0:00</div>
    </div>
</div>
"""

# Apply marquee scrolling to an element when its inner text overflows.
applyMarquee: (div, selector, html) ->
  el = div.find(selector)
  node = el[0]
  return unless node
  if el.attr('data-marquee-html') isnt html
    el.attr('data-marquee-html', html)
    el.html("<span class=\"marquee-text\">#{html}</span>")
  inner = el.find('.marquee-text')[0]
  return unless inner
  overflow = inner.scrollWidth - node.clientWidth
  if overflow > 0
    duration = Math.max(14, Math.round((overflow + 80) / 10))
    node.style.setProperty('--marquee-distance', "-#{overflow}px")
    node.style.setProperty('--marquee-duration', "#{duration}s")
    el.addClass('is-marquee')
  else
    el.removeClass('is-marquee')
    node.style.removeProperty('--marquee-distance')
    node.style.removeProperty('--marquee-duration')

# Format a duration in seconds as H:MM:SS (when >= 1h) or M:SS.
formatTime: (t, prefix = '') ->
  h = Math.floor(t / 3600)
  m = Math.floor((t % 3600) / 60)
  s = t % 60
  sStr = if s < 10 then "0#{s}" else "#{s}"
  if h > 0
    mStr = if m < 10 then "0#{m}" else "#{m}"
    "#{prefix}#{h}:#{mStr}:#{sStr}"
  else
    "#{prefix}#{m}:#{sStr}"

# Update the rendered output.
update: (output, domEl) ->

  div = $(domEl)

  # if widget enabled
  if @options.widgetEnable

    # if not output then hide the widget
    if !output
      div.animate({opacity: 0}, 1000, 'swing').hide(1)
      return

    # gather script values
    values = output.slice(0,-1).split(" @ ")
    songDuration = values[4]
    currentPosition = values[5]
    coverURL = values[6]
    isLoved = values[8]
    playerState = values[10] or 'playing'

    songNameHtml = values[1]
    if isLoved == 'true'
      songNameHtml = songNameHtml + '<span class="is-loved">&starf;</span>'

    songYear = values[3]
    albumHtml = values[2]
    if songYear and songYear isnt '0' and songYear isnt 'NA'
      albumHtml += " &bull; #{songYear}"

    defaultUrl = 'now-playing.widget/lib/default.png'
    newBg = if not coverURL or coverURL is 'NA'
      "url(#{defaultUrl})"
    else
      # layer default underneath so it shows if coverURL fails to load
      "url(#{coverURL}), url(#{defaultUrl})"

    # cross-fade the top row when the track actually changes
    songId = "#{values[0]}|#{values[1]}|#{values[2]}"
    self = this
    applyTrackInfo = ->
      self.applyMarquee(div, '.artist-name', values[0])
      self.applyMarquee(div, '.song-name', songNameHtml)
      self.applyMarquee(div, '.album-name', albumHtml)
      div.find('.album-art').css('background-image', newBg)

    if @_lastSongId? and @_lastSongId isnt songId
      topRow = div.find('.top-row')
      topRow.stop(true).animate {opacity: 0}, 250, ->
        applyTrackInfo()
        topRow.animate {opacity: 1}, 250
    else
      applyTrackInfo()
    @_lastSongId = songId

    # set progress bar width — measured from container so it tracks layout changes
    barContainer = div.find('.bar-container')
    barWidth = barContainer[0].clientWidth
    songProgress = (currentPosition / songDuration) * barWidth
    div.find('.bar-progress').css width: songProgress

    # format time, clamped to 0
    elapsed = parseInt(currentPosition, 10)
    elapsed = 0 if isNaN(elapsed) or elapsed < 0
    total = parseInt(songDuration, 10)
    total = 0 if isNaN(total) or total < 0
    remaining = Math.max(0, total - elapsed)

    div.find('.time-elapsed').text(@formatTime(elapsed))
    div.find('.time-remaining').text(@formatTime(remaining, '-'))

    mode = if @options.showBothTimes then 'both'
    else if @options.showRemainingTime then 'remaining'
    else 'elapsed'
    container = div.find('.container')
    container
      .removeClass('mode-elapsed mode-remaining mode-both')
      .addClass("mode-#{mode}")
    container.toggleClass('layout-compact', @options.progressBarPosition is 'compact')
    container.toggleClass('no-time', not @options.showTime)
    if playerState is 'paused'
      container.addClass('is-paused')
    else
      container.removeClass('is-paused')

    # show the widget
    div.show(1).animate({opacity: 1}, 250, 'swing')

  # hide widget if disabled
  else
    div.hide()
