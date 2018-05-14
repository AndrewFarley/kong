use strict;
use warnings FATAL => 'all';
use Test::Nginx::Socket::Lua;

$ENV{TEST_NGINX_HTML_DIR} ||= html_dir();

plan tests => repeat_each() * (blocks() * 3);

run_tests();

__DATA__

=== TEST 1: upstream.clear_header() errors if arguments are not given
--- config
    location = /t {
        content_by_lua_block {
            local SDK = require "kong.sdk"
            local sdk = SDK.new()

            local pok, err = pcall(sdk.upstream.clear_header)
            ngx.say(err)
        }
    }
--- request
GET /t
--- response_body
header must be a string
--- no_error_log
[error]



=== TEST 2: upstream.clear_header() errors if header is not a string
--- config
    location = /t {
        content_by_lua_block {
            local SDK = require "kong.sdk"
            local sdk = SDK.new()

            local pok, err = pcall(sdk.upstream.clear_header, 127001, "foo")
            ngx.say(err)
        }
    }
--- request
GET /t
--- response_body
header must be a string
--- no_error_log
[error]



=== TEST 3: upstream.clear_header() clears a given header
--- http_config
    server {
        listen unix:$TEST_NGINX_HTML_DIR/nginx.sock;

        location /t {
            content_by_lua_block {
                ngx.say("X-Foo: {" .. tostring(ngx.req.get_headers()["X-Foo"]) .. "}")
            }
        }
    }
--- config
    location = /t {

        access_by_lua_block {
            local SDK = require "kong.sdk"
            local sdk = SDK.new()

            sdk.upstream.clear_header("X-Foo")

        }

        proxy_pass http://unix:/$TEST_NGINX_HTML_DIR/nginx.sock;
    }
--- request
GET /t
--- more_headers
X-Foo: bar
--- response_body
X-Foo: {nil}
--- no_error_log
[error]



=== TEST 4: upstream.clear_header() clears multiple given headers
--- http_config
    server {
        listen unix:$TEST_NGINX_HTML_DIR/nginx.sock;

        location /t {
            content_by_lua_block {
                ngx.say("X-Foo: {" .. tostring(ngx.req.get_headers()["X-Foo"]) .. "}")
            }
        }
    }
--- config
    location = /t {

        access_by_lua_block {
            local SDK = require "kong.sdk"
            local sdk = SDK.new()

            sdk.upstream.clear_header("X-Foo")

        }

        proxy_pass http://unix:/$TEST_NGINX_HTML_DIR/nginx.sock;
    }
--- request
GET /t
--- more_headers
X-Foo: hello
X-Foo: world
--- response_body
X-Foo: {nil}
--- no_error_log
[error]



=== TEST 5: upstream.clear_header() clears headers set via set_header
--- http_config
    server {
        listen unix:$TEST_NGINX_HTML_DIR/nginx.sock;

        location /t {
            content_by_lua_block {
                ngx.say("X-Foo: {" .. tostring(ngx.req.get_headers()["X-Foo"]) .. "}")
            }
        }
    }
--- config
    location = /t {

        access_by_lua_block {
            local SDK = require "kong.sdk"
            local sdk = SDK.new()

            sdk.upstream.set_header("X-Foo", "hello")

            sdk.upstream.clear_header("X-Foo")

        }

        proxy_pass http://unix:/$TEST_NGINX_HTML_DIR/nginx.sock;
    }
--- request
GET /t
--- response_body
X-Foo: {nil}
--- no_error_log
[error]



=== TEST 6: upstream.clear_header() clears headers set via add_header
--- http_config
    server {
        listen unix:$TEST_NGINX_HTML_DIR/nginx.sock;

        location /t {
            content_by_lua_block {
                ngx.say("X-Foo: {" .. tostring(ngx.req.get_headers()["X-Foo"]) .. "}")
            }
        }
    }
--- config
    location = /t {

        access_by_lua_block {
            local SDK = require "kong.sdk"
            local sdk = SDK.new()

            sdk.upstream.set_header("X-Foo", "hello")

            sdk.upstream.add_header("X-Foo", "world")

            sdk.upstream.clear_header("X-Foo")

        }

        proxy_pass http://unix:/$TEST_NGINX_HTML_DIR/nginx.sock;
    }
--- request
GET /t
--- response_body
X-Foo: {nil}
--- no_error_log
[error]
