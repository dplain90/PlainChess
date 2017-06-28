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
    if((x + y + 2) % 2 === 0){
      this.spaceEl.classList.add("white");
    } else {
      this.spaceEl.classList.add("black");
    }
  }

  setValue(val){
    this.spaceEl.innerHTML = val;
  }
}

class Board {
  constructor() {
    this.main = document.getElementsByClassName('main')[0];
    this.messages = document.getElementById('messages');
    this.move = [];
    this.grid = [];
    this.clearErrors = this.clearErrors.bind(this);
    this.displayWinner = this.displayWinner.bind(this);
    this.populateSpaces = this.populateSpaces.bind(this);
    this.updateMove = this.updateMove.bind(this);
    this.sendMove = this.sendMove.bind(this);
    this.receiveMove = this.receiveMove.bind(this);
    this.players = 1;
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
    if(this.players === 1) {
      let loading = document.createElement("div");
      loading.id = "loading"
      loading.className = "errors";
      loading.textContent = "Thinking.........";
      this.messages.append(loading);
    }


    xhr.onload = () => {
      if(this.players === 1) {
        document.getElementById('loading').remove();
      }
      console.log(xhr.response);
      console.log(JSON.parse(xhr.response));
      this.receiveMove(JSON.parse(xhr.response));
    }
    xhr.send(JSON.stringify(data));
  }

  receiveMove(response) {
    if(response.errors === ""){
      let {start_val, end_val, engine_start, engine_end, engine_pos_start, engine_pos_end, players, fen} = response;

      window.fen = fen;
      this.players = players;
      if(response.winner !== ""){
        this.displayWinner(response.winner);
      } else {
        this.updateValue(this.move[0], start_val);
        this.updateValue(this.move[1], end_val);
        if(players === 1) {
          this.updateValue(engine_pos_start, engine_start);
          this.updateValue(engine_pos_end, engine_end);
        }
      this.clearErrors();
      this.move = [];
      }
    } else {
      this.clearErrors();
      let errors = document.createElement("div");
      errors.className = "errors";
      errors.textContent = response.errors;
      this.messages.append(errors);
      this.move = [];
    }
  }

  displayWinner(message){
    let winningEl = document.createElement("h1");
    winningEl.className = "winner";
    winningEl.textContent = message;
    this.messages.append(winningEl);
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

class IOConsole {
  constructor(board){
    this.board = board;
    this.messages = document.getElementById('messages');
    this.consoleIO = document.querySelector('#console');

    this.consoleIO.addEventListener('keypress',function(e) {
      let key = e.which || e.keyCode;
      if (key === 13) {
        let xhr = new XMLHttpRequest();
        xhr.responseType = "document";
        xhr.open('GET', e.currentTarget.value);
        xhr.onload = () => {
          window.location = xhr.responseURL;
        }
        xhr.send(toString(this.players));
      }
    });
  }


}

let board = new Board();
let gameConsole = new IOConsole(board);
