app.dao.CardDAO = (db)->
  @db = db
  this

_.extend app.dao.CardDAO::,
  create: (user_id, image_url, audio_url, message, callback)->
    self = this
    @db.transaction ((tx) ->
      console.log "Inserting cards"
      sql = "INSERT INTO cards (user_id,image_url,audio_url,message,deleted,created_at,updated_at) VALUES " +
      "(:user_id,:image_url,:audio_url,:message,0,:created_at,:updated_at)"
      now = (new Date()).Format('yyyy-MM-dd hh:mm:ss')
      tx.executeSql sql, [user_id, image_url, audio_url, message, now, now]

    ), @txErrorHandler, (tx) ->
      self.db.transaction ((tx) ->
        sql = "SELECT MAX(id) as id FROM cards WHERE deleted != 1"
        tx.executeSql sql, [], (tx, results) ->
          callback (if results.rows.length is 1 then results.rows.item(0) else null)

      ), self.txErrorHandler

  synchronized: (id, callback)->
    @db.transaction ((tx) ->
      sql = "UPDATE cards SET synchronized = 1 WHERE id = :id "
      tx.executeSql sql, [id]

    ), @txErrorHandler, (tx) ->
      callback()

  deleteById: (id, callback)->
    @db.transaction ((tx) ->
      sql = "UPDATE cards SET deleted = 1 WHERE id = :id "
      tx.executeSql sql, [id]

    ), @txErrorHandler, (tx) ->
      callback()

  findByUser: (id, callback)->
    @db.transaction ((tx) ->
      sql = "SELECT id,user_id,image_url,audio_url,message,synchronized,updated_at " +
      "FROM cards WHERE deleted != 1 and user_id in ('0', :id) ORDER BY updated_at DESC"

      tx.executeSql sql, [id], (tx, results) ->
        len = results.rows.length
        cards = []
        i = 0
        while i < len
          cards[i] = results.rows.item(i)
          i = i + 1
        callback cards

    ), @txErrorHandler

  findById: (id, callback) ->
    @db.transaction ((tx) ->
      sql = "SELECT image_url,audio_url FROM cards WHERE id=:id AND deleted != 1"
      tx.executeSql sql, [id], (tx, results) ->
        callback (if results.rows.length is 1 then results.rows.item(0) else null)

    ), @txErrorHandler

  txErrorHandler: (tx) ->
    app.utils.notification.showAlert tx.message, "Transaction Error"