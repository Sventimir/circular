[%%shared.start]

module T = struct

    type t = int * int

    let equal (ax, ay) (bx, by) = ax = bx && ay = by

    let init total = (0, total)

    let complete = (1, 1)

    let push p (v, total) =
        let v' = p + v in
        if v' > total then (total, total) else (v', total)

    let frac (v, total) =
        float_of_int v /. float_of_int total

end

include T

module Arc = struct

    let pi = 4. *. atan 1.0

    let of_float f = f *. 2.0 *. pi -. 0.5 *. pi

end

[%%client.start]

module type PROG_INIT = sig

    val total : int
    val origin : float * float
    val radius : float

    val ctx : Dom_html.canvasRenderingContext2D Js.t

end

module Signal(Init : PROG_INIT) = struct

    type nonrec t = t React.signal

    let (set_event, set) = React.E.create ()
    let (push_event, push) = React.E.create ()

    let progress =
        let e = React.E.select [
            React.E.map (fun x _ -> x) set_event;
            React.E.map T.push push_event;
        ] in
        React.S.fold ~eq:T.equal ( |> ) (T.init Init.total) e

    let (ox, oy) = Init.origin

    let rec draw from_frac to_frac _ =
        if from_frac < to_frac then
            let next_frac = from_frac +. 0.001 in
            let from_arc = Arc.of_float from_frac in
            let to_arc = Arc.of_float next_frac in
            let callback = Js.wrap_callback (draw next_frac to_frac) in
            Init.ctx##beginPath;
            Init.ctx##arc ox oy Init.radius from_arc to_arc Js._false;
            Init.ctx##stroke;
            ignore (Dom_html.window##requestAnimationFrame callback)

    let trace =
        let handle (from_frac, to_frac) =
            let callback = Js.wrap_callback (draw from_frac to_frac) in
            ignore (Dom_html.window##requestAnimationFrame callback)
        in
        React.S.diff (fun next prev -> frac prev, frac next) progress
        |> React.E.trace handle

end
