
getErrMessage = (responseText) ->
  if !responseText?
    return ''
    
  messages = JSON.parse(responseText)
  message = ''
  for val, i in messages
    message += val
  
  return message

# サーバーサイドから人工知能ボットAPIに
# リクエストを送信して結果取得する
#
send = ->
  inputText = $('#input-text').val()
  if !inputText? || inputText == '' 
    return

  $('#input-text').attr('disabled', true)
    
  $.ajax '/threads/ajax_post',
    type: 'POST'
    data : { inputText: inputText }
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      if jqXHR.responseText?
        alert getErrMessage(jqXHR.responseText)
      else
        alert '予期せぬエラーが発生しました'
        
      $('#input-text').attr('disabled', false)
      $('#input-text').focus()
    success: (data, textStatus, jqXHR) ->
      $('#input-text').val('')
      displayRow data, true, true
      $('#rows').animate({scrollTop: $('#rows')[0].scrollHeight}, 'slow');
      $('#input-text').attr('disabled', false)
      $('#input-text').focus()

# UID生成
#
# @param [Integer] UID生成文字数
# @return [String] UID生成文字列
#
generateId = (len) ->
   result = ''
   for i in [1..len]
     chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
     result += chars.substr Math.floor(Math.random() * chars.length), 1
       
    return result

# Railsのtime型を YYYY-mm-dd hh:mi:ss にフォーマット
#
# @param [String] Rails time型 文字列
# @return [String] フォーマット文字列 (YYYY-mm-dd hh:mi:ss)
#
getDatetimeStr = (dateStr) ->
  dateStr = dateStr.replace('T', ' ')
  return dateStr.substr(0, 19) 
   
# メッセージ行表示
#
# @param [Array] メッセージ行データ
# @param [Boolean] 最終行: true, 最終行以外: false
# @param [Boolean] 追加行: true, 追加行以外: false
#
displayRow = (record, isLast, isAdd) ->
  html = ''
  
  if isAdd
    html += '<hr>'
    
  html += '<div class="row">'
  html += '<p class="post-inf">'
  html += getDatetimeStr record.created_at
  html += ' <span class="person">'
  html += '自分</span>'
  html += '<p class="post-text">'
  html += record.input_text
  html += '</p>'
  html += '</div>'
  
  html += '<hr>'

  html += '<div class="row">'
  html += '<p class="post-inf">'
  html += getDatetimeStr record.created_at
  html += ' <span class="person">'
  html += 'ボット</span>'
  html += '<p class="post-text">'
  html += record.res_text
  html += '</p>'
  html += '</div>'
  
  if !isLast
    html += '<hr>'

  $('#rows').append(html)
  
# メッセージリスト表示
#
# @param [Array] メッセージリストデータ
#
displayList = (results) ->
  $('#rows').html('')
  if !results?
    return
  
  for i in [0..results.length - 1]
    isLast = false
    if i == results.length - 1
      isLast = true

    displayRow results[i], isLast, false
  
$ ->
  # リストの高さ調整
  listHeight = $(window).height() - $('.fotter').height() - 35;
  $('#rows').css('height', listHeight)
  
  # クッキーからUID取得(なければ生成)
  uid = $.cookie('uid')
  if !uid?
    uid = generateId(20)
    $.cookie('uid', uid, { expires: 30 });
  
  # 初期メッセージリスト非同期取得表示
  $.ajax '/threads/ajax_list',
    type: 'GET'
    data : { uid: uid }
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      alert "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if !data?
        return
        
      displayList data
      $('#rows').animate({scrollTop: $('#rows')[0].scrollHeight}, 'fast');
  
  # メッセージ入力テキストでEnterキー送信
  $('#input-text').on 'keypress', (event) ->
     if event.which == 13
       send()
       return false
