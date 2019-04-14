# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('.store_edit_form').on 'submit', (e) ->
    $this = $(this)
    window.store_index_myname = $this.closest('tr').find('.store_name').val()
    window.store_index_samename_count = 0
    $this.closest('tbody').find('tr').each ->
      if $(this).find('.store_name').val() == window.store_index_myname
        window.store_index_samename_count++
    
    #if window.store_index_samename_count > 1
    #  alert('店舗名は重複してしてできません。')
    #  return false
    # end
  # end
# end