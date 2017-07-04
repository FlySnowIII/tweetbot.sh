/*
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

var configs;

function log(aMessage, ...aArgs)
{
	if (!configs || !configs.debug)
		return;

	console.log('tweetbotsh-remote-controller: ' + aMessage, ...aArgs);
}

configs = new Configs({
	tweetsh_path : '',
	target_account : '',
	debug : false
});
