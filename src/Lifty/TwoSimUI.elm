module Lifty.TwoSimUI where

import Maybe        as M
import Maybe.Extra  as M   exposing ((?))
import Array        as A
import Set
import Signal       as S
import Task                exposing (Task)
import Time                exposing (Time)
import Either              exposing (Either(..), elim)
import Effects      as E   exposing (Effects, Never)
import Animation    as Ani exposing (Animation, static, retarget)
import AnimationFrame
import StartApp

import Lifty.Util    exposing (delay)
import Lifty.TwoController as C
import Lifty.TwoSim        as Sim
import Lifty.TwoSimView    as V
import Lifty.TwoSimRender  as R


type alias Action p = Either (V.Action p) (Sim.Action p)

num_floors = 5

init_state =
  { t = 0
  , floors = A.repeat num_floors []
  , calls_up = Set.empty
  , calls_down = Set.empty
  , adding = Nothing
  , leaving = []
  , max_queue = 4
  , lift_cap = 2
  , lifts = A.repeat 2 { dests = Set.empty
                       , next = 0
                       , up = False
                       , busy = False
                       , pax = []
                       , y = static 0 } }

--update : Action p -> V.State s l p -> (V.State s l p, Effects (Action p))
update a s = a |> elim
  (\a -> V.update a s |> \(s', e) -> (s', E.map Right e))
  (\a -> Sim.update (Debug.log "a" a) s |> \(s', ma, e) ->
    (V.animate s a s' ma, E.map Right e))

app = StartApp.start
  { init = (init_state, E.none)
  , view = R.render ((<<) Right << ((<<) Sim.Action << C.Go))
                    (Right << (Sim.Action << C.CallUp))
                    (Right << (Sim.Action << C.CallDown))
                    (Left << V.StartAdd)
                    (Left << V.FinishAdd)
  , update = update
  , inputs = [AnimationFrame.frame |> S.foldp (+) 0 |> S.map (Left << V.Tick)] }

main = app.html

port tasks : Signal (Task Never ())
port tasks = app.tasks
