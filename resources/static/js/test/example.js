var Greeter2 = /** @class */ (function () {
    function Greeter2(message) {
        this.greeting = message;
    }
    Greeter2.prototype.greet = function () {
        return "Hello, " + this.greeting;
    };
    return Greeter2;
}());
var greeter2 = new Greeter("world");
console.log(greeter2.greet());
//# sourceMappingURL=example.js.map