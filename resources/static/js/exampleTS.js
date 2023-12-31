// Run: npm run tsc
// Output: resources/static/js/ts/test/exampleTS.js (compiled from exampleTS.ts)
var Greeter = /** @class */ (function () {
    function Greeter(message) {
        this.greeting = message;
    }
    Greeter.prototype.greet = function () {
        return "Hello, " + this.greeting;
    };
    return Greeter;
}());
var greeter = new Greeter("world");
console.log(greeter.greet());
console.log("Hello from exampleTS.ts");
//# sourceMappingURL=exampleTS.js.map