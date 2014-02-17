app.dao.CollectionDAO = (db)->
  @db = db
  this

_.extend app.dao.CollectionDAO::,
  findAll: (callback)->
    @db.transaction ((tx) ->
      sql = "SELECT c.id,c.title,c.desp,c.image_url,count(t.id) topic_count " +
      "FROM collections c LEFT JOIN topics t ON c.deleted != 1 and c.id = t.collection_id GROUP BY c.id ORDER BY c.id"

      tx.executeSql sql, [], (tx, results) ->
        len = results.rows.length
        collections = []
        i = 0
        while i < len
          collections[i] = results.rows.item(i)
          i = i + 1
        callback collections

    ), @txErrorHandler

  findById: (id, callback) ->
    @db.transaction ((tx) ->
      sql = "SELECT title,desp,image_url FROM collections WHERE id=:id AND deleted != 1"
      tx.executeSql sql, [id], (tx, results) ->
        callback (if results.rows.length is 1 then results.rows.item(0) else null)

    ), @txErrorHandler

  txErrorHandler: (tx) ->
    app.utils.notification.showAlert tx.message, "Transaction Error"

