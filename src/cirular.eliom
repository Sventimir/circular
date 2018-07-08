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

let%client draw ctx ((r, g, b), size, (x1, y1), (x2, y2)) =
    let color = CSS.Color.string_of_t (CSS.Color.rgb r g b) in
    ctx##.strokeStyle := (Js.string color);
    ctx##.lineWidth := float size;
    ctx##beginPath;
    ctx##(moveTo (float x1) (float y1));
    ctx##(lineTo (float x2) (float y2));
    ctx##stroke

let canvas_elt =
    canvas ~a:[a_width width; a_height height]
        [pcdata "your browser doesn't support canvas"]

let%client init_client () =
    let canvas = Eliom_content.Html.To_dom.of_canvas ~%canvas_elt in
    let ctx = canvas##(getContext (Dom_html._2d_)) in
    ctx##.lineCap := Js.string "round";
    draw ctx ((0, 0, 0), 12, (10, 10), (200, 100))

let handle () () =
    let _ = [%client (init_client () : unit) ] in
    html
        (head (title (pcdata "Graffiti")) [])
        (body [h1 [pcdata "Graffiti"]; canvas_elt])
    |> return

let _ =
    Circular.register ~service:main_service handle
