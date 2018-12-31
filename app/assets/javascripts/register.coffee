$ ->
  controller = $('body').first().data('controller')
  action = $('body').first().data('action')

  # only exec on registrations controller
  if controller == 'registrations'
    if action == 'new' || action == 'edit' || action == 'create' || action == 'update'
      $('#postcode').jpostal({
        postcode: $('#postcode'),
        address: {
                 "#user_prefecture_name": "%3", # 都道府県が入力される
                 "#address": "%4%5%6", # 市区町村と町域が入力される
                 "#building": "%7" # 大口事務所の番地と名称が入力される
               }
      })
  
    # check_username
    $('#username').on 'input', ->
      username = $('#username').val()
      $.post( '/users/check_username', 'username='+ username )
      .done (data) ->
        result = $.parseJSON(data)
      
        show_text = ''
        if result.message == 'exists'
          show_text = 'すでに利用されています。'
        if result.message == 'you'
          show_text = '現在のユーザー名です。'
        if result.message == 'invalid'
          show_text = '使用できる文字は半角英数字と-_のみで、4文字以上が必要です。'
        if result.message == 'available'
          show_text = '利用可能です。'
        
        $('#username_checkresult').text(show_text)
      
      .fail (jqXHR, textStatus, errorThrown) ->
        $('#username_checkresult').text('通信エラーです。')