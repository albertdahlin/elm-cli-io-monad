port module Cli exposing
    ( CliProgram
    , run
    )

{-|

# Run as a CLI program

@docs CliProgram, run

-}
import IO exposing (Effect(..), IO)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Task

{-| Our Program
-}
type alias CliProgram =
    Program Env Model Msg


type Msg
    = GotNextValue Value


type alias Model =
    IO.Process


port toJsLand : ToJs -> Cmd msg


port fromJsLand : (Value -> msg) -> Sub msg


type alias ToJs =
    { fn : String
    , args : List Value
    }


type alias Env =
    { argv : List String
    }


effectToCmd : Effect -> Cmd Msg
effectToCmd effect =
    case effect of
        WriteLn str ->
            toJsLand { fn = "writeLn", args = [ Encode.string str ] }

        ReadLine ->
            toJsLand { fn = "readLine", args = [] }

        Exit ->
            toJsLand { fn = "exit", args = [] }

        NoOp ->
            callSelf (GotNextValue Encode.null)


init : IO () -> Env -> ( Model, Cmd Msg )
init io env =
    let
        ( process, effect ) =
            IO.start io
    in
    ( process
    , effectToCmd effect
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotNextValue value ->
            let
                ( nextProcess, effect ) =
                    IO.step value model
            in
            ( nextProcess
            , effectToCmd effect
            )


callSelf : Msg -> Cmd Msg
callSelf msg =
    Task.succeed msg
        |> Task.perform identity


subscriptions : Model -> Sub Msg
subscriptions model =
    fromJsLand GotNextValue


{-| Create a `Platform.worker` program.
-}
run : IO () -> Program Env Model Msg
run io =
    Platform.worker
        { init = init io
        , update = update
        , subscriptions = subscriptions
        }
