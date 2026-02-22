package main

import (
	"encoding/json"
	"io/fs"
	"os"
	"path/filepath"
	"slices"
	"strings"
)

type void = struct{}

type Object struct {
	Name        string
	GlobalInsts []string
	Methods     map[string]void
	Properties  map[string]void
}

func main() {
	objs, extras := map[string]Object{}, map[string][]string{}

	fs.WalkDir(os.DirFS("."), "3rdparty/turanszkij_WickedEngine", func(path string, dirEntry fs.DirEntry, err error) error {
		if !dirEntry.IsDir() && filepath.Ext(path) == ".cpp" {
			data, _ := os.ReadFile(path)
			src := string(data)
			for _, name := range findOccurrences(src, "Luna<", ">") {
				name = strings.TrimPrefix(strings.TrimPrefix(strings.TrimSuffix(strings.TrimPrefix(name, "wi::lua::"), "_BindLua"), "primitive::"), "scene::")
				obj, exists := objs[name]
				if !exists {
					obj = Object{Name: name, Properties: map[string]void{}, Methods: map[string]void{}}
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
					obj.Properties[occ] = void{}
				}
				for _, occ := range findOccurrences(src, "lunamethod("+name+"_BindLua, ", ")") {
					obj.Methods[occ] = void{}
				}
				objs[name] = obj
			}

			if extra := (findOccurrences(src, `wi::lua::RunText(R"(`, `)");`)); len(extra) > 0 {
				name := strings.TrimSuffix(strings.TrimPrefix(filepath.Base(path), "wi"), "_BindLua.cpp")
				extras[name] = append(extras[name], findOccurrences(src, `wi::lua::RunText(R"(`, `)");`)...)
			}
		}
		return nil
	})

	data, _ := json.MarshalIndent([]any{objs, extras}, "", "  ")
	println(string(data))
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
