package fs

import (
	"path"

	"github.com/stregato/mio/safe"
)

var (
	FSDir            = "fs"
	HeadersDir       = path.Join(FSDir, "headers")
	DataDir          = path.Join(FSDir, "data")
	ConfigPath       = path.Join(FSDir, "config.conf")
	ErrExists        = "ErrExist: filesystem already exists in %s"
	DefaultGroupName = safe.GroupName("usr") // default group name

	GET_GROUP_NAME = "GET_GROUP_NAME" // query to get group name
)

type FS struct {
	S        *safe.Safe
	StoreUrl string
	Config   Config
}

type Config struct {
	Quota       int64
	Description string
}
