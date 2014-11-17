define [ "seq_diagram/base_theme", "seq_diagram/d3_theme"], (BaseTheme, D3Theme) ->
  
  class RaphaelTheme extends BaseTheme
    init_font : ->
      @_font = 
        'font-size': 16,
        'font-family': 'Andale Mono, monospace'
      
    

  class HandRaphaelTheme extends BaseTheme


  class Theme
    @themes = 
      simple : RaphaelTheme,
      hand  : HandRaphaelTheme
      d3    :  D3Theme
    @getTheme: (themeName)->
      throw new Error("Unsupported theme: " + themeName)  unless themeName of @themes      
      return @themes[themeName]
    
      
  return Theme
