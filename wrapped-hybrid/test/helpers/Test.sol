import { Test as stdTest } from "lib/forge-std/src/Test.sol";

contract Test is stdTest {
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal carol = makeAddr("carol");
    address internal chuck = makeAddr("chuck");
}
