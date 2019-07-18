package main

import (
	"fmt"
	"sync"
)

func main() {
	sup := NewSupervisor()
	actor := NewActor(func(msg Msg) Msg {
		fmt.Println(msg)
		return msg
	})

	sup.Add(actor)

	for crash := range sup.crashCh {
		fmt.Println(crash)
	}
}

type Msg interface{}

type Actor struct {
	in      chan Msg
	out     chan Msg
	process func(Msg) Msg
	stop    chan bool
}

func NewActor(fn func(Msg) Msg) *Actor {
	return &Actor{
		in:      make(chan Msg),
		out:     make(chan Msg),
		process: fn,
		stop:    make(chan bool, 1),
	}
}

func (actor *Actor) loop() {
	for {
		select {
		case msg := <-actor.in:
			actor.out <- actor.process(msg)
		case <-actor.stop:
			return
		}
	}
}

type Supervisor struct {
	sync.RWMutex
	actors  map[*Actor]bool
	runCh   chan *Actor
	crashCh chan interface{}
}

func NewSupervisor() *Supervisor {
	sup := &Supervisor{
		actors:  map[*Actor]bool{},
		runCh:   make(chan *Actor, 10),
		crashCh: make(chan interface{}),
	}
	go sup.runLoop()
	return sup
}

func (sup *Supervisor) Add(actor *Actor) {
	sup.Lock()
	defer sup.Unlock()

	sup.actors[actor] = true
	sup.runCh <- actor
}

func (sup *Supervisor) Remove(actor *Actor) {
	if !sup.actors[actor] {
		return
	}
	actor.stop <- true
	delete(sup.actors, actor)
}

func (sup *Supervisor) runLoop() {
	for actor := range sup.runCh {
		go sup.run(actor)
	}
}

func (sup *Supervisor) run(actor *Actor) {
	defer func() {
		crash := recover()
		go sup.sendCrash(crash)
		sup.runCh <- actor
	}()

	actor.loop()
}

func (sup *Supervisor) sendCrash(crash interface{}) {
	select {
	case sup.crashCh <- crash:
	default:
	}
}
