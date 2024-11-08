;;
;; This code can be used to extend the comm language for the WebAssembly target language (average difficulty)
;;

;; https://webassembly.github.io/wabt/demo/wat2wasm/
;; const wasmInstance = new WebAssembly.Instance(wasmModule, {console});
;; const { main } = wasmInstance.exports;

(module
  ;; Import a print function from the host environment.
  (import "console" "log" (func $print (param i32)))

  ;; Memory declaration (1 page = 64KiB)
  (memory 1)
  (export "memory" (memory 0))

  ;; Data for the stack pointer initial value (assuming start at 0)
  (data (i32.const 0) "\00\00\00\00")


  ;; Function to demonstrate the logic
  (func $main
    ;; Local variables, equivalent to t0, t1, t2, and sp in the original code
    (local $t0 i32)
    (local $t1 i32)
    (local $t2 i32)
    (local $sp i32)

    
    ;; Initialize stack pointer and temporary variables
    (local.set $sp (i32.const 0))
    (local.set $t1 (i32.const 1))

    ;; Simulate PUSH operation
    (i32.store (local.get $sp) (local.get $t1))
    (local.set $sp (i32.add (local.get $sp) (i32.const 4)))

    ;; Simulate SET operation
    (local.set $sp (i32.sub (local.get $sp) (i32.const 4)))
    (local.set $t0 (i32.load (local.get $sp)))

    ;; ADD operation
    (local.set $t2 (i32.add (local.get $t0) (local.get $t1)))
    ;; Simulate storing result for printing
    (call $print (local.get $t2))

    ;; SUB operation
    (local.set $t2 (i32.sub (local.get $t0) (local.get $t1)))
    ;; Simulate storing result for printing
    (call $print (local.get $t2))
  )

  ;; Export the main function to make it callable from the host environment
  (start $main)
)