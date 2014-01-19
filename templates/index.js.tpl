/**
 *  class <%name%>
 * 
 *  <%description%>
 * 
 *  Copyright 2012 Ajax.org Services B.V.
 *
 *  This product includes software developed by
 *  Ajax.org Services B.V. (http://www.ajax.org/).
 *
 *  Author: Mike de Boer <mike@ajax.org>
 **/

"use strict";

var Fs = require("fs");
var Util = require("./../../util");
var error = require("./../../error");

/**
 * @module api
 * @constructor
 **/
var GithubHandler = module.exports = function(client) {
    this.client = client;
    this.routes = JSON.parse(Fs.readFileSync(__dirname + "/routes.json", "utf8"));
};

GithubHandler.prototype = {
    sendError: function(err, msg, block, callback) {
        Util.log(err, block, msg.user, "error");
        if (typeof err == "string")
            err = new error.InternalServerError(err);
        if (callback)
            callback(err);
    },
    handler: function(msg, block, callback) {
        var self = this;
        this.client.httpSend(msg, block, function(err, res) {
            if (err)
                return self.sendError(err, msg, null, callback);

            var ret;
            try {
                ret = res.data && JSON.parse(res.data);
            }
            catch (ex) {
                if (callback)
                    callback(new error.InternalServerError(ex.message), res);
                return;
            }

            ret.headers = {};
            [<%headers%>].forEach(function(header) {
                if (res.headers[header])
                    ret.headers[header] = res.headers[header];
            });

            if (callback)
                callback(null, ret);
        });
    }
};
