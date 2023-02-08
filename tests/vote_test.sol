// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "remix_tests.sol";
import "remix_accounts.sol";

import "./stub_token.sol";

import "../vote.sol";

contract testSuite is Voting {
    StubERC20 token;

    function beforeAll() public {
        token = new StubERC20();

        token.mint(TestsAccounts.getAccount(3), 100);
        token.mint(TestsAccounts.getAccount(4), 500);
    }

    /// #sender: account-1
    function createPoll0() public {
        string[] memory options = new string[](2);
        options[0] = "monday";
        options[1] = "it's wednesday my dudes!";

        uint pollId = startPoll(
            "What day is this?",
            options,
            address(token)
        );

        Assert.equal(pollId, 0, "First poll has valid id");
    }

    /// #sender: account-2
    function createPoll1() public {
        string[] memory options = new string[](3);
        options[0] = "cats";
        options[1] = "dogs";
        options[2] = "frogs";

        uint pollId = startPoll(
            "Cats or dogs?",
            options,
            address(token)
        );

        Assert.equal(pollId, 1, "Second poll has valid id");
    }

    function getQuestions() public {
        string memory q;
        string[] memory opts;

        (q, opts) = getQuestion(0);

        Assert.equal(q, "What day is this?", "Correct question for 1'st poll expected.");
        Assert.equal(opts.length, 2, "Correct options count for 1'st poll expected.");
        Assert.equal(opts[0], "monday", "Correct option 0 for 1'st poll expected.");
        Assert.equal(opts[1], "it's wednesday my dudes!", "Correct option 1 for 1'st poll expected.");

        (q, opts) = getQuestion(1);

        Assert.equal(q, "Cats or dogs?", "Correct question for 2'nd poll expected.");
        Assert.equal(opts.length, 3, "Correct options count for 2'nd poll expected.");
        Assert.equal(opts[0], "cats", "Correct option 0 for 2'nd poll expected.");
        Assert.equal(opts[1], "dogs", "Correct option 1 for 2'nd poll expected.");
        Assert.equal(opts[2], "frogs", "Correct option 1 for 2'nd poll expected.");
    }

    function getVoteCounts00() public {
        Assert.equal(getVoteCount(0), 0, "No votes for 1'st poll");
        Assert.equal(getVoteCount(1), 0, "No votes for 2'nd poll");
    }

    /// #sender: account-3
    function vote3() public {
        vote(0, 0);
        vote(1, 1);
    }

    function getVoteCounts11() public {
        Assert.equal(getVoteCount(0), 1, "1 vote for 1'st poll");
        Assert.equal(getVoteCount(1), 1, "1 vote for 2'nd poll");
    }

    /// #sender: account-4
    function vote40() public {
        vote(0, 1);
    }

    function getVoteCounts21() public {
        Assert.equal(getVoteCount(0), 2, "2 votes for 1'st poll");
        Assert.equal(getVoteCount(1), 1, "1 vote for 2'nd poll");
    }

    /// #sender: account-4
    function vote41() public {
        vote(1, 2);
    }

    function getVoteCounts22() public {
        Assert.equal(getVoteCount(0), 2, "2 votes for 1'st poll");
        Assert.equal(getVoteCount(1), 2, "2 votes for 2'nd poll");
    }

    /// #sender: account-1
    function closePoll0() public {
        bool ok;
        (ok, ) = address(this).delegatecall(abi.encodeWithSignature('close(uint256)', 0));

        Assert.ok(ok, "Call success expected");
    }

    /// #sender: account-1
    function closeClosedPoll0() public {
        bool ok;
        (ok, ) = address(this).delegatecall(abi.encodeWithSignature('close(uint256)', 0));

        Assert.ok(!ok, "Call failure expected");
    }

    function validateResultOfPoll0() public {
        PollOptionResult[] memory result = getResult(0);

        Assert.equal(result.length, 2, "Valid options count");
        Assert.equal(result[0].score, 100, "Valid option 0 score");

        Assert.equal(result[1].score, 500, "Valid option 1 score");
    }

    /// #sender: account-2
    function closePoll1() public {
        close(1);
    }

    function validateResultOfPoll1() public {
        PollOptionResult[] memory result = getResult(1);

        Assert.equal(result.length, 3, "Valid options count");
        Assert.equal(result[0].score, 0, "Valid option 0 score");
        Assert.equal(result[0].voters.length, 0, "Valid option 0 voters count");
        Assert.equal(result[0].voteWeights.length, 0, "Valid option 0 vote weights count");

        Assert.equal(result[1].score, 100, "Valid option 1 score");

        Assert.equal(result[2].score, 500, "Valid option 2 score");
    }
}
