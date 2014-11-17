
define [ "underscore", 'raphael'], (_, Raphael) ->
  LINETYPE =
    SOLID: 0
    DOTTED: 1

  ARROWTYPE =
    FILLED: 0
    OPEN: 1

  PLACEMENT =
    LEFTOF: 0
    RIGHTOF: 1
    OVER: 2

  DIAGRAM_MARGIN = 10
  ACTOR_MARGIN = 10
  ACTOR_PADDING = 10
  SIGNAL_MARGIN = 5
  SIGNAL_PADDING = 5
  NOTE_MARGIN = 10
  NOTE_PADDING = 5
  NOTE_OVERLAP = 15
  TITLE_MARGIN = 0
  TITLE_PADDING = 5
  SELF_SIGNAL_WIDTH = 20

  LINE =
    stroke: "#000"
    "stroke-width": 2

  RECT = fill: "#fff"

  getCenterX = (box) ->
    box.x + box.width / 2
  getCenterY = (box) ->
    box.y + box.height / 2

  assert = (exp, message) ->
    assert(message)  unless exp
    return

  Raphael.fn.line = (x1, y1, x2, y2) ->
    assert _.all([
      x1
      x2
      y1
      y2
    ], _.isFinite), "x1,x2,y1,y2 must be numeric"
    @path "M{0},{1} L{2},{3}", x1, y1, x2, y2

  Raphael.fn.wobble = (x1, y1, x2, y2) ->
    assert _.all([
      x1
      x2
      y1
      y2
    ], _.isFinite), "x1,x2,y1,y2 must be numeric"
    wobble = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) / 25
    
    # Distance along line
    r1 = Math.random()
    r2 = Math.random()
    xfactor = (if Math.random() > 0.5 then wobble else -wobble)
    yfactor = (if Math.random() > 0.5 then wobble else -wobble)
    p1 =
      x: (x2 - x1) * r1 + x1 + xfactor
      y: (y2 - y1) * r1 + y1 + yfactor

    p2 =
      x: (x2 - x1) * r2 + x1 - xfactor
      y: (y2 - y1) * r2 + y1 - yfactor

    "C" + p1.x + "," + p1.y + " " + p2.x + "," + p2.y + " " + x2 + "," + y2


  ###*
  Returns the text's bounding box
  ###
  Raphael.fn.text_bbox = (text, font) ->
    p = undefined
    if font._obj
      p = @print_center(0, 0, text, font._obj, font["font-size"])
    else
      p = @text(0, 0, text)
      p.attr font
    bb = p.getBBox()
    p.remove()
    bb


  ###*
  Draws a wobbly (hand drawn) rect
  ###
  Raphael.fn.handRect = (x, y, w, h) ->
    assert _.all([
      x
      y
      w
      h
    ], _.isFinite), "x, y, w, h must be numeric"
    @path("M" + x + "," + y + @wobble(x, y, x + w, y) + @wobble(x + w, y, x + w, y + h) + @wobble(x + w, y + h, x, y + h) + @wobble(x, y + h, x, y)).attr RECT


  ###*
  Draws a wobbly (hand drawn) line
  ###
  Raphael.fn.handLine = (x1, y1, x2, y2) ->
    assert _.all([
      x1
      x2
      y1
      y2
    ], _.isFinite), "x1,x2,y1,y2 must be numeric"
    @path "M" + x1 + "," + y1 + @wobble(x1, y1, x2, y2)


  ###*
  Prints, but aligns text in a similar way to text(...)
  ###
  Raphael.fn.print_center = (x, y, string, font, size, letter_spacing) ->
    path = @print(x, y, string, font, size, "baseline", letter_spacing)
    bb = path.getBBox()
    
    # Translate the text so it's centered.
    dx = (x - bb.x) - bb.width / 2
    dy = (y - bb.y) - bb.height / 2
    
    # Due to an issue in Raphael 2.1.0 (that seems to be fixed later)
    # we remap the path itself, instead of using a transformation matrix
    m = new Raphael.matrix()
    m.translate dx, dy
    path.attr "path", Raphael.mapPath(path.attr("path"), m)

    # otherwise we would do this:
    #return path.transform("t" + dx + "," + dy);
    
  class BaseTheme
    constructor: (diagram) ->
      console.log "BaseTheme", diagram
      @diagram = diagram
      @_paper = `undefined`
      @_font = `undefined`
      @_title = `undefined` # hack - This should be somewhere better
      @_actors_height = 0
      @_signals_height = 0
      a = @arrow_types = {}
      a[ARROWTYPE.FILLED] = "block"
      a[ARROWTYPE.OPEN] = "open"
      l = @line_types = {}
      l[LINETYPE.SOLID] = ""
      l[LINETYPE.DOTTED] = "-"
      return

    init_paper: (container) ->
      @_paper = new Raphael(container, 320, 200)
      return

    init_font: ->

    draw_line: (x1, y1, x2, y2) ->
      @_paper.line x1, y1, x2, y2

    draw_rect: (x, y, w, h) ->
      @_paper.rect x, y, w, h

    draw: (container) ->
      console.log "drawing on", container
      diagram = @diagram
      @init_paper container
      @init_font()
      @layout()
      title_height = (if @_title then @_title.height else 0)
      @_paper.setStart()
      @_paper.setSize diagram.width, diagram.height
      y = DIAGRAM_MARGIN + title_height
      @draw_title()
      @draw_actors y
      @draw_signals y + @_actors_height
      @_paper.setFinish()
      return

    layout: ->
      
      # Local copies
      # min width
      # min width
      
      # Setup some layout stuff
      
      #var bb = t.attr("text", a.name).getBBox();
      actor_ensure_distance = (a, b, d) ->
        assert a < b, "a must be less than or equal to b"
        if a < 0
          
          # Ensure b has left margin
          b = actors[b]
          b.x = Math.max(d - b.width / 2, b.x)
        else if b >= actors.length
          
          # Ensure a has right margin
          a = actors[a]
          a.padding_right = Math.max(d, a.padding_right)
        else
          a = actors[a]
          a.distances[b] = Math.max(d, (if a.distances[b] then a.distances[b] else 0))
        return
      diagram = @diagram
      paper = @_paper
      font = @_font
      actors = diagram.actors
      signals = diagram.signals
      diagram.width = 0
      diagram.height = 0
      if diagram.title
        title = @_title = {}
        bb = paper.text_bbox(diagram.title, font)
        title.text_bb = bb
        title.message = diagram.title
        title.width = bb.width + (TITLE_PADDING + TITLE_MARGIN) * 2
        title.height = bb.height + (TITLE_PADDING + TITLE_MARGIN) * 2
        title.x = DIAGRAM_MARGIN
        title.y = DIAGRAM_MARGIN
        diagram.width += title.width
        diagram.height += title.height
      _.each actors, ((a) ->
        bb = paper.text_bbox(a.name, font)
        a.text_bb = bb
        a.x = 0
        a.y = 0
        a.width = bb.width + (ACTOR_PADDING + ACTOR_MARGIN) * 2
        a.height = bb.height + (ACTOR_PADDING + ACTOR_MARGIN) * 2
        a.distances = []
        a.padding_right = 0
        @_actors_height = Math.max(a.height, @_actors_height)
        return
      ), this
      _.each signals, ((s) ->
        a = undefined # Indexes of the left and right actors involved
        b = undefined
        bb = paper.text_bbox(s.message, font)
        
        #var bb = t.attr("text", s.message).getBBox();
        s.text_bb = bb
        s.width = bb.width
        s.height = bb.height
        extra_width = 0
        if s.type is "Signal"
          s.width += (SIGNAL_MARGIN + SIGNAL_PADDING) * 2
          s.height += (SIGNAL_MARGIN + SIGNAL_PADDING) * 2
          if s.isSelf()
            a = s.actorA.index
            b = a + 1
            s.width += SELF_SIGNAL_WIDTH
          else
            a = Math.min(s.actorA.index, s.actorB.index)
            b = Math.max(s.actorA.index, s.actorB.index)
        else if s.type is "Note"
          s.width += (NOTE_MARGIN + NOTE_PADDING) * 2
          s.height += (NOTE_MARGIN + NOTE_PADDING) * 2
          
          # HACK lets include the actor's padding
          extra_width = 2 * ACTOR_MARGIN
          if s.placement is PLACEMENT.LEFTOF
            b = s.actor.index
            a = b - 1
          else if s.placement is PLACEMENT.RIGHTOF
            a = s.actor.index
            b = a + 1
          else if s.placement is PLACEMENT.OVER and s.hasManyActors()
            
            # Over multiple actors
            a = Math.min(s.actor[0].index, s.actor[1].index)
            b = Math.max(s.actor[0].index, s.actor[1].index)
            
            # We don't need our padding, and we want to overlap
            extra_width = -(NOTE_PADDING * 2 + NOTE_OVERLAP * 2)
          else if s.placement is PLACEMENT.OVER
            
            # Over single actor
            a = s.actor.index
            actor_ensure_distance a - 1, a, s.width / 2
            actor_ensure_distance a, a + 1, s.width / 2
            @_signals_height += s.height
            return # Bail out early
        else
          throw new Error("Unhandled signal type:" + s.type)
        actor_ensure_distance a, b, s.width + extra_width
        @_signals_height += s.height
        return
      ), this
      
      # Re-jig the positions
      actors_x = 0
      _.each actors, ((a) ->
        a.x = Math.max(actors_x, a.x)
        
        # TODO This only works if we loop in sequence, 0, 1, 2, etc
        _.each a.distances, (distance, b) ->
          
          # lodash (and possibly others) do not like sparse arrays
          # so sometimes they return undefined
          return  if typeof distance is "undefined"
          b = actors[b]
          distance = Math.max(distance, a.width / 2, b.width / 2)
          b.x = Math.max(b.x, a.x + a.width / 2 + distance - b.width / 2)
          return

        actors_x = a.x + a.width + a.padding_right
        return
      ), this
      diagram.width = Math.max(actors_x, diagram.width)
      
      # TODO Refactor a little
      diagram.width += 2 * DIAGRAM_MARGIN
      diagram.height += 2 * DIAGRAM_MARGIN + 2 * @_actors_height + @_signals_height
      this

    draw_title: ->
      title = @_title
      @draw_text_box title, title.message, TITLE_MARGIN, TITLE_PADDING, @_font  if title
      return

    draw_actors: (offsetY) ->
      y = offsetY
      _.each @diagram.actors, ((a) ->
        
        # Top box
        @draw_actor a, y, @_actors_height
        
        # Bottom box
        @draw_actor a, y + @_actors_height + @_signals_height, @_actors_height
        
        # Veritical line
        aX = getCenterX(a)
        line = @draw_line(aX, y + @_actors_height - ACTOR_MARGIN, aX, y + @_actors_height + ACTOR_MARGIN + @_signals_height)
        line.attr LINE
        return
      ), this
      return

    draw_actor: (actor, offsetY, height) ->
      actor.y = offsetY
      actor.height = height
      @draw_text_box actor, actor.name, ACTOR_MARGIN, ACTOR_PADDING, @_font
      return

    draw_signals: (offsetY) ->
      y = offsetY
      _.each @diagram.signals, ((s) ->
        if s.type is "Signal"
          if s.isSelf()
            @draw_self_signal s, y
          else
            @draw_signal s, y
        else @draw_note s, y  if s.type is "Note"
        y += s.height
        return
      ), this
      return

    draw_self_signal: (signal, offsetY) ->
      assert signal.isSelf(), "signal must be a self signal"
      text_bb = signal.text_bb
      aX = getCenterX(signal.actorA)
      x = aX + SELF_SIGNAL_WIDTH + SIGNAL_PADDING - text_bb.x
      y = offsetY + signal.height / 2
      @draw_text x, y, signal.message, @_font
      attr = _.extend({}, LINE,
        "stroke-dasharray": @line_types[signal.linetype]
      )
      y1 = offsetY + SIGNAL_MARGIN
      y2 = y1 + signal.height - SIGNAL_MARGIN
      
      # Draw three lines, the last one with a arrow
      line = undefined
      line = @draw_line(aX, y1, aX + SELF_SIGNAL_WIDTH, y1)
      line.attr attr
      line = @draw_line(aX + SELF_SIGNAL_WIDTH, y1, aX + SELF_SIGNAL_WIDTH, y2)
      line.attr attr
      line = @draw_line(aX + SELF_SIGNAL_WIDTH, y2, aX, y2)
      attr["arrow-end"] = @arrow_types[signal.arrowtype] + "-wide-long"
      line.attr attr
      return

    draw_signal: (signal, offsetY) ->
      aX = getCenterX(signal.actorA)
      bX = getCenterX(signal.actorB)
      
      # Mid point between actors
      x = (bX - aX) / 2 + aX
      y = offsetY + SIGNAL_MARGIN + 2 * SIGNAL_PADDING
      
      # Draw the text in the middle of the signal
      @draw_text x, y, signal.message, @_font
      
      # Draw the line along the bottom of the signal
      y = offsetY + signal.height - SIGNAL_MARGIN - SIGNAL_PADDING
      line = @draw_line(aX, y, bX, y)
      line.attr LINE
      line.attr
        "arrow-end": @arrow_types[signal.arrowtype] + "-wide-long"
        "stroke-dasharray": @line_types[signal.linetype]

      return

    
    #var ARROW_SIZE = 16;
    #var dir = this.actorA.x < this.actorB.x ? 1 : -1;
    #draw_arrowhead(bX, offsetY, ARROW_SIZE, dir);
    draw_note: (note, offsetY) ->
      note.y = offsetY
      actorA = (if note.hasManyActors() then note.actor[0] else note.actor)
      aX = getCenterX(actorA)
      switch note.placement
        when PLACEMENT.RIGHTOF
          note.x = aX + ACTOR_MARGIN
        when PLACEMENT.LEFTOF
          note.x = aX - ACTOR_MARGIN - note.width
        when PLACEMENT.OVER
          if note.hasManyActors()
            bX = getCenterX(note.actor[1])
            overlap = NOTE_OVERLAP + NOTE_PADDING
            note.x = aX - overlap
            note.width = (bX + overlap) - note.x
          else
            note.x = aX - note.width / 2
        else
          throw new Error("Unhandled note placement:" + note.placement)
      @draw_text_box note, note.message, NOTE_MARGIN, NOTE_PADDING, @_font
      return

    
    ###*
    Draws text with a white background
    x,y (int) x,y center point for this text
    TODO Horz center the text when it's multi-line print
    ###
    draw_text: (x, y, text, font) ->
      paper = @_paper
      f = font or {}
      t = undefined
      if f._obj
        t = paper.print_center(x, y, text, f._obj, f["font-size"])
      else
        t = paper.text(x, y, text)
        t.attr f
      
      # draw a rect behind it
      bb = t.getBBox()
      r = paper.rect(bb.x, bb.y, bb.width, bb.height)
      r.attr
        fill: "#fff"
        stroke: "none"

      t.toFront()
      return

    draw_text_box: (box, text, margin, padding, font) ->
      x = box.x + margin
      y = box.y + margin
      w = box.width - 2 * margin
      h = box.height - 2 * margin
      
      # Draw inner box
      rect = @draw_rect(x, y, w, h)
      rect.attr LINE
      
      # Draw text (in the center)
      x = getCenterX(box)
      y = getCenterY(box)
      @draw_text x, y, text, font
      return
  
  return BaseTheme