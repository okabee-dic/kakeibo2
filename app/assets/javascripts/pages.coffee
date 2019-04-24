# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  # common script for all pages
  #get CSRF token
  $.ajaxPrefilter (options, originalOptions, jqXHR) ->
    if (!options.crossDomain) 
      token = $('meta[name="csrf-token"]').attr('content')
      if (token) 
        return jqXHR.setRequestHeader('X-CSRF-Token', token)
  
  # match height class
  mh_class_callback = ->
    $('.mh').each ->
      $(this).siblings('.mh').each (index, elem) =>
        $this = $(this)
        elem_height = $(elem).height()
        if elem_height > $this.height()
          $this.height( elem_height )
        # end
      # end
    # end
  # end

  mh_class_callback()

  $('window').on 'resize', ->
    mh_class_callback()
  # end

  # separated area accordion
  $('.separated_area').each ->
    $this = $(this)
    $this.children('.caption').first().on 'click', ->
      $this = $(this)
      $this.parent().find('.separated_area_content').first().slideToggle()
      $this.parent().toggleClass('hide')
    # end
    $this.width( $this.find('.separated_area_content').first().outerWidth() )

    if $this.hasClass('hide')
      $this.find('.separated_area_content').first().slideUp()
    # end
  # end

