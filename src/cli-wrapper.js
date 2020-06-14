
const { Elm } = require('./app.js');
const readline = require('readline');


const app = Elm.MyApp.init({
    flags: {
        argv: process.argv
    }
});

let rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});


app.ports.toJsLand.subscribe(function(msg) {
    switch (msg.fn) {
        case 'writeLine':
            rl.write(msg.args[0] + "\n");
            app.ports.fromJsLand.send({});
            break;

        case 'readLine':
            rl.question("", function(line) {
                app.ports.fromJsLand.send(line);
            });
            break;

        case 'exit':
            rl.close();
            process.stdout.write("\n");
            break;


        default:
            console.error("IO?", msg);
    }

});

