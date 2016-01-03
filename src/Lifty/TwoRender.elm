module Lifty.TwoRender where

import Debug
import String               exposing (join)
import Maybe          as M
import List           as L
import Array          as A
import Set                  exposing (Set)
import Signal         as S  exposing (Message)
import Animation            exposing (animate)
import Html
import Svg                  exposing (Svg, svg, g, rect, circle, text', text)
import Svg.Attributes       exposing (x, y, width, height, class, opacity)
import Svg.Events           exposing (onClick)

import Lifty.Util           exposing (f_, s_, zeroTo, imapA, mkM, mkM2)
import Lifty.RenderUtil     exposing (circle_, movey)
import Lifty.Render         exposing (rBg, rLifts, rFrame)

rCallBtns : Int -> Set Int -> Set Int -> (Int -> Message) -> (Int -> Message) -> Svg
rCallBtns num_floors calls_up calls_down callUpM callDownM =
  g [] <| flip L.map (zeroTo num_floors) <| \(floor_id) ->
    movey floor_id
      [ circle_ -0.5 0.72 0.2
          [ class (if Set.member floor_id calls_up then "callbtn pressed" else "callbtn")
          , opacity (if floor_id == (num_floors - 1) then "0" else "1")
          , onClick (callUpM floor_id) ]
      , circle_ -0.5 0.28 0.2
          [ class (if Set.member floor_id calls_down then "callbtn pressed" else "callbtn")
          , opacity (if floor_id == 0 then "0" else "1")
          , onClick (callDownM floor_id) ] ]

rLiftsTwo = rLifts (\fi l -> Set.member fi l.dests)

render go callUp callDown a s = let
  num_floors = A.length s.floors
  num_lifts = A.length s.lifts
  in rFrame (2 + num_lifts) (1 + num_floors)
    [ rBg num_floors num_lifts
    , rCallBtns num_floors s.calls_up s.calls_down (mkM a callUp) (mkM a callDown)
    , rLiftsTwo num_floors s.lifts s.t (mkM2 a go) ]
