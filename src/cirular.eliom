[%%shared.start]
open Eliom_content.Html.D
open Lwt

module Circular = Eliom_registration.App(struct
    let application_name = "weles"
    let global_data_path = None
end)

[%%server.start]

let main_service =
  Eliom_service.create
    ~path:(Eliom_service.Path [])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let%shared width  = 700
let%shared height = 400

let%client prepare ctx (r, g, b) size =
    let color = CSS.Color.string_of_t (CSS.Color.rgb r g b) in
    ctx##.strokeStyle := (Js.string color);
    ctx##.lineWidth := float size

let canvas_elt =
    canvas ~a:[a_id "canvas"; a_width width; a_height height]
        [pcdata "your browser doesn't support canvas"]

[%%client.start]

let init_client () =
    let canvas = Eliom_content.Html.To_dom.of_canvas ~%canvas_elt in
    let ctx = canvas##(getContext (Dom_html._2d_)) in
    ctx##.lineCap := Js.string "round";
    prepare ctx (255, 0, 0) 10

let main () =
    let module Prog = Progress.Signal(struct

        let total = 100
        let origin = (150.0, 150.0)
        let radius = 100.0

        let ctx =
            let canvas = Eliom_content.Html.To_dom.of_canvas ~%canvas_elt in
            canvas##(getContext (Dom_html._2d_))

    end) in
    let rec loop () =
        Prog.push 5;
        Lwt_js.sleep 2.0 >>= loop
    in
    loop ()

[%%server.start]

let handle () () =
    let (_ : unit Eliom_client_value.t) = [%client
        init_client ();
        async main
    ] in
    html
        (Eliom_tools.F.head ~title:"Graffitti" ~css:[["css"; "main.css"]] ())
        (body [h1 [pcdata "Graffiti"]; canvas_elt])
    |> return

let _ =
    Circular.register ~service:main_service handle
