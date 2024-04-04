package safe

import (
	"github.com/stregato/mio/lib/core"
	"github.com/stregato/mio/lib/sqlx"
	"github.com/vmihailenco/msgpack/v5"
)

func GetConfig(db *sqlx.DB, node string, key string) (s string, i int64, v []byte, ok bool) {
	err := db.QueryRow("GET_CONFIG", sqlx.Args{"node": node, "key": key}, &s, &i, &v)
	switch err {
	case sqlx.ErrNoRows:
		ok = false
	case nil:
		ok = true
	default:
		core.IsErr(err, "cannot get config for %s/%s: %v", node, key)
		ok = false
	}
	core.Trace("SQL: GET_CONFIG: %s/%s - ok=%t, %s, %d, %v", node, key, ok, s, i, v)
	return s, i, v, ok
}

func SetConfig(db *sqlx.DB, node string, key string, s string, i int64, v []byte) error {
	_, err := db.Exec("SET_CONFIG", sqlx.Args{"node": node, "key": key, "s": s, "i": i, "b": v})
	if core.IsErr(err, "cannot set config %s/%s with values %s, %d, %v: %v", node, key, s, i, v) {
		return err
	}
	core.Trace("SQL: SET_CONFIG: %s/%s - %s, %d, %v", node, key, s, i, v)
	return nil
}

func GetConfigStruct(db *sqlx.DB, node string, key string, v interface{}) error {
	_, _, b, ok := GetConfig(db, node, key)
	if ok {
		return msgpack.Unmarshal(b, v)
	}
	return sqlx.ErrNoRows
}

func SetConfigStruct(db *sqlx.DB, node string, key string, v interface{}) error {
	data, err := msgpack.Marshal(v)
	if core.IsErr(err, "cannot marshal config %s/%s: %v", node, key) {
		return err
	}
	return SetConfig(db, node, key, "", 0, data)
}

func DelConfigs(db *sqlx.DB, node string) error {
	_, err := db.Exec("DEL_CONFIG", sqlx.Args{"node": node})
	core.IsErr(err, "cannot del configs %s", node)
	return err
}