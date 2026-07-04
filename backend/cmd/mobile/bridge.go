package main

/*
#include <stdlib.h>
*/
import "C"
import "unsafe"

//export Invoke
func Invoke(method *C.char, argsJSON *C.char) *C.char {
	goMethod := C.GoString(method)
	goArgs := C.GoString(argsJSON)
	result := dispatch(goMethod, goArgs)
	return C.CString(result)
}

//export FreeCString
func FreeCString(ptr *C.char) {
	C.free(unsafe.Pointer(ptr))
}

func main() {}
