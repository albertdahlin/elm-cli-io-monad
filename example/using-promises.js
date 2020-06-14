
const readline = require('readline');

let rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});


const writeLine = str => new Promise(next => {
    rl.write(str + "\n");
    next(null);
});

const readLine = () => new Promise(next => rl.question("", next));


const exit = () => new Promise(next => {
    rl.close();
});

const askAge = () =>
    writeLine(`What's your age?`)
        .then(readLine)
        .then((input) => {
            let age = parseInt(input);
            if (isNaN(age)) {
                return writeLine("Not a number, try again:").then(askAge);
            } else {
                return age;
            }
        });


const program =
    writeLine("What's your name?")
        .then(readLine)
        .then((name) => writeLine(`Hello ${name}`))
        .then(askAge)
        .then((age) => {
            if (age > 18) {
                return writeLine("You are an adult.");
            } else {
                return writeLine("You are a minor.");
            }
        });


program.then(exit);
