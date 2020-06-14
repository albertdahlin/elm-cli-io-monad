port module IO exposing
    ( CliProgram
    , Env
    , IO
    , do
    , readLine
    , return
    , run
    , writeLn
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Task


type alias CliProgram =
    Program Env Model Msg


port toJsLand : ToJs -> Cmd msg


port fromJsLand : (Value -> msg) -> Sub msg


type alias ToJs =
    { fn : String
    , args : List Value
    }


type alias Env =
    { argv : List String
    }


type Msg
    = GotNextValue Value


type Model
    = Model (Decoder ( Model, Cmd Msg ))


type IO a
    = IO ((a -> ( Model, Cmd Msg )) -> ( Model, Cmd Msg ))


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
                |> Model
            , callSelf (GotNextValue Encode.null)
            )
        )


readLine : IO String
readLine =
    IO
        (\next ->
            ( Decode.string
                |> Decode.map next
                |> Model
            , toJsLand { fn = "readLine", args = [] }
            )
        )


writeLn : String -> IO ()
writeLn str =
    IO
        (\next ->
            ( Decode.succeed ()
                |> Decode.map next
                |> Model
            , toJsLand { fn = "writeLn", args = [ Encode.string str ] }
            )
        )


done : () -> ( Model, Cmd Msg )
done _ =
    ( Decode.fail "Exited"
        |> Model
    , toJsLand { fn = "exit", args = [] }
    )


init : IO () -> Env -> ( Model, Cmd Msg )
init (IO io) env =
    io done


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ((Model decoder) as model) =
    case msg of
        GotNextValue value ->
            case Decode.decodeValue decoder value of
                Ok ( newModel, newCmd ) ->
                    ( newModel
                    , newCmd
                    )

                Err err ->
                    ( model
                    , Cmd.none
                    )


callSelf : Msg -> Cmd Msg
callSelf msg =
    Task.succeed msg
        |> Task.perform identity


subscriptions : Model -> Sub Msg
subscriptions model =
    fromJsLand GotNextValue


run : IO () -> Program Env Model Msg
run io =
    Platform.worker
        { init = init io
        , update = update
        , subscriptions = subscriptions
        }
