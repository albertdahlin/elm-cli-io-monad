module IO exposing
    ( IO, return, writeLn, readLine, do, exit
    , Effect(..), Process, start, step
    )

{-|


# Write IO programs

@docs IO, return, writeLn, readLine, do, exit

# Run IO

@docs Effect, Process, start, step

-}

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type Effect
    = WriteLn String
    | ReadLine
    | Exit
    | NoOp


type Process
    = Process (Decoder ( Process, Effect ))


type IO a
    = IO ((a -> ( Process, Effect )) -> ( Process, Effect ))


do : IO a -> (a -> IO b) -> IO b
do (IO fn) cont =
    IO
        (\next ->
            fn
                (\a ->
                    let
                        (IO io2) =
                            cont a
                    in
                    io2 next
                )
        )


return : a -> IO a
return a =
    IO
        (\next ->
            ( Decode.succeed a
                |> Decode.map next
                |> Process
            , NoOp
            )
        )


readLine : IO String
readLine =
    IO
        (\next ->
            ( Decode.string
                |> Decode.map next
                |> Process
            , ReadLine
            )
        )


writeLn : String -> IO ()
writeLn str =
    IO
        (\next ->
            ( Decode.succeed ()
                |> Decode.map next
                |> Process
            , WriteLn str
            )
        )


exit : IO ()
exit =
    IO
        (\_ ->
            ( Decode.fail "Exited"
                |> Process
            , Exit
            )
        )


step : Value -> Process -> ( Process, Effect )
step value (Process decoder) =
    case Decode.decodeValue decoder value of
        Ok ( nextProcess, nextEffect ) ->
            ( nextProcess
            , nextEffect
            )

        Err err ->
            ( Process decoder
            , NoOp
            )


start : IO () -> ( Process, Effect )
start (IO io) =
    let
        done _ =
            ( Decode.fail "Exited"
                |> Process
            , Exit
            )
    in
    io done
