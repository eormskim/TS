// Run: npm run tsc
// Output: resources/static/js/ts/test/exampleTS.js (compiled from exampleTS.ts)
class Greeter {
    constructor(message) {
        this.greeting = message;
    }
    greet() {
        return "Hello, " + this.greeting;
    }
}
let greeter = new Greeter("world");
console.log(greeter.greet());
console.log("Hello from exampleTS.ts");
//# sourceMappingURL=exampleTS.js.map