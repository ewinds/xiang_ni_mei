app.dao.BaseDAO = (db)->
  @db = db
  this

_.extend app.dao.BaseDAO::,
  initialize: (callback) ->
    self = this
    @isInitialized (result) ->
      if result
        callback()
      else
        self.createTable ->
          self.populate callback

# Check if employee table exists
  isInitialized: (callback) ->
    self = this
    @db.transaction ((tx) ->
      sql = "SELECT name FROM sqlite_master WHERE type='table' AND name=:tableName"
      tx.executeSql sql, ["collections"], (tx, results) ->
        if results.rows.length is 1
          console.log "Database is initialized"
          callback true
        else
          console.log "Database is not initialized"
          callback false

    ), @txErrorHandler

# Create Employee table
  createTable: (callback) ->
    self = this
    @db.transaction ((tx) ->
      sql = "CREATE TABLE IF NOT EXISTS collections ( " +
      "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
      "title varchar(255), " +
      "desp varchar(255), " +
      "image_url varchar(255), " +
      "deleted integer, " +
      "created_at datetime, " +
      "updated_at datetime)"
      console.log "Creating COLLECTIONS table"
      tx.executeSql sql

      sql = "CREATE TABLE IF NOT EXISTS topics ( " +
      "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
      "collection_id integer, " +
      "title varchar(255), " +
      "desp varchar(255), " +
      "image_url varchar(255), " +
      "bg_url varchar(255), " +
      "config_data varchar(255), " +
      "deleted integer, " +
      "created_at datetime, " +
      "updated_at datetime)"
      console.log "Creating TOPICS table"
      tx.executeSql sql

      sql = "CREATE TABLE IF NOT EXISTS cards ( " +
      "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
      "user_id integer, " +
      "image_url varchar(255), " +
      "audio_url varchar(255), " +
      "message varchar(255), " +
      "deleted integer, " +
      "synchronized integer, " +
      "created_at datetime, " +
      "updated_at datetime)"
      console.log "Creating CARDS table"
      tx.executeSql sql

    ), @txErrorHandler, (tx) ->
      callback()

# Populate employee table with ample data for ou-of-the-box experience
  populate: (callback) ->
    @db.transaction ((tx) ->
      console.log "Inserting collections"
      tx.executeSql "INSERT INTO collections (id,title,desp,image_url,deleted,created_at,updated_at) VALUES " +
      "(1,'爱情','Love','images/collection1.png',0,'2010-06-0319:01:19','2010-06-0319:01:19')"
      tx.executeSql "INSERT INTO collections (id,title,desp,image_url,deleted,created_at,updated_at) VALUES " +
      "(2,'友情','Friend ship','images/collection2.png',0,'2010-06-0319:01:19','2010-06-0319:01:19')"
      tx.executeSql "INSERT INTO collections (id,title,desp,image_url,deleted,created_at,updated_at) VALUES " +
      "(3,'祝福','Greeting','images/collection3.png',0,'2010-06-0319:01:19','2010-06-0319:01:19')"
      tx.executeSql "INSERT INTO collections (id,title,desp,image_url,deleted,created_at,updated_at) VALUES " +
      "(4,'DIY','Do it yourself','images/collection4.png',0,'2010-06-0319:01:19','2010-06-0319:01:19')"

      console.log "Inserting topics"
      tx.executeSql "INSERT INTO topics (id,collection_id,title,desp,image_url,bg_url,config_data,deleted,created_at,updated_at) VALUES " +
      "(1,1,'心心相印','','images/topic1.png','images/topic1_bg.png','',0,'2010-06-0319:01:19','2010-06-0319:01:19')"
      tx.executeSql "INSERT INTO topics (id,collection_id,title,desp,image_url,bg_url,config_data,deleted,created_at,updated_at) VALUES " +
      "(2,1,'情人节快乐','','images/topic2.png','','',0,'2010-06-0319:01:19','2010-06-0319:01:19')"
      tx.executeSql "INSERT INTO topics (id,collection_id,title,desp,image_url,bg_url,config_data,deleted,created_at,updated_at) VALUES " +
      "(3,1,'I Miss You','','images/topic3.png','','',0,'2010-06-0319:01:19','2010-06-0319:01:19')"
      tx.executeSql "INSERT INTO topics (id,collection_id,title,desp,image_url,bg_url,config_data,deleted,created_at,updated_at) VALUES " +
      "(4,1,'魂牵梦绕','','images/topic4.png','','',0,'2010-06-0319:01:19','2010-06-0319:01:19')"
      tx.executeSql "INSERT INTO topics (id,collection_id,title,desp,image_url,bg_url,config_data,deleted,created_at,updated_at) VALUES " +
      "(5,1,'I Love You','','images/topic5.png','','',0,'2010-06-0319:01:19','2010-06-0319:01:19')"
      tx.executeSql "INSERT INTO topics (id,collection_id,title,desp,image_url,bg_url,config_data,deleted,created_at,updated_at) VALUES " +
      "(6,1,'Yes, I Do','','images/topic6.png','','',0,'2010-06-0319:01:19','2010-06-0319:01:19')"

    ), @txErrorHandler, (tx) ->
      callback()

  dropTable: (callback) ->
    @db.transaction ((tx) ->
      console.log "Dropping EMPLOYEE table"
      tx.executeSql "DROP TABLE IF EXISTS employee"
    ), @txErrorHandler, ->
      console.log "Table employee successfully DROPPED in local SQLite database"
      callback()

  reset: (callback) ->
    self = this
    @dropTable ->
      self.createTable ->
        callback()

  txErrorHandler: (tx) ->
    app.utils.notification.showAlert tx.message, "Transaction Error"