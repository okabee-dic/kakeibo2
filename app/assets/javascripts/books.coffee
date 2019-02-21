# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  if $('body').data('controller') == 'books'
    # create pathes
    self_path = location.pathname.replace(/\/edit.*$/, "/edit")
    income_path = self_path.replace(/\/edit$/, "/incomes")
    receipt_path = self_path.replace(/\/edit$/, "/receipts")
  
    # start tablesorter
    $('#book_edit_receipts table').tablesorter({
      theme: 'blue',
      sortList: [[0, 0], [1, 0]]
    })
    $('#book_edit_incomes table').tablesorter({
      theme: 'blue',
      sortList: [[0, 0], [1, 0]]
    })
  
    # add separates to price
    # カンマ区切りを追加する関数
    add_separates = (num) ->
      return String(num).replace( /(\d)(?=(\d\d\d)+(?!\d))/g, '$1,')

    # calculate the balance
    # データが変更された際に収支を計算する関数
    calc_balance = ->
      year = $('#book_edit_main').data('year')
      month = $('#book_edit_main').data('month')

      $.ajax({
        url: location.pathname.replace(/\/edit.*$/, "/get_balance"),
        type: 'POST',
        data: {
          "year": year,
          "month": month,
          "target": 'all'
        }
      })
      .done (data) ->
        # parse json and setting price from json
        result = JSON.parse(data)
        total_result = result.balance
        total_incomes = result.incomes
        total_receipts = result.receipts

        showing_balance(total_receipts, total_incomes, total_result)

      .fail (jqXHR, textStatus, errorThrown) ->
        # in error, calc from local DOM elements
        total_receipts = 0
        total_incomes = 0

        $('#book_edit_receipts .column_price input').each ->
          price = parseInt( $(this).val() )
          unless Number.isInteger(price)
            price = 0
          total_receipts += price
        $('#book_edit_incomes .column_price input').each ->
          price = parseInt( $(this).val() )
          unless Number.isInteger(price)
            price = 0
          total_incomes += price

        total_result = total_incomes - total_receipts
        # end

        window.book_edit_total_result = total_result
        window.book_edit_total_incomes = total_incomes
        window.book_edit_total_receipts = total_receipts

        showing_balance(total_receipts, total_incomes, total_result)

      # end fail
    # end calc_balance

    # the function showing the balance
    # 収支を表示する関数
    showing_balance = (total_receipts, total_incomes, total_result) ->
      # add separates to prices and set prices to view
      if (total_result < 0)
        total_result = "▲#{ add_separates( -1 * total_result ) }"
      else
        total_result = add_separates(total_result)
        
      $total_view = $('#book_edit_total_view')
      $total_view.find('#book_edit_total_receipts .total_price').first()
      .text( add_separates(total_receipts) )

      $total_view.find('#book_edit_total_incomes .total_price').first()
      .text( add_separates(total_incomes) )

      $total_view.find('#book_edit_total_result .total_price').first()
      .text( total_result )
    # end showing_balance

    # function of update receipts
    # 変更されたデータを送信する関数
    update_receipts = ($parent) ->
      pay_date = $parent.find('.column_pay_date > input').first().val()
      store = $parent.find('.column_store > input').first().val()
      price = $parent.find('.column_price > input').first().val()
      type = $parent.data('rowtype')
      row_id = $parent.data('rowid')
      year = $('#book_edit_main').data('year')
      month = $('#book_edit_main').data('month')
    
      # data validation
      if pay_date == ""
        return
      if store == ""
        return
      if price == ""
        return
      
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
          $input_row = $parent.children('.book_edit_table_new_row')
          $input_row.find('input').each ->
            $(this).val('')
          $input_row.find('.book_edit_cell_text').each ->
            $(this).text('')
          # create new item
          row_text = "<tr class=\"book_edit_table_row\" data-rowid=\"#{id}\" data-rowtype=\"#{type}\">
                <td class=\"book_edit_cell column_pay_date\">
                  <span class=\"book_edit_cell_text\">#{day}</span>
                  <input class=\"book_edit_cell_input\" value=\"#{day}\">
                </td>
                <td class=\"book_edit_cell column_store\">
                  <span class=\"book_edit_cell_text\">#{store}</span>
                  <input class=\"book_edit_cell_input\" value=\"#{store}\">
                </td>
                <td class=\"book_edit_cell column_price\">
                  <span class=\"book_edit_cell_text\">#{add_separates(price)}</span>
                  <input class=\"book_edit_cell_input\" value=\"#{price}\">
                </td>
                <td>
                  <button class=\"book_edit_delete_btn\" data-rowid=\"#{id}\" data-rowtype=\"#{type}\">delete</button>
                </td>
              </tr>"
          $parent.append(row_text)
          
          # sort table
          $parent.closest('table').trigger("update")
          # new item from goes to the last
          $parent.children('.book_edit_table_new_row').first().appendTo($parent)
          # reset events
          setting_events_of_cell()
        else
          # update item
          row = $parent.children("[data-rowid=#{id}]").first()
          row.find('.column_pay_date > input').first().val(day).siblings('.book_edit_cell_text')
          .text(day)
          row.find('.column_store > input').first().val(store).siblings('.book_edit_cell_text')
          .text(store)
          row.find('.column_price > input').first().val(price).siblings('.book_edit_cell_text')
          .text( add_separates(price) )
        
        # calc balance on either events
        # calc after DOM edit
        window.setTimeout(calc_balance, 1000)
              
      .fail (data) ->
        console.log('error:' + data)
      
    # end update_receipts
  
    # method of delete button on click
    # 削除ボタンをクリックしたときに呼ばれる関数
    delete_btn_on_click = (btn) ->
      $this = $(btn)
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
        
        # row_id from server is the same as sending row_id
        id = delete_row.row_id
        type = delete_row.type
        
        if(type == 'income')
          $parent = $('#book_edit_incomes > .book_edit_table tbody')
        else
          $parent = $('#book_edit_receipts > .book_edit_table tbody')
          
        $parent.children("[data-rowid=\"#{id}\"]").remove()

      # reset events
      setting_events_of_cell()

      # calc balance
      # calc after DOM remove
      window.setTimeout(calc_balance, 1000)
        
      .fail (data) ->
        console.log('error:' + data)
    # end delete_btn_on_click

    # the function that is setting events of cell when DOM is created.
    # DOM要素が追加された際にイベントを設定する関数
    setting_events_of_cell = ->
      # on click delete btn
      $('#book_edit_main .book_edit_delete_btn').each ->
        $btn = $(this)
        $btn.on 'click', ->
          delete_btn_on_click(this)
      # end delete btn on click

      # set same width to cells and inputs
      # セルとinputのサイズを合わせる
      set_width_to_cells_and_inputs = ($cell) ->
        $input = $cell.children('input').first()
        $input.width( $cell.width() )
    
      # set width on load
      $('.book_edit_cell').each ->
        set_width_to_cells_and_inputs( $(this) )

      # set width on resize
      $('.book_edit_cell').on 'resize' , ->
        set_width_to_cells_and_inputs( $(this) )

      # on focus edit cell
      # toggle to show the input and hide the text
      # セルをクリックするとinputに切り替える
      $('.book_edit_cell').each ->
        $(this).on 'click', ->
          $this = $(this)
          # remove editting class which other cells have
          $('.editting').removeClass('editting')
          # set editting class to myself
          $this.addClass('editting')
          # focus on my input
          $this.children('input').first().focus()
  
      $('.book_edit_cell_input').each ->
        # on focus out, send data and toggle showing of input and text
        # inputからフォーカスが外れると編集したデータを送信
        # 送信後、inputを非表示にしてテキストを表示する
        $(this).on 'blur', ->
          $this = $(this)
          # if price, add separates
          if $this.parents('.column_price').length
            value = add_separates( $this.val() )
          else
            value = $this.val()
    
          # Hide input on focus out
          $this.closest('.editting').removeClass('editting')
          .children('.book_edit_cell_text').first().text( value )
      
          # post input
          $row = $this.closest('tr')
          update_receipts($row)

          # resize input width to new cell width
          $this.closest('tbody').find('.book_edit_cell').each ->
            set_width_to_cells_and_inputs( $(this) )

      
      
    # end setting_events_of_cell

    # initial setting events
    setting_events_of_cell()

    # this function is for books/index
    # edit name of books btn on click
    # books/indexで名前を変更した際に送信する
    $('.books_index_edit_name_btn').on 'click', ->
      $this = $(this)
      $book_names = $this.parents('.books_index_name_row').first().
      children('.books_index_names').first()

      book_id = parseInt( $book_names.data('bookid') )
      # toggle class 'active'
      $book_name_input_area = $book_names.children('.books_index_edit_name_input_area').first()
      .toggleClass('active')

      $book_name_area = $book_names.children('.books_index_name_area').first().toggleClass('active')
      
      # changing name and sending name
      if $this.hasClass('active')
        # sending name
        book_name = $book_name_input_area.find('input').first().val()
        $.ajax({
          url: "/books/#{book_id}",
          type: 'patch',
          data: {
            name: book_name
          }
        })
        .done (data) ->
          result = JSON.parse(data)
        
        $book_name_area.find('.books_index_book_name').text(book_name)
        $this.text('名前変更')
      else
        $this.text('送信')
      
      $this.toggleClass('active')
    # end edit name of books btn on click

  # end controller books
      