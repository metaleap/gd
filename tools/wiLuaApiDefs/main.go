package main

import (
	"io/fs"
	"os"
	"path/filepath"
	"slices"
	"strings"
)

type Object struct {
	Name        string
	GlobalInsts []string
	Methods     []string
	Properties  []Property
}

type Property struct {
	Name    string
	GetType string
	SetType string
}

func main() {
	ret := map[string]Object{}

	fs.WalkDir(os.DirFS("."), "3rdparty/turanszkij_WickedEngine", func(path string, dirEntry fs.DirEntry, err error) error {
		if !dirEntry.IsDir() && filepath.Ext(path) == ".cpp" {
			data, _ := os.ReadFile(path)
			src := string(data)
			for _, name := range findOccurrences(src, "Luna<", ">") {
				name = strings.TrimPrefix(strings.TrimPrefix(strings.TrimSuffix(strings.TrimPrefix(name, "wi::lua::"), "_BindLua"), "primitive::"), "scene::")
				obj, exists := ret[name]
				if !exists {
					obj = Object{Name: name}
				}
				obj.GlobalInsts = append(obj.GlobalInsts, findOccurrences(src, `Luna<wi::lua::`+name+`_BindLua>::push_global(wi::lua::GetLuaState(), "`, `"`)...)
				obj.GlobalInsts = append(obj.GlobalInsts, findOccurrences(src, `Luna<`+name+`_BindLua>::push_global(wi::lua::GetLuaState(), "`, `"`)...)
				for i := len(obj.GlobalInsts) - 1; i >= 0; i-- {
					if idx := slices.Index(obj.GlobalInsts, obj.GlobalInsts[i]); idx < i {
						obj.GlobalInsts = append(obj.GlobalInsts[:i], obj.GlobalInsts[i+1:]...)
						i--
					}
				}

				for _, occ := range findOccurrences(src, "lunaproperty("+name+"_BindLua, ", ")") {
					prop := Property{Name: occ}

					obj.Properties = append(obj.Properties, prop)
				}

				ret[name] = obj
			}
		}
		return nil
	})

	// data, _ := json.MarshalIndent(ret, "", "  ")
	// println(string(data))
}

func findOccurrences(src string, start string, end string) (ret []string) {
	for len(src) > 0 {
		if idx1 := strings.Index(src, start); idx1 < 0 {
			break
		} else if idx2 := (idx1 + len(start)) + strings.Index(src[idx1+len(start):], end); idx2 <= idx1 {
			break
		} else {
			ret = append(ret, src[idx1+len(start):idx2])
			src = src[idx2+len(end):]
		}
	}
	return
}
