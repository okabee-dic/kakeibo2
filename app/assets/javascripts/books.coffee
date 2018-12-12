# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  # get CSRF token
  $.ajaxPrefilter (options, originalOptions, jqXHR) ->
    if (!options.crossDomain) 
      token = $('meta[name="csrf-token"]').attr('content')
      if (token) 
        return jqXHR.setRequestHeader('X-CSRF-Token', token)
        
  # create pathes
  income_path = location.pathname.replace(/\/edit$/, "/incomes")
  receipt_path = location.pathname.replace(/\/edit$/, "/receipts")
  
  # start tablesorter
  $('#book_edit_receipts table').tablesorter({
    textSorter : {
      1: (a, b, direction, column, table) ->
        if (table.config.sortLocaleCompare) 
          return a.localeCompare(b) 
        return ((a < b) ? -1 : ((a > b) ? 1 : 0))
    }
  })
        
  $('#book_edit_main .book_edit_send_btn').each ->
    $btn = $(this)
    
    $btn.on 'click', ->
      $this = $(this)
      $parent = $this.closest('tr')
      pay_date = $parent.find('.column_pay_date').first().val()
      store = $parent.find('.column_store').first().val()
      price = $parent.find('.column_price').first().val()
      type = $this.data('rowtype')
      row_id = $this.data('rowid')
      year = $('#book_edit_main').data('year')
      month = $('#book_edit_main').data('month')
      
      # create path
      # create or update, destroy is in another function
      if row_id == -1
        # create
        method = 'POST'
        if type == 'income'
          path = income_path
        else
          path = receipt_path
      else
        #update
        method = 'PATCH'
        if type == 'income'
          path = "#{income_path}/#{row_id}"
        else
          path = "#{receipt_path}/#{row_id}"
        
      $.ajax({
        url: path,
        type: method,
        data: {
          "pay_date": pay_date,
          "store": store,
          "price": price,
          "type": type,
          "row_id": row_id,
          "year": year,
          "month": month
        }
      })
      .done (data) ->
        new_row = JSON.parse(data)
        if(new_row.type == 'income')
          $parent = $('#book_edit_incomes > .book_edit_table tbody')
        else
          $parent = $('#book_edit_receipts > .book_edit_table tbody')
       
        day = parseInt( new_row.pay_date.replace(/.*-/, '') )
        store = new_row.store_name
        price = new_row.price
        id = new_row.id
        type = new_row.type
        
        # if create
        if(new_row.row_id == -1)
          # clear input form
          $parent.children('.book_edit_table_new_row').find('input').each ->
            $(this).val('')
          # create new item
          row_text = "<tr class=\"book_edit_table_row\" data-rowid=\"#{id}\">
                  <td><input class=\"column_pay_date\" value=\"#{day}\"></td>
                  <td><input class=\"column_store\" value=\"#{store}\"></td></td>
                  <td><input class=\"column_price\" value=\"#{price}\"></td>
                  <td>
                    <button class=\"book_edit_send_btn\" data-rowid=\"#{id}\" data-rowtype=\"#{type}\">send</button>
                    <button class=\"book_edit_delete_btn\" data-rowid=\"#{id}\" data-rowtype=\"#{type}\">delete</button>
                  </td>
                </tr>"
          $parent.append(row_text)
          # sort table
          #$parent.closest('table')
          # new item from goes to the last
          $parent.children('.book_edit_table_new_row').first().appendTo($parent)
        else
          # update item
          row = $parent.children("[data-rowid=#{id}]").first()
          row.find('.column_pay_date').first().val(day)
          row.find('.column_store').first().val(store)
          row.find('.column_price').first().val(price)
              
      .fail (data) ->
        console.log('error:'+ data)
        
  $('#book_edit_main .book_edit_delete_btn').each ->
    $btn = $(this)
    
    $btn.on 'click', ->
      $this = $(this)
      #$parent = $this.closest('tr')
      type = $this.data('rowtype')
      row_id = $this.data('rowid')
      
      if type == 'income'
        path = "#{income_path}/#{row_id}"
      else
        path = "#{receipt_path}/#{row_id}"
      
      $.ajax({
        url: path,
        type: 'DELETE',
        data: {
          "type": type,
          "row_id": row_id
        }
      })
      .done (data) ->
        delete_row = JSON.parse(data)
        
        id = delete_row.row_id
        type = delete_row.type
        
        if(type == 'income')
          $parent = $('#book_edit_incomes > .book_edit_table tbody')
        else
          $parent = $('#book_edit_receipts > .book_edit_table tbody')
          
        $parent.children("[data-rowid=\"#{id}\"]").remove()
        
      .fail (data) ->
        console.log('error:'+ data)