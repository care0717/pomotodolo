port module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Html exposing (Html, div, i, p, section, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Platform.Cmd exposing (Cmd)
import Task
import Time


port notifyUser : () -> Cmd msg


port notified : (Bool -> msg) -> Sub msg



-- MODEL


initTime =
    10


type alias Model =
    { zone : Time.Zone
    , timer : Int
    , isStart : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc initTime False
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | DoTimer
    | Reset
    | Notification
    | Notified Bool


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            let
                c =
                    if model.isStart then
                        model.timer - 1

                    else
                        model.timer

                res =
                    if c <= -1 then
                        update Notification model

                    else
                        ( { model | timer = c }
                        , Cmd.none
                        )
            in
            res

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )

        DoTimer ->
            let
                r =
                    not model.isStart
            in
            ( { model | isStart = r }, Cmd.none )

        Reset ->
            ( { model | timer = initTime, isStart = False }
            , Cmd.none
            )

        Notification ->
            ( model, notifyUser () )

        Notified isNotified ->
            update Reset model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ notified Notified, Time.every 1000 Tick ]



-- VIEW


view : Model -> Html Msg
view model =
    let
        c =
            String.fromInt model.timer

        bt =
            if model.isStart then
                "fas fa-stop"

            else
                "fas fa-play"
    in
    section [ class "section" ]
        [ div [ class "container" ]
            [ div
                []
                [ p [ class "title" ] [ text c ]
                ]
            , div
                [ class "icon is-large button", type_ "button", onClick DoTimer ]
                [ i [ class bt ] []
                ]
            , div
                [ class "icon is-large button", type_ "button", onClick Reset ]
                [ i [ class "fas fa-undo" ] []
                ]
            ]
        ]


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
