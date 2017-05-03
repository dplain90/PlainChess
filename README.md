Plain Chess
=====

Plain Chess is a lightweight Chess web-app, that cuts out all the toppings and gets right to the meat and potatoes. Ruby on the back-end, Rack serving as the webserver interface, with vanilla JS DOM manipulation & XHTML AJAX requests on the front-end.

How to Play:
---------------
1. Clone or download repo and navigate to root directory.
2. Start Rack Server by running ``` ruby game.rb ``` in console.
3. Navigate to http://localhost:3000/ in your browser.
4. Have fun!

Implementation Details
---------------

The primary goal with Plain Chess is to demonstrate a fully-functional Ruby implementation of Chess without all of the inapplicable extras that come with frameworks/libraries such as JQuery, React, & Rails.

Back-End
---------------

 Candidate moves for each piece on the board are provided by iterating over predefined sets of x,y increments for each class of piece, and then recursively compiling applicable positions.

```
 def moves
    self.directions
      .values
      .map{ |dir| candidates(position, dir) }
      .flatten(1)
  end
```  

Moves is responsible for iterating over each potential direction a piece can go and calling the candidates method.


```
 def candidates(pos, dir, results = [])
    pos = calc_new_pos(pos, dir) if pos == position
    return results if off_board?(pos) || same_color?(pos)
    results << pos
    return results if board.color_of_position(pos) == enemy_color
    candidates(calc_new_pos(pos, dir), dir, results)
  end
```

  Candidates will collect positions that meet necessary criteria for a candidate move (space does not contain own color, is not out of bounds, etc.). This is a method on the parent class of Piece. Certain pieces have special requirements for determining candidate moves, such as the King, Pawn, & Knight. In these cases, the child class overrides this method with it's own criteria.

Front-End
----------

After the HTML is populated via Rack, events and AJAX calls are managed by two classes, Board & Space. Upon the initial render, a Board class is instantiated which conducts a nested loop to populate each DOM element with an instantiation of the Space class. The Space class sets up and handles the onClick events and holds it's designated DOM element as a prop.

When instantiated each Space is also given the Board object in it's constructor. This allows for the onClick callback to be handled by the Board class which waits until both a starting position and ending position have been collected before sending an AJAX request to the back-end to update the grid:

```
updateMove(newPos){
        return (e) => {
          this.move.push(newPos);
          if(this.move.length > 1){
            this.sendMove();
          }
        }
      }
 ```

Once a response is received, the two Space objects that will change call their setValue function which updates their DOM element's textContent to it's new value. By pinpointing these two objects, re-rendering is minimized to the bare-minimum. If errors are sent back in the AJAX response, they are appended to the board's container.

```
updateValue(pos, val) {
        let x = pos[0];
        let y = pos[1];
        this.grid[x][y].setValue(val);
      }

setValue(val){
        this.spaceEl.textContent = val;
      }
 ```


Todos
-----

* [ ] Square Colors
* [ ] Static Piece Images
* [ ] Castling, Pawn Graduations, etc.
