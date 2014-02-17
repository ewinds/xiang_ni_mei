app.dao.TopicDAO = (db)->
  @db = db
  this

_.extend app.dao.TopicDAO::,
  findByCollection: (key, callback)->
    @db.transaction ((tx) ->
      sql = "SELECT id,title,desp,image_url " +
      "FROM topics WHERE collection_id = :id AND deleted != 1 ORDER BY id"

      tx.executeSql sql, [key], (tx, results) ->
        len = results.rows.length
        topics = []
        i = 0
        while i < len
          topics[i] = results.rows.item(i)
          i = i + 1
        callback topics

    ), @txErrorHandler

  findById: (id, callback) ->
    @db.transaction ((tx) ->
      sql = "SELECT title,desp,image_url,bg_url,config_data FROM topics WHERE id=:id AND deleted != 1"
      tx.executeSql sql, [id], (tx, results) ->
        callback (if results.rows.length is 1 then results.rows.item(0) else null)

    ), @txErrorHandler

  txErrorHandler: (tx) ->
    app.utils.notification.showAlert tx.message, "Transaction Error"
