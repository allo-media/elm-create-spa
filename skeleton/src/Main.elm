module Main exposing (main)

import Data.Session exposing (Session)
import Html.Styled as Html exposing (..)
import Navigation exposing (Location)
import Page.Home as Home
import Route exposing (Route)
import Views.Page as Page


type alias Flags =
    {}


type Page
    = Blank
    | HomePage Home.Model
    | NotFound


type alias Model =
    { page : Page
    , session : Session
    }


type Msg
    = HomeMsg Home.Msg
    | SetRoute (Maybe Route)


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    case maybeRoute of
        Nothing ->
            { model | page = NotFound } ! []

        Just Route.Home ->
            let
                ( homeModel, homeCmds ) =
                    Home.init model.session
            in
            { model | page = HomePage homeModel }
                ! [ Cmd.map HomeMsg homeCmds ]


init : Flags -> Location -> ( Model, Cmd Msg )
init _ location =
    let
        -- you'll usually want to retrieve and decode serialized session
        -- information from flags here
        session =
            {}
    in
    setRoute (Route.fromLocation location)
        { page = Blank
        , session = session
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ page, session } as model) =
    let
        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
            { model | page = toModel newModel }
                ! [ Cmd.map toMsg newCmd ]
    in
    case ( msg, page ) of
        ( SetRoute route, _ ) ->
            setRoute route model

        ( HomeMsg homeMsg, HomePage homeModel ) ->
            toPage HomePage HomeMsg (Home.update session) homeMsg homeModel

        ( _, NotFound ) ->
            { model | page = NotFound } ! []

        ( _, _ ) ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        HomePage _ ->
            Sub.none

        NotFound ->
            Sub.none

        Blank ->
            Sub.none


view : Model -> Html Msg
view model =
    let
        pageConfig =
            Page.Config model.session
    in
    case model.page of
        HomePage homeModel ->
            Home.view model.session homeModel
                |> Html.map HomeMsg
                |> Page.frame (pageConfig Page.Home)

        NotFound ->
            Html.div [] [ Html.text "Not found" ]
                |> Page.frame (pageConfig Page.Other)

        Blank ->
            Html.text ""
                |> Page.frame (pageConfig Page.Other)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view >> Html.toUnstyled
        , update = update
        , subscriptions = subscriptions
        }
