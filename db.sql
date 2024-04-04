-- INIT
CREATE TABLE IF NOT EXISTS mio_identities (
    id      VARCHAR(256),
    data    BLOB,
    PRIMARY KEY(id)
);

-- GET_IDENTITIES
SELECT data FROM mio_identities

-- GET_IDENTITY
SELECT data FROM mio_identities WHERE id=:id

-- DEL_IDENTITY
DELETE FROM mio_identities WHERE id=:id

-- SET_IDENTITY
INSERT INTO mio_identities(id,data) VALUES(:id,:data)
    ON CONFLICT(id) DO UPDATE SET data=:data
	WHERE id=:id

-- INIT
CREATE TABLE IF NOT EXISTS mio_configs (
    node    VARCHAR(128) NOT NULL, 
    k       VARCHAR(64) NOT NULL, 
    s       VARCHAR(64) NOT NULL,
    i       INTEGER NOT NULL,
    b       BLOB,
    CONSTRAINT pk_safe_key PRIMARY KEY(node,k)
);

-- GET_CONFIG
SELECT s, i, b FROM mio_configs WHERE node=:node AND k=:key

-- SET_CONFIG
INSERT INTO mio_configs(node,k,s,i,b) VALUES(:node,:key,:s,:i,:b)
	ON CONFLICT(node,k) DO UPDATE SET s=:s,i=:i,b=:b
	WHERE node=:node AND k=:key

-- DEL_CONFIG
DELETE FROM mio_configs WHERE node=:node


-- INIT
CREATE TABLE IF NOT EXISTS mio_files (
    id VARCHAR(256) PRIMARY KEY,
    storeUrl    VARCHAR(256),
    name        VARCHAR(256),
    dir         VARCHAR(4096),
    creator     VARCHAR(256),
    groupName   VARCHAR(256),
    tags        VARCHAR(4096),
    modTime     INTEGER,
    size        INTEGER,
    attributes  BLOB,
    zipped INTEGER,
    localPath VARCHAR(4096)
);

-- INIT
CREATE INDEX IF NOT EXISTS idx_mio_files_dir ON mio_files(dir)

-- INIT
CREATE INDEX IF NOT EXISTS idx_mio_files_groupName ON mio_files(groupName)

-- INIT
CREATE INDEX IF NOT EXISTS idx_mio_files_tags ON mio_files(tags)

-- INIT
CREATE INDEX IF NOT EXISTS idx_mio_files_modTime ON mio_files(modTime)

-- INIT
CREATE INDEX IF NOT EXISTS idx_mio_files_name ON mio_files(name)

-- INSERT_FILE
INSERT INTO mio_files(id,storeUrl,name,dir,creator,groupName,tags,modTime,size,attributes) 
    VALUES(:id,:storeUrl,:name,:dir,:creator,:groupName,:tags,:modTime,:size,:attributes)
    ON CONFLICT(id) DO UPDATE SET storeUrl=:storeUrl,name=:name,dir=:dir,groupName=:groupName,tags=:tags,modTime=:modTime,size=:size,attributes=:attributes
    WHERE id=:id

-- GET_LAST_ID
SELECT id FROM mio_files WHERE dir=:dir ORDER BY id DESC LIMIT 1

-- GET_FILES_BY_DIR
SELECT id,name,dir,groupName,tags,modTime,size,creator,attributes,zipped,localPath,encryptionKey FROM mio_files 
    WHERE storeUrl=storeUrl AND dir=:dir
    AND (:groupName = '' OR groupName = :groupName)
    AND (:tag = '' OR tag LIKE '% ' || :tag || ' %')
    AND (:creator = '' OR creator = :creator)
    AND (:before < 0 OR modTime < :before)
    AND (:after < 0 OR modTime > :after)
    AND (:prefix = '' OR name LIKE :prefix || '%')
    AND (:suffix = '' OR name LIKE '%' || :suffix)
    #ORDER_BY
    LIMIT CASE WHEN :limit = 0 THEN -1 ELSE :limit END OFFSET :offset

-- GET_GROUP_NAME 
SELECT DISTINCT groupName FROM mio_files WHERE storeUrl=:storeUrl AND dir = :dir AND name = :name 