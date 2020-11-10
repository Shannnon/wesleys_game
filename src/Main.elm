module Main exposing (..)

import Playground exposing (..)
import Time exposing (..)



--Model--


main =
    game view update initModel


initModel : Model
initModel =
    { wesMoves = { x = -300, y = 0 }
    , lastShotFired = NeverFired
    , shotBullets = [ NotFired ]
    }


type LastShotFired
    = NeverFired
    | LastFiredStamp Time



-- this is where the type alias' we made up are used


type alias Model =
    { wesMoves : WesMoves
    , lastShotFired : LastShotFired
    , shotBullets : List ShotBullet
    }



-- this is saying WesMoves is an x and y coordinantes


type alias WesMoves =
    { x : Number, y : Number }


type alias InFlightPosition =
    Number


type alias FrozenOriginWesOffset =
    WesMoves



-- this one is a custom type


type ShotBullet
    = NotFired
    | Fired InFlightPosition FrozenOriginWesOffset



--Update--


update : Computer -> Model -> Model
update computer model =
    let
        -- this is where I tell it that if the arrow keys are hit, Wesley moves
        updatedWesMoves =
            { x = model.wesMoves.x + toX computer.keyboard
            , y = model.wesMoves.y + toY computer.keyboard
            }

        -- not sure I fully grasp this part
        updatedBulletShoots =
            updateBulletsShot computer model

        -- or this part
        updatedLastFired =
            updateLastFired computer model.lastShotFired
    in
    { model
        | wesMoves = updatedWesMoves
        , lastShotFired = updatedLastFired
        , shotBullets = updatedBulletShoots
    }



{- I can understand where this is all going (from here to line 146)
   and when I look at it, it makes sense
   but I don't feel like I can repeat it or fully comprehend it, and yes I'm
   practicing utilizing comments more :-D
-}


updateLastFired computer previousFiredValue =
    if computer.keyboard.space then
        LastFiredStamp computer.time

    else
        previousFiredValue


updateBulletsShot computer model =
    let
        incrementedBullets =
            List.foldl (bulletIncrementer computer.screen.width) [] model.shotBullets

        canFire =
            calcCanFire computer.time model.lastShotFired
    in
    case ( canFire, computer.keyboard.space ) of
        ( True, True ) ->
            Fired 15 model.wesMoves :: incrementedBullets

        _ ->
            incrementedBullets


calcCanFire : Time -> LastShotFired -> Bool
calcCanFire (Time currentPosix) lastShotFired =
    case lastShotFired of
        NeverFired ->
            True

        LastFiredStamp (Time lastFiredPosix) ->
            True


moreThanMillisFromPosix checker nowPosix thenPosix =
    let
        delta =
            Time.posixToMillis nowPosix - Time.posixToMillis thenPosix
    in
    if delta > checker then
        True

    else
        False


bulletIncrementer width bullet acc =
    case bullet of
        Fired x wP ->
            if x > (width * 2) then
                acc

            else
                Fired (x + 5) wP :: acc

        NotFired ->
            NotFired :: acc



--View--
-- I feel really good about making updates in view, it speaks to me and I get it lol
{- I wanted to make the target move, so I added the zigzag function which worked
   becasue time can now be recognized (thanks to Doug lol) but it broke EVERYTHING
   I had to reconfigure all of the other elements so they fit on the screen they way
   they were before. Which after a while I figured out, but I have no idea why
   it happened. Now let's see if I can remember how to push this to Github so you
   can see my branch... lol
-}


view : Computer -> Model -> List Shape
view computer model =
    [ theBackground computer
    , theTarget 1000
        |> moveDown 385
        |> moveRight 0
        |> moveX (zigzag 15 -15 5 computer.time)
    , myWesley
        |> scale 0.5
        |> move model.wesMoves.x
            model.wesMoves.y
    ]
        ++ shotBulletsView model
        ++ [ theGround computer |> moveDown 385
           ]



-- I added the computer.screen to clean it up a bit, was a great idea!
{- When I added this to make it look cleaner, I ran into a number of issues,
   one being that it didn't work lol. The reason it didn't work is that
   theBackground and theGround weren't given computer, therefore it didn't know
   what to do with computer.screen.
-}


theBackground computer =
    group
        [ rectangle lightBlue computer.screen.width computer.screen.height
        ]


theBullet =
    group
        [ circle black 10 ]


theTarget time =
    group
        [ circle red 100 |> moveUp 350 |> moveRight 200
        , circle white 80 |> moveUp 350 |> moveRight 200
        , circle red 60 |> moveUp 350 |> moveRight 200
        , circle white 40 |> moveUp 350 |> moveRight 200
        , circle red 20 |> moveUp 350 |> moveRight 200
        ]


theGround computer =
    group
        [ rectangle lightGreen computer.screen.width 500
        ]


shotBulletsView model =
    List.map (shotBulletView model) model.shotBullets


shotBulletView model singleBullet =
    let
        moveFunction : Shape -> Shape
        moveFunction =
            case singleBullet of
                NotFired ->
                    move model.wesMoves.x model.wesMoves.y

                Fired x frozenWP ->
                    move (frozenWP.x + x) frozenWP.y
    in
    group
        [ circle black 5 ]
        |> moveDown 22.5
        |> moveRight 108
        |> moveFunction


myWesley =
    group
        [ square (rgb 212 162 106) 40 |> moveDown 40
        , oval (rgb 212 162 106) 20 40
            |> moveLeft 40
            |> moveUp 10
        , oval (rgb 212 162 106) 20 40
            |> moveRight 40
            |> moveUp 10
        , square (rgb 212 162 106) 80
        , wesEyes |> moveUp 10
        , circle darkYellow 30
            |> moveUp 50
        , circle darkYellow 20
            |> moveUp 50
            |> moveRight 20
        , circle darkYellow 20
            |> moveUp 50
            |> moveLeft 20
        , polygon black [ ( -25, -20 ), ( 0, 2 ), ( 25, -20 ) ]
            |> rotate 180
            |> moveDown 30
        , rectangle white 40 3 |> moveDown 13
        , wesBody |> moveDown 95
        , wesGun |> moveRight 160 |> moveDown 60
        ]


wesEyes =
    group
        [ circle white 15 |> moveLeft 17
        , circle white 15 |> moveRight 17
        , circle blue 10 |> moveLeft 17
        , circle blue 10 |> moveRight 17
        , circle black 4 |> moveLeft 17
        , circle black 4 |> moveRight 17
        ]


wesBody =
    group
        [ rectangle orange 100 120 |> moveDown 10
        , rectangle darkGray 100 100 |> moveDown 120
        , circle (rgb 212 162 106) 12 |> moveLeft 60 |> moveDown 115
        , circle (rgb 212 162 106) 12 |> moveRight 145 |> moveUp 35
        , rectangle orange 30 160 |> moveLeft 60 |> moveDown 30
        , rectangle orange 160 30 |> moveRight 60 |> moveUp 35
        , circle lightBlue 25 |> moveDown 180 |> moveLeft 25
        , circle lightBlue 25 |> moveDown 180 |> moveRight 25
        , rectangle darkGray 100 5 |> moveDown 170
        , rectangle darkOrange 5 85 |> moveLeft 42 |> moveDown 28
        ]


wesGun =
    group
        [ rectangle black 20 50
        , rectangle black 50 20 |> moveRight 30 |> moveUp 15
        ]
