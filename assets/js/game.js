class Space {
  constructor(x, y, board){

    this.board = board;
    this.pos = {
      'x': x,
      'y': y
    }

    this.spaceEl = document.getElementsByClassName(`${x}-${y}`)[0];
    this.setValue = this.setValue.bind(this);
    this.spaceEl.addEventListener('click', board.updateMove([x, y]));
  }

  setValue(val){
    this.spaceEl.textContent = val;
  }
}

class Board {
  constructor() {
    this.main = document.getElementsByClassName('main')[0];
    this.move = [];
    this.grid = [];
    this.clearErrors = this.clearErrors.bind(this);
    this.displayWinner = this.displayWinner.bind(this);
    this.populateSpaces = this.populateSpaces.bind(this);
    this.updateMove = this.updateMove.bind(this);
    this.sendMove = this.sendMove.bind(this);
    this.receiveMove = this.receiveMove.bind(this);
    this.populateSpaces();
  }

  updateMove(newPos){
    return (e) => {
      this.move.push(newPos);
      if(this.move.length > 1){
        this.sendMove();
      }
    }
  }

  sendMove(){
    const xhr = new XMLHttpRequest();
    xhr.open('POST', '/');
    const data = { move: this.move }

    xhr.onload = () => {
      this.receiveMove(JSON.parse(xhr.response));
    }
    xhr.send(JSON.stringify(data));
  }

  receiveMove(response) {
    if(response.errors === ""){
      let {start_val, end_val} = response;
      if(response.winner !== ""){
        this.displayWinner(response.winner);
      } else {
      this.updateValue(this.move[0], start_val);
      this.updateValue(this.move[1], end_val);
      this.clearErrors();
      this.move = [];
      }
    } else {
      this.clearErrors();
      let errors = document.createElement("div");
      errors.className = "errors";
      errors.textContent = response.errors;
      this.main.append(errors);
      this.move = [];
    }
  }

  displayWinner(message){
    let winningEl = document.createElement("h1");
    winningEl.className = "winner";
    winningEl.textContent = message;
    this.main.append(winningEl);
  }

  clearErrors() {
    let errorMessages = document.getElementsByClassName('errors');
    if (errorMessages.length !== 0) {
      errorMessages[0].remove();
    }
  }
  updateValue(pos, val) {
    let x = pos[0];
    let y = pos[1];
    this.grid[x][y].setValue(val);
  }

  populateSpaces() {
    for (let x = 0; x < 8; x++) {
      let row = [];
      for (let y = 0; y < 8; y++) {
        let space = new Space(x, y, this);
        row.push(space);
      }
      this.grid.push(row);
    }
  }
}

let officialBoard = new Board();