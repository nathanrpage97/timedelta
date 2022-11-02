local timedelta = require "timedelta"

describe('timedelta', function()
    describe('new', function()
        it('basic-works', function()

            local basic = timedelta:new{seconds = 3, days = 7}
            assert.equal(basic.days, 7)
            assert.equal(basic.seconds, 3)

            local neg_days = timedelta:new{seconds = 3, days = -7}
            assert.equal(neg_days.days, -7)
            assert.equal(neg_days.seconds, 3)

            local neg_seconds = timedelta:new{seconds = -3, days = 7}
            assert.equal(neg_seconds.days, 6)
            assert.equal(neg_seconds.seconds, 86397)

        end)

        it('basic-fail', function()

            assert.has_error(function()
                -- too large of days
                timedelta:new{seconds = 3, days = 7e14}
            end)
            assert.has_error(function()
                -- too large of seconds
                timedelta:new{seconds = 3e14, days = 7}
            end)
        end)

        it('rounding-hev microseconds', function()

            local a = timedelta:new{microseconds = 1.4}
            assert.equal(2, a.microseconds)

            a = timedelta:new{microseconds = 1.1}
            assert.equal(2, a.microseconds)

            a = timedelta:new{microseconds = 1.9}
            assert.equal(2, a.microseconds)

            a = timedelta:new{microseconds = 2.1}
            assert.equal(2, a.microseconds)

            a = timedelta:new{microseconds = 2.6}
            assert.equal(2, a.microseconds)

            a = timedelta:new{microseconds = -2.6}
            assert.equal(1e6 - 2, a.microseconds)

            a = timedelta:new{microseconds = -3.6}
            assert.equal(1e6 - 4, a.microseconds)

        end)

    end)
end)
