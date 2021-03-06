# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
　# only books_controller
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

        window.book_edit_total_result = total_result
        window.book_edit_total_incomes = total_incomes
        window.book_edit_total_receipts = total_receipts

        showing_balance(total_receipts, total_incomes, total_result)

      # end fail()
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
      if isNaN(pay_date)
        return
      if isNaN(price)
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
      # end setting path
    
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
          row_text = new_row.html
          #$tr = $parent.append(row_text)
          $tr = $(row_text)
          $tr.appendTo($parent)
          
          
          # sort table
          $parent.closest('table').trigger("update")
          # new item from goes to the last
          $newrow = $parent.children('.book_edit_table_new_row').first().appendTo($parent)
          # focus to new input
          $newrow.find('input').first().focus()
          # scroll to the target
          $("html,body").animate( { scrollTop: $newrow.offset().top } )

          # reset events
          setting_events_of_cell($tr)
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
        alert('データの更新に失敗しました。')
      
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

      # calc balance
      # calc after DOM remove
      window.setTimeout(calc_balance, 1000)
        
      .fail (data) ->
        alert('データの削除に失敗しました。')
    # end delete_btn_on_click

    # the function that is setting events of cell when DOM is created.
    # DOM要素が追加された際にイベントを設定する関数
    # do not fire events when this script is called by 'show' action.
    # show メソッドの場合は、編集できないようにするため、イベントを呼び出さない。
    if( $('body').data('action') != "show")
      setting_events_of_cell = ($row) ->
        
        # on click delete btn
        $row.find('.book_edit_delete_btn').each ->
          $btn = $(this)
          $btn.on 'click', ->
            delete_btn_on_click(this)
        # end delete btn on click

        # set same width to cells and inputs
        # セルとinputのサイズを合わせる
        set_width_to_cells_and_inputs = ($cell) ->
          $input = $cell.children('input').first()
          $input.width( $cell.width() )
        # end set_width_to_cells_and_inputs()
      
        # set width on load
        # セル内のテキストとテキストボックスの幅を揃える
        $row.find('.book_edit_cell').each ->
          set_width_to_cells_and_inputs( $(this) )
        # end $row.find('.book_edit_cell').each
  
        # on focus edit cell
        # toggle to show the input and hide the text
        # セルをクリックするとinputに切り替える
        $row.find('.book_edit_cell').each ->
          $(this).on 'click', ->
            $this = $(this)
            # remove editting class which other cells have
            $('.editting').removeClass('editting')
            # set editting class to myself
            $this.addClass('editting')
            # focus on my input
            $this.children('input').first().focus()
          # end
        # end
    
        $row.find('.book_edit_cell_input').each ->
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
          # end blur
        # end edit_input each
      # end setting_events_of_cell()
    
      # on press Tab button
      # on show action, not fire this event.
      document.addEventListener 'keydown', (e) ->
        # Tab or Enter
        if e.keyCode == 9 || e.keyCode == 13
          target = document.activeElement
          $target = $(target)
          if $target.prop("tagName") == 'INPUT'
            $editcells = $target.closest('table').find('.book_edit_cell')
            $targetcell = $target.closest('.book_edit_cell')
            cellindex = $editcells.index($targetcell)
            $nextcell = $editcells.eq(cellindex + 1)
          
            if $editcells.length == cellindex + 1
              # go to new input
              target.blur()
              $nextcell = $target.closest('.book_edit_table_new_row')
              .children('.column_pay_date').first()
            # end
            
            # scroll to the target
            $nexttarget = $nextcell.addClass('editting').find('input').first()
            $("html,body").animate( { scrollTop: $nextcell.offset().top } )
            $nexttarget.focus()
          # end
          e.preventDefault()
        # end
      # end document.addEventListener
    # end if( $('body').data('action') != "show")

    # initial setting events
    $('.book_edit_table_row').each ->
      setting_events_of_cell( $(this) )
    # end

    $('.book_edit_table_new_row').each ->
      setting_events_of_cell( $(this) )
    # end

    #------------------------------------------------------------------------------
    # function for books/index
    #------------------------------------------------------------------------------

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
        # end
        
        $book_name_area.find('.books_index_book_name').text(book_name)
        $this.text('名前変更')
      else
        $this.text('送信')
      # end
      
      $this.toggleClass('active')
    # end edit name of books btn on click

    # function called when '.allow_show_checkbox' are changed.
    $('.allow_show_checkbox').on 'change', ->
      $this = $(this)
      $book_names = $this.parents('.books_index_name_row').first().
      children('.books_index_names').first()
      book_id = parseInt( $book_names.data('bookid') )
      if $this.prop('checked')
        allow_flag = 'true'
      else
        allow_flag = 'false'
      #end

      $.ajax({
          url: "/books/#{book_id}",
          type: 'patch',
          data: {
            show_flag: allow_flag
          }
      })
      .done (data) ->
        result = JSON.parse(data)
      .fail (data) ->
        alert('データの送信に失敗しました。')
      # end
    # end .allow_show_checkbox on change

  # end controller books
      