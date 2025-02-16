[
    {make_install, [{git, "https://github.com/djcruz93/mzbench.git"},
                    {dir, "workers/xmpp"}]},

    {pool, [{size, {numvar, "users-number", 1000}},
            {worker_type, xmpp_worker},
            {worker_start, {linear, {{numvar, "user-rps", 500}, rps}}}],
        [
            % connect to xmpp.example.com:5222 server and
            % use domain.example.com as domain
            % use user_{pool_id} as nickname
            {connect, {iname, "user", {pool_id}},
                      "domain.example.com",
                      "xmpp.example.com",
                      5222},

            % send initial presence
            {initial_presence},

            % wait until everyone is connected to the xmpp server
            {set_signal, init, 1},
            {wait_signal, init, {numvar, "users-number", 1000}},

            % spawn stream parser in the seperate thread and enable message's latency and count parsers
            {spawn_stream_parser, 0, 60000, [{t, histogram},
                                             {t, message},
                                             {t, errors}]},

            % send a private message to random user but me
            {loop, [{time, {{numvar, "duration", 5}, min}},
                    {rate, {ramp, linear, {{numvar, "min-msgs-rps", 1}, rps},
                                          {{numvar, "max-msgs-rps", 10}, rps}}}],
                [{send_message, {recipient, "user", {numvar, "users-number", 1000}}, {marker, 50}, skip}]
            },

            % close socket and halt stream parser
            {close}
        ]
    }

].
