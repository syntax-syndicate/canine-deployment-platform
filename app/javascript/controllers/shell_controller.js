import { Controller } from "@hotwired/stimulus"
import { Terminal } from 'xterm';
import consumer from "../channels/consumer"


let currentValue = "";
export default class extends Controller {
  static targets = ["terminal"]
  static values = { projectId: String }
  connect() {
    this.terminal = new Terminal();
    this.terminal.open(this.terminalTarget);
    this.subscription = consumer.subscriptions.create(
      { channel: "ShellChannel", project_id: this.projectIdValue },
      {
        connected: this._connected.bind(this),
        disconnected: this._disconnected.bind(this),
        received: this._received.bind(this)
      }
    );

    this.terminal.onData((data) => {
      if (data === '\r') {
        this.subscription.send({input: currentValue, project_id: this.projectIdValue})
        this.terminal.value = '';
        this.terminal.write('\r\n');
        currentValue = '';
      } else {
        currentValue += data;
        this.terminal.write(data);
      }
    });
  }

  _received(data) {
    console.log(data);
    if (data.message) {
      this.terminal.writeln(data.message);
    } else if (data.output) {
      data.output.split('\n').forEach(line => {
        this.terminal.writeln(line);
      });
    }
    this.terminal.write("$ ")
  }

  _connected() {
    console.log(`Connected to shell channel for project ${this.projectIdValue}`);
    this.terminal.write("$ ")
  }

  _disconnected() {
    console.log(`Disconnected from shell channel for project ${this.projectIdValue}`);
  }
  
  
}
